import '../../../core/api/api_client.dart';

class LiveRepository {
  LiveRepository(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> start(String title) async {
    return await _api.post('/live/start', body: {'title': title})
        as Map<String, dynamic>;
  }

  Future<void> end(int streamId) async {
    await _api.post('/live/end', body: {'streamId': streamId});
  }

  Future<Map<String, dynamic>?> myActive() async {
    final data = await _api.get('/live/my-active');
    if (data == null) return null;
    return data as Map<String, dynamic>?;
  }

  Future<List<Map<String, dynamic>>> activeStreams() async {
    return asJsonList(await _api.get('/live/active'));
  }

  Future<Map<String, dynamic>> join(int streamId) async {
    return await _api.post('/live/$streamId/join') as Map<String, dynamic>;
  }
}
