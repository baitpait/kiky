import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/push/push_registration_service.dart';
import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../shared/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({ApiClient? apiClient, TokenStorage? storage})
      : _api = apiClient ?? ApiClient(),
        _storage = storage ?? TokenStorage() {
    _api.onUnauthorized = _refreshSession;
  }

  final ApiClient _api;
  final TokenStorage _storage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userKey = 'user_json';

  UserModel? _user;
  String? _accessToken;
  bool _loading = false;
  String? _error;
  bool _initialized = false;

  UserModel? get user => _user;
  String? get accessToken => _accessToken;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _initialized;

  ApiClient get api => _api;

  Future<void> init() async {
    try {
      final access = await _readStorage(_accessKey);
      final userJson = await _readStorage(_userKey);

      if (access != null && userJson != null) {
        _accessToken = access;
        _api.setAccessToken(access);
        _user = UserModel.fromJson(
          jsonDecode(userJson) as Map<String, dynamic>,
        );
        await const PushRegistrationService().registerIfAvailable();
      }
    } catch (_) {
      await _clearSession();
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.post(
        '/auth/login',
        body: {'username': username, 'password': password},
      ) as Map<String, dynamic>;
      final tokens = AuthTokens.fromJson(result);
      await _persistSession(tokens);
      _user = tokens.user;
      await const PushRegistrationService().registerIfAvailable();
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = _loginErrorMessage(e.message);
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'تعذّر الاتصال بالخادم';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final refresh = await _storage.read(_refreshKey);
    if (refresh != null) {
      try {
        await _api.post('/auth/logout', body: {'refreshToken': refresh});
      } catch (_) {}
    }
    await _clearSession();
    _user = null;
    notifyListeners();
  }

  Future<bool> _refreshSession() async {
    final refresh = await _storage.read(_refreshKey);
    if (refresh == null) return false;
    try {
      final result = await _api.post(
        '/auth/refresh',
        body: {'refreshToken': refresh},
      ) as Map<String, dynamic>;
      final tokens = AuthTokens.fromJson(result);
      await _persistSession(tokens);
      _user = tokens.user;
      notifyListeners();
      return true;
    } catch (_) {
      await _clearSession();
      _user = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> _persistSession(AuthTokens tokens) async {
    _accessToken = tokens.accessToken;
    _api.setAccessToken(tokens.accessToken);
    await _storage.write(_accessKey, tokens.accessToken);
    await _storage.write(_refreshKey, tokens.refreshToken);
    await _storage.write(
      _userKey,
      jsonEncode({
        'id': tokens.user.id,
        'username': tokens.user.username,
        'role': tokens.user.role,
        'name': tokens.user.name,
      }),
    );
  }

  Future<void> _clearSession() async {
    _accessToken = null;
    _api.setAccessToken(null);
    await _storage.delete(_accessKey);
    await _storage.delete(_refreshKey);
    await _storage.delete(_userKey);
  }

  Future<String?> _readStorage(String key) async {
    final future = _storage.read(key);
    if (kIsWeb) {
      return future.timeout(const Duration(seconds: 2), onTimeout: () => null);
    }
    return future;
  }
}

String _loginErrorMessage(String message) {
  if (message.contains('Invalid credentials')) {
    return 'اسم المستخدم أو كلمة المرور غير صحيحة';
  }
  return message;
}
