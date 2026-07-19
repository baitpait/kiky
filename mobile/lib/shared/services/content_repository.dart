import '../../../core/api/api_client.dart';

class ContentRepository {
  ContentRepository(this._api);
  final ApiClient _api;

  // Banners
  Future<List<Map<String, dynamic>>> listBanners() async {
    return asJsonList(await _api.get('/admin/banners'));
  }

  Future<Map<String, dynamic>> createBanner(Map<String, dynamic> body) async {
    return await _api.post('/admin/banners', body: body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateBanner(int id, Map<String, dynamic> body) async {
    return await _api.put('/admin/banners/$id', body: body) as Map<String, dynamic>;
  }

  Future<void> deleteBanner(int id) async {
    await _api.delete('/admin/banners/$id');
  }

  // Calendar
  Future<List<Map<String, dynamic>>> listEvents() async {
    return asJsonList(await _api.get('/admin/calendar-events'));
  }

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> body) async {
    return await _api.post('/admin/calendar-events', body: body)
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateEvent(int id, Map<String, dynamic> body) async {
    return await _api.put('/admin/calendar-events/$id', body: body)
        as Map<String, dynamic>;
  }

  Future<void> deleteEvent(int id) async {
    await _api.delete('/admin/calendar-events/$id');
  }

  // Public
  Future<List<Map<String, dynamic>>> publicBanners() async {
    return asJsonList(await _api.get('/banners'));
  }

  Future<List<Map<String, dynamic>>> publicCalendar() async {
    return asJsonList(await _api.get('/calendar-events'));
  }

  // Notifications
  Future<void> sendNotification(Map<String, dynamic> body) async {
    await _api.post('/admin/notifications/send', body: body);
  }
}
