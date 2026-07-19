import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraLiveHelper {
  RtcEngine? _engine;
  bool _joined = false;

  bool get isJoined => _joined;

  Future<bool> initAndJoin({
    required String appId,
    required String token,
    required String channelName,
    required int uid,
    required bool isBroadcaster,
  }) async {
    if (appId.isEmpty || token == 'demo-token') return false;

    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    await _engine!.enableVideo();
    await _engine!.setClientRole(
      role: isBroadcaster
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience,
    );

    if (isBroadcaster) {
      await _engine!.startPreview();
    }

    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: isBroadcaster
            ? ClientRoleType.clientRoleBroadcaster
            : ClientRoleType.clientRoleAudience,
      ),
    );

    _joined = true;
    return true;
  }

  Future<void> leave() async {
    if (_engine != null && _joined) {
      await _engine!.leaveChannel();
      await _engine!.release();
      _engine = null;
      _joined = false;
    }
  }

  Widget? localPreview() {
    if (_engine == null || !_joined) return null;
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }
}
