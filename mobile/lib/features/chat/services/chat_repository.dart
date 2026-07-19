import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/utils/image_mime_utils.dart';

class ChatRepository {
  ChatRepository(this._api, this._accessToken);
  final ApiClient _api;
  final String? _accessToken;

  Future<List<Map<String, dynamic>>> listConversations() async {
    return asJsonList(await _api.get('/conversations'));
  }

  Future<Map<String, dynamic>> openConversation(int studentId) async {
    return await _api.post('/conversations', body: {'studentId': studentId})
        as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getMessages(int conversationId) async {
    return asJsonList(
      await _api.get('/conversations/$conversationId/messages'),
    );
  }

  Future<Map<String, dynamic>> sendMessage(int conversationId, String body) async {
    return await _api.post('/conversations/$conversationId/messages', body: {
      'body': body,
    }) as Map<String, dynamic>;
  }

  Future<void> markRead(int conversationId) async {
    await _api.put('/conversations/$conversationId/read');
  }

  Future<Map<String, dynamic>> sendAttachment(
    int conversationId,
    List<int> bytes,
    String filename, {
    String? body,
    String? mimeType,
  }) async {
    final mime = resolveImageMime(filename, mimeType);
    final safeName = ensureImageFilename(filename, mime);
    return await _api.uploadMultipart(
          '/conversations/$conversationId/attachments',
          fileField: 'file',
          bytes: bytes,
          filename: safeName,
          contentType: mime,
          fields: body != null ? {'body': body} : {},
        ) as Map<String, dynamic>;
  }

  WebSocketChannel? connectWebSocket() {
    if (_accessToken == null) return null;
    final uri = Uri.parse(
      '${ApiConstants.wsBaseUrl}/ws/chat?token=$_accessToken',
    );
    return WebSocketChannel.connect(uri);
  }

  void wsJoin(WebSocketChannel channel, int conversationId) {
    channel.sink.add(jsonEncode({
      'event': 'join',
      'data': {'conversationId': conversationId},
    }));
  }

  void wsSend(WebSocketChannel channel, int conversationId, String body) {
    channel.sink.add(jsonEncode({
      'event': 'send',
      'data': {'conversationId': conversationId, 'body': body},
    }));
  }
}
