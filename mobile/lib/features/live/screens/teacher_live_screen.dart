import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../services/live_repository.dart';
import '../services/agora_live_helper.dart';

class TeacherLiveScreen extends StatefulWidget {
  const TeacherLiveScreen({super.key});

  @override
  State<TeacherLiveScreen> createState() => _TeacherLiveScreenState();
}

class _TeacherLiveScreenState extends State<TeacherLiveScreen> {
  final _titleController = TextEditingController(text: 'حصة الروضة');
  final _agora = AgoraLiveHelper();
  Map<String, dynamic>? _session;
  bool _loading = false;
  bool _broadcasting = false;
  bool _demoMode = false;
  String? _agoraError;

  @override
  void initState() {
    super.initState();
    _agora.onStateChanged = () {
      if (mounted) setState(() {});
    };
  }

  @override
  void dispose() {
    _agora.leave();
    _agora.disposeNotifier();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _agoraError = null;
    });
    try {
      final repo = LiveRepository(context.read<AuthProvider>().api);
      final result = await repo.start(_titleController.text.trim());
      final agora = result['agora'] as Map<String, dynamic>? ?? {};
      _demoMode = agora['demo'] == true;

      if (_demoMode) {
        setState(() {
          _session = result;
          _broadcasting = true;
          _loading = false;
        });
        return;
      }

      final joined = await _agora.initAndJoin(
        appId: agora['appId']?.toString() ?? '',
        token: agora['token']?.toString() ?? '',
        channelName: agora['channelName']?.toString() ?? '',
        uid: agora['uid'] as int? ?? 0,
        isBroadcaster: true,
      );

      if (!joined) {
        final stream = result['stream'] as Map<String, dynamic>?;
        final streamId = stream?['id'] as int?;
        if (streamId != null) {
          await repo.end(streamId);
        }
        setState(() {
          _loading = false;
          _agoraError =
              'تعذّر بدء الكاميرا/الميكروفون. تأكد من السماح للمتصفح بالوصول.';
        });
        return;
      }

      setState(() {
        _session = result;
        _broadcasting = true;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.coralRed,
          ),
        );
      }
    }
  }

  Future<void> _end() async {
    if (_session == null) return;
    final stream = _session!['stream'] as Map<String, dynamic>?;
    final streamId = stream?['id'] as int?;
    if (streamId == null) return;

    setState(() => _loading = true);
    try {
      if (!mounted) return;
      await _agora.leave();
      if (!mounted) return;
      await LiveRepository(context.read<AuthProvider>().api).end(streamId);
      if (!mounted) return;
      setState(() {
        _session = null;
        _broadcasting = false;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('بث مباشر')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _broadcasting ? _buildLive() : _buildStart(),
        ),
      ),
    );
  }

  Widget _buildStart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.videocam, size: 72, color: AppColors.coralRed),
        const SizedBox(height: 16),
        const Text(
          'المعلمة فقط تبدأ البث',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'يحتاج بث حقيقي: AGORA_APP_ID و AGORA_APP_CERTIFICATE في backend/.env',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        if (_agoraError != null) ...[
          const SizedBox(height: 12),
          Text(
            _agoraError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.coralRed),
          ),
        ],
        const SizedBox(height: 24),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'عنوان البث'),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _loading ? null : _start,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.coralRed,
          ),
          child: _loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('بدء البث المباشر'),
        ),
      ],
    );
  }

  Widget _buildLive() {
    final stream = _session?['stream'] as Map<String, dynamic>?;
    final preview = _agora.localPreview();

    return Column(
      children: [
        if (_demoMode)
          Card(
            color: AppColors.warmOrange.withValues(alpha: 0.15),
            child: const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('وضع تجريبي'),
              subtitle: Text(
                'أضف AGORA_APP_ID و AGORA_APP_CERTIFICATE في backend/.env ثم أعد تشغيل API',
              ),
            ),
          ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
            ),
            child: preview != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: preview,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.live_tv,
                            color: Colors.white, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          stream?['title']?.toString() ?? 'بث نشط',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '🔴 LIVE',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loading ? null : _end,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.coralRed,
          ),
          child: const Text('إنهاء البث'),
        ),
      ],
    );
  }
}
