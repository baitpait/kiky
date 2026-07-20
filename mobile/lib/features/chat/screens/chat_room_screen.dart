import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/utils/json_utils.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/media_url_utils.dart';
import '../services/chat_repository.dart';
import '../../../shared/services/notification_bell_refresh.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key, required this.conversation});

  final Map<String, dynamic> conversation;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;
  bool _loading = true;
  String? _error;
  int? _myUserId;

  int get _conversationId => widget.conversation['id'] as int;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _init();
    });
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();
    _myUserId = auth.user?.id;
    final repo = ChatRepository(auth.api, auth.accessToken);

    try {
      final messages = await repo.getMessages(_conversationId);
      await repo.markRead(_conversationId);

      if (!mounted) return;

      _channel = repo.connectWebSocket();
      if (_channel != null) {
        repo.wsJoin(_channel!, _conversationId);
        _wsSub = _channel!.stream.listen(_onWsMessage);
      }

      if (!mounted) return;

      setState(() {
        _messages = messages;
        _loading = false;
        _error = null;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _appendMessage(Map<String, dynamic> msg) {
    final id = msg['id'];
    if (id != null && _messages.any((m) => m['id'] == id)) return;
    setState(() => _messages.add(msg));
    _scrollToBottom();
  }

  void _onWsMessage(dynamic raw) {
    try {
      final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
      if (decoded['event'] == 'new_message') {
        final msg = decoded['data'] as Map<String, dynamic>;
        _appendMessage(msg);
        final senderId = msg['senderId'];
        if (senderId != null && asInt(senderId) != _myUserId) {
          NotificationBellRefresh.bump();
        }
      }
    } catch (_) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    final auth = context.read<AuthProvider>();
    final repo = ChatRepository(auth.api, auth.accessToken);

    try {
      if (_channel != null) {
        repo.wsSend(_channel!, _conversationId, text);
      } else {
        final msg = await repo.sendMessage(_conversationId, text);
        _appendMessage(msg);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _sendImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;

    final auth = context.read<AuthProvider>();
    final repo = ChatRepository(auth.api, auth.accessToken);

    try {
      final bytes = await file.readAsBytes();
      final msg = await repo.sendAttachment(
        _conversationId,
        bytes,
        file.name,
        mimeType: file.mimeType,
      );
      _appendMessage(msg);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _channel?.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.conversation['student'] as Map<String, dynamic>?;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(student?['name']?.toString() ?? 'محادثة'),
        ),
        body: Column(
          children: [
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 48, color: Colors.red),
                                const SizedBox(height: 12),
                                Text(
                                  'تعذّر تحميل المحادثة',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(_error!, textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: () {
                                    setState(() {
                                      _loading = true;
                                      _error = null;
                                    });
                                    _init();
                                  },
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) {
                        final m = _messages[i];
                        final sid = m['senderId'];
                        final mine = _myUserId != null &&
                            sid != null &&
                            asInt(sid) == _myUserId;
                        final attachments =
                            m['attachments'] as List<dynamic>? ?? [];

                        return Align(
                          alignment: mine
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: mine
                                  ? AppColors.kiddyBlue
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: mine
                                  ? null
                                  : Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (m['body'] != null)
                                  Text(
                                    m['body'].toString(),
                                    style: TextStyle(
                                      color: mine ? Colors.white : null,
                                    ),
                                  ),
                                for (final a in attachments)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        resolveMediaUrl(
                                          (a as Map)['fileUrl']?.toString() ??
                                              (a)['file_url']?.toString(),
                                        ),
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.broken_image),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _sendImage,
                      icon: const Icon(Icons.image, color: AppColors.kiddyBlue),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالة...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    IconButton(
                      onPressed: _send,
                      icon: const Icon(Icons.send, color: AppColors.linkGreen),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
