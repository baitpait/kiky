import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/json_utils.dart';
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
  bool _checkingActive = true;
  bool _broadcasting = false;
  bool _demoMode = false;
  String? _agoraError;

  LiveRepository get _repo =>
      LiveRepository(context.read<AuthProvider>().api);

  @override
  void initState() {
    super.initState();
    _agora.onStateChanged = () {
      if (mounted) setState(() {});
    };
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkActive());
  }

  @override
  void dispose() {
    _agora.leave();
    _agora.disposeNotifier();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _checkActive() async {
    try {
      final active = await _repo.myActive();
      if (active != null && mounted) {
        setState(() {
          _session = active;
          _demoMode = active['agora']?['demo'] == true;
          _broadcasting = false;
          _checkingActive = false;
        });
      } else if (mounted) {
        setState(() => _checkingActive = false);
      }
    } catch (_) {
      if (mounted) setState(() => _checkingActive = false);
    }
  }

  Future<bool> _joinAgora(Map<String, dynamic> result) async {
    final agora = result['agora'] as Map<String, dynamic>? ?? {};
    _demoMode = agora['demo'] == true;

    if (_demoMode) return true;

    final uid = asIntOrNull(agora['uid']) ?? 0;
    return _agora.initAndJoin(
      appId: agora['appId']?.toString() ?? '',
      token: agora['token']?.toString() ?? '',
      channelName: agora['channelName']?.toString() ?? '',
      uid: uid,
      isBroadcaster: true,
    );
  }

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _agoraError = null;
    });
    try {
      final result = await _repo.start(_titleController.text.trim());
      final resumed = result['resumed'] == true;

      final joined = await _joinAgora(result);

      if (!joined) {
        final stream = result['stream'] as Map<String, dynamic>?;
        final streamId = asIntOrNull(stream?['id']);
        if (streamId != null) await _repo.end(streamId);
        setState(() {
          _loading = false;
          _agoraError =
              'تعذّر بدء الكاميرا/الميكروفون. اسمح للمتصفح بالوصول ثم أعد المحاولة.';
        });
        return;
      }

      setState(() {
        _session = result;
        _broadcasting = true;
        _loading = false;
      });

      if (resumed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم استئناف البث المفتوح'),
          ),
        );
      }
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

  Future<void> _resumeActive() async {
    if (_session == null) return;
    setState(() {
      _loading = true;
      _agoraError = null;
    });

    final joined = await _joinAgora(_session!);
    if (!joined) {
      setState(() {
        _loading = false;
        _agoraError =
            'تعذّر إعادة الاتصال بالبث. اسمح للكاميرا/الميكروفون ثم حاول مجدداً.';
      });
      return;
    }

    setState(() {
      _broadcasting = true;
      _loading = false;
    });
  }

  Future<void> _end() async {
    if (_session == null) return;
    final stream = _session!['stream'] as Map<String, dynamic>?;
    final streamId = asIntOrNull(stream?['id']);
    if (streamId == null) return;

    setState(() => _loading = true);
    try {
      await _agora.leave();
      if (!mounted) return;
      await _repo.end(streamId);
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
          child: _checkingActive
              ? const Center(child: CircularProgressIndicator())
              : _broadcasting
                  ? _buildLive()
                  : _session != null
                      ? _buildResume()
                      : _buildStart(),
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
          'المعلمة تبدأ البث — أولياء الأمور يشاهدون',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'للبث الحقيقي: AGORA_APP_ID + AGORA_APP_CERTIFICATE في backend/.env',
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

  Widget _buildResume() {
    final stream = _session?['stream'] as Map<String, dynamic>?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: AppColors.softSky,
          child: ListTile(
            leading: const Icon(Icons.live_tv, color: AppColors.coralRed),
            title: Text(stream?['title']?.toString() ?? 'بث نشط'),
            subtitle: const Text('لديك بث مفتوح — أكملي أو أنهي'),
          ),
        ),
        const SizedBox(height: 16),
        if (_agoraError != null)
          Text(
            _agoraError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.coralRed),
          ),
        const Spacer(),
        ElevatedButton(
          onPressed: _loading ? null : _resumeActive,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.linkGreen,
          ),
          child: _loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('متابعة البث'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _loading ? null : _end,
          child: const Text('إنهاء البث'),
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
                'شغّل SETUP-AGORA.bat وأضف المفاتيح ثم أعد تشغيل API',
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
