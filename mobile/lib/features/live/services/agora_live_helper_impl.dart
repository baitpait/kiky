import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Real Agora RTC — Web (iris_web) + Android/iOS.
class AgoraLiveHelper {
  RtcEngine? _engine;
  RtcEngineEventHandler? _handler;
  bool _joined = false;
  String? _channelName;
  int? _localUid;

  bool _disposed = false;

  final ValueNotifier<int?> remoteUid = ValueNotifier(null);
  VoidCallback? onStateChanged;

  bool get isJoined => _joined;

  Future<bool> initAndJoin({
    required String appId,
    required String token,
    required String channelName,
    required int uid,
    required bool isBroadcaster,
    int? expectedRemoteUid,
  }) async {
    if (appId.isEmpty || token.isEmpty || token == 'demo-token') {
      return false;
    }

    try {
      if (!kIsWeb) {
        await [Permission.microphone, Permission.camera].request();
      }

      await leave();

      _channelName = channelName;
      _localUid = uid;
      if (!_disposed) {
        remoteUid.value = null;
      }

      _engine = createAgoraRtcEngine();
      await _engine!.initialize(
        RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

      _handler = RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          if (!isBroadcaster &&
              expectedRemoteUid != null &&
              expectedRemoteUid != uid &&
              !_disposed) {
            remoteUid.value = expectedRemoteUid;
          }
          onStateChanged?.call();
        },
        onUserJoined: (connection, rUid, elapsed) {
          if (rUid != 0 && rUid != _localUid && !_disposed) {
            remoteUid.value = rUid;
            onStateChanged?.call();
          }
        },
        onUserOffline: (connection, rUid, reason) {
          if (!_disposed && remoteUid.value == rUid) {
            remoteUid.value = null;
            onStateChanged?.call();
          }
        },
        onError: (err, msg) {
          debugPrint('AgoraLiveHelper error: $err — $msg');
        },
      );
      _engine!.registerEventHandler(_handler!);

      await _engine!.enableVideo();
      await _engine!.enableAudio();

      final role = isBroadcaster
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience;

      await _engine!.setClientRole(role: role);

      if (isBroadcaster) {
        await _engine!.startPreview();
      }

      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: role,
          publishCameraTrack: isBroadcaster,
          publishMicrophoneTrack: isBroadcaster,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          audienceLatencyLevel: isBroadcaster
              ? AudienceLatencyLevelType.audienceLatencyLevelUltraLowLatency
              : AudienceLatencyLevelType.audienceLatencyLevelLowLatency,
        ),
      );

      _joined = true;
      return true;
    } catch (e, st) {
      debugPrint('AgoraLiveHelper initAndJoin failed: $e\n$st');
      await leave();
      return false;
    }
  }

  Future<void> leave() async {
    if (!_disposed) {
      remoteUid.value = null;
    }
    if (_engine != null) {
      if (_handler != null) {
        _engine!.unregisterEventHandler(_handler!);
        _handler = null;
      }
      if (_joined) {
        await _engine!.leaveChannel();
      }
      await _engine!.release();
      _engine = null;
      _joined = false;
    }
    _channelName = null;
    _localUid = null;
  }

  void disposeNotifier() {
    _disposed = true;
    remoteUid.dispose();
  }

  Widget? localPreview() {
    if (_engine == null || !_joined) return null;
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(
          uid: 0,
          renderMode: RenderModeType.renderModeFit,
        ),
      ),
    );
  }

  Widget? remotePreview() {
    final rUid = remoteUid.value;
    final channel = _channelName;
    if (_engine == null || !_joined || rUid == null || channel == null) {
      return null;
    }
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(
          uid: rUid,
          renderMode: RenderModeType.renderModeFit,
        ),
        connection: RtcConnection(channelId: channel),
      ),
    );
  }
}
