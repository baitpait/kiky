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

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _agora.leave();
    super.dispose();
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
    setState(() => _loading = true);
    try {
      final result =
          await LiveRepository(context.read<AuthProvider>().api).join(streamId);
      final agora = result['agora'] as Map<String, dynamic>? ?? {};
      _demoMode = agora['demo'] == true;

      if (!_demoMode) {
        await _agora.initAndJoin(
          appId: agora['appId']?.toString() ?? '',
          token: agora['token']?.toString() ?? '',
          channelName: agora['channelName']?.toString() ?? '',
          uid: agora['uid'] as int? ?? 0,
          isBroadcaster: false,
        );
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
    setState(() => _watching = null);
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
          ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.live_tv, color: Colors.white, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    stream?['title']?.toString() ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    teacherUser?['name']?.toString() ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '🔴 LIVE',
                    style: TextStyle(color: Colors.redAccent, fontSize: 20),
                  ),
                ],
              ),
            ),
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
