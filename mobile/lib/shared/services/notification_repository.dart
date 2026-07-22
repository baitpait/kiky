import '../../core/utils/json_utils.dart';
import '../../core/api/api_client.dart';

class NotificationRepository {
  NotificationRepository(this._api);
  final ApiClient _api;

  Future<List<Map<String, dynamic>>> list() async {
    return asJsonList(await _api.get('/notifications'));
  }

  Future<int> unreadCount() async {
    final result = await _api.get('/notifications/unread-count');
    if (result is int) return result;
    if (result is Map<String, dynamic>) {
      return asInt(result['count']);
    }
    if (result is num) return result.toInt();
    return 0;
  }

  Future<void> markRead(int id) async {
    await _api.put('/notifications/$id/read');
  }

  Future<int> markAllRead() async {
    final result = await _api.put('/notifications/read-all');
    if (result is Map<String, dynamic>) {
      return asInt(result['updated']);
    }
    return 0;
  }

  Future<void> registerDevice({
    required String token,
    required String platform,
  }) async {
    await _api.post(
      '/devices/register',
      body: {'token': token, 'platform': platform},
    );
  }
}
