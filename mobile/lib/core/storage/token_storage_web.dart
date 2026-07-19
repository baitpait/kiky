import 'dart:html' as html;

/// Web — localStorage (secure storage is unreliable/slow on Flutter web).
class TokenStorage {
  Future<String?> read(String key) async => html.window.localStorage[key];

  Future<void> write(String key, String value) async {
    html.window.localStorage[key] = value;
  }

  Future<void> delete(String key) async {
    html.window.localStorage.remove(key);
  }
}
