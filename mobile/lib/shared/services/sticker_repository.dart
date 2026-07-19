import '../../core/api/api_client.dart';

class StickerRepository {
  StickerRepository(this._api);
  final ApiClient _api;

  Future<List<Map<String, dynamic>>> listLevels() async {
    return asJsonList(await _api.get('/admin/sticker-levels'));
  }

  Future<void> createLevel({
    required String name,
    required String color,
    required int sortOrder,
  }) async {
    await _api.post('/admin/sticker-levels', body: {
      'name': name,
      'color': color,
      'sortOrder': sortOrder,
    });
  }

  Future<void> updateLevel(
    int id, {
    required String name,
    required String color,
    required int sortOrder,
  }) async {
    await _api.put('/admin/sticker-levels/$id', body: {
      'name': name,
      'color': color,
      'sortOrder': sortOrder,
    });
  }

  Future<void> deactivateLevel(int id) async {
    await _api.delete('/admin/sticker-levels/$id');
  }

  Future<List<Map<String, dynamic>>> listStickers() async {
    return asJsonList(await _api.get('/admin/stickers'));
  }

  Future<void> createSticker({
    required String name,
    required String iconUrl,
    required int levelId,
    String? description,
  }) async {
    await _api.post('/admin/stickers', body: {
      'name': name,
      'iconUrl': iconUrl,
      'levelId': levelId,
      if (description != null && description.isNotEmpty) 'description': description,
    });
  }

  Future<void> updateSticker(
    int id, {
    required String name,
    required String iconUrl,
    required int levelId,
    String? description,
  }) async {
    await _api.put('/admin/stickers/$id', body: {
      'name': name,
      'iconUrl': iconUrl,
      'levelId': levelId,
      'description': description ?? '',
    });
  }

  Future<void> deactivateSticker(int id) async {
    await _api.delete('/admin/stickers/$id');
  }
}

String normalizeStickerColor(String input) {
  final trimmed = input.trim();
  if (trimmed.startsWith('#') && trimmed.length == 7) return trimmed;
  if (RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(trimmed)) return '#$trimmed';
  return '#6BC04B';
}
