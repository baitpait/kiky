import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../services/live_repository.dart';
import '../services/agora_live_helper.dart';

class ParentLiveScreen extends StatefulWidget {
  const ParentLiveScreen({super.key});

  @override
  State<ParentLiveScreen> createState() => _ParentLiveScreenState();
}

class _ParentLiveScreenState extends State<ParentLiveScreen> {
  List<Map<String, dynamic>> _streams = [];
  bool _loading = true;
  Map<String, dynamic>? _watching;
  final _agora = AgoraLiveHelper();
  bool _demoMode = false;
  String? _agoraError;

  @override
  void initState() {
    super.initState();
    _agora.onStateChanged = () {
      if (mounted) setState(() {});
    };
    _load();
  }

  @override
  void dispose() {
    _agora.leave();
    _agora.disposeNotifier();
    super.dispose();
  }

  int? _broadcasterUid(Map<String, dynamic>? watching) {
    final agora = watching?['agora'] as Map<String, dynamic>?;
    final fromAgora = agora?['broadcasterUid'];
    if (fromAgora is int) return fromAgora;
    if (fromAgora is num) return fromAgora.toInt();

    final stream = watching?['stream'] as Map<String, dynamic>?;
    final teacher = stream?['teacher'] as Map<String, dynamic>?;
    if (teacher == null) return null;
    final userId = teacher['userId'];
    if (userId is int) return userId;
    if (userId is num) return userId.toInt();
    final user = teacher['user'] as Map<String, dynamic>?;
    final raw = user?['id'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return null;
  }

  Future<void> _load() async {
    try {
      final list =
          await LiveRepository(context.read<AuthProvider>().api).activeStreams();
      setState(() {
        _streams = list;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _join(int streamId) async {
    setState(() {
      _loading = true;
      _agoraError = null;
    });
    try {
      final result =
          await LiveRepository(context.read<AuthProvider>().api).join(streamId);
      final agora = result['agora'] as Map<String, dynamic>? ?? {};
      _demoMode = agora['demo'] == true;

      if (_demoMode) {
        setState(() {
          _watching = result;
          _loading = false;
        });
        return;
      }

      final broadcasterUid = _broadcasterUid(result);
      final joined = await _agora.initAndJoin(
        appId: agora['appId']?.toString() ?? '',
        token: agora['token']?.toString() ?? '',
        channelName: agora['channelName']?.toString() ?? '',
        uid: agora['uid'] as int? ?? 0,
        isBroadcaster: false,
        expectedRemoteUid: broadcasterUid,
      );

      if (!joined) {
        setState(() {
          _loading = false;
          _agoraError = 'تعذّر الاتصال بالبث. تحقق من Agora واتصال الإنترنت.';
        });
        return;
      }

      setState(() {
        _watching = result;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _leave() async {
    await _agora.leave();
    setState(() {
      _watching = null;
      _agoraError = null;
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_watching != null ? 'مشاهدة البث' : 'البث المباشر'),
          leading: _watching != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _leave,
                )
              : null,
        ),
        body: _watching != null ? _buildWatch() : _buildList(),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_streams.isEmpty) {
      return const Center(child: Text('لا يوجد بث مباشر الآن'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: _streams.length,
        itemBuilder: (_, i) {
          final s = _streams[i];
          final teacher = s['teacher'] as Map<String, dynamic>?;
          final teacherUser = teacher?['user'] as Map<String, dynamic>?;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.coralRed,
                child: Icon(Icons.live_tv, color: Colors.white),
              ),
              title: Text(s['title']?.toString() ?? 'بث مباشر'),
              subtitle: Text(teacherUser?['name']?.toString() ?? 'المعلمة'),
              trailing: const Chip(
                label: Text('🔴 مباشر'),
                backgroundColor: AppColors.softSky,
              ),
              onTap: () => _join(s['id'] as int),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWatch() {
    final stream = _watching?['stream'] as Map<String, dynamic>?;
    final teacher = stream?['teacher'] as Map<String, dynamic>?;
    final teacherUser = teacher?['user'] as Map<String, dynamic>?;

    return Column(
      children: [
        if (_demoMode)
          const ListTile(
            leading: Icon(Icons.info_outline, color: AppColors.warmOrange),
            title: Text('وضع تجريبي — Agora غير مُعد'),
            subtitle: Text('أضف مفاتيح Agora في backend/.env'),
          ),
        if (_agoraError != null)
          ListTile(
            leading: const Icon(Icons.error_outline, color: AppColors.coralRed),
            title: Text(_agoraError!),
          ),
        Expanded(
          child: ValueListenableBuilder<int?>(
            valueListenable: _agora.remoteUid,
            builder: (context, _, __) {
              final remote = _agora.remotePreview();
              return Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: remote != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: remote,
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!_demoMode && _agora.isJoined)
                              const Padding(
                                padding: EdgeInsets.all(24),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            else
                              const Icon(Icons.live_tv,
                                  color: Colors.white, size: 64),
                            const SizedBox(height: 16),
                            Text(
                              stream?['title']?.toString() ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              teacherUser?['name']?.toString() ?? '',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '🔴 LIVE',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _leave,
            child: const Text('مغادرة البث'),
          ),
        ),
      ],
    );
  }
}
