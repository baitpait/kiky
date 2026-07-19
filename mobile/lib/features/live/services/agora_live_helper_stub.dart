import 'package:flutter/material.dart';

/// Web stub — Agora SDK is heavy; live video uses demo mode on web.
class AgoraLiveHelper {
  bool get isJoined => false;

  Future<bool> initAndJoin({
    required String appId,
    required String token,
    required String channelName,
    required int uid,
    required bool isBroadcaster,
  }) async =>
      false;

  Future<void> leave() async {}

  Widget? localPreview() => null;
}
