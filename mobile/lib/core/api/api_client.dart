import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';

class ApiClient {
  ApiClient({http.Client? client, this.onUnauthorized})
      : _client = client ?? http.Client();

  final http.Client _client;
  String? _accessToken;
  Future<bool> Function()? onUnauthorized;
  bool _isRefreshing = false;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  Map<String, String> get _authHeaders => {
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  Future<dynamic> get(String path) async {
    try {
      return await _withRetry(() => _client
          .get(Uri.parse('${ApiConstants.baseUrl}$path'), headers: _jsonHeaders)
          .timeout(ApiConstants.connectTimeout));
    } catch (e) {
      throw _wrapNetworkError(e);
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    try {
      return await _withRetry(() => _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}$path'),
            headers: _jsonHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectTimeout));
    } catch (e) {
      throw _wrapNetworkError(e);
    }
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    try {
      return await _withRetry(() => _client
          .put(
            Uri.parse('${ApiConstants.baseUrl}$path'),
            headers: _jsonHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectTimeout));
    } catch (e) {
      throw _wrapNetworkError(e);
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      return await _withRetry(() => _client
          .delete(
            Uri.parse('${ApiConstants.baseUrl}$path'),
            headers: _jsonHeaders,
          )
          .timeout(ApiConstants.connectTimeout));
    } catch (e) {
      throw _wrapNetworkError(e);
    }
  }

  Future<dynamic> _withRetry(
    Future<http.Response> Function() request,
  ) async {
    var response = await request();
    if (response.statusCode == 401 &&
        onUnauthorized != null &&
        !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshed = await onUnauthorized!();
        if (refreshed) {
          response = await request();
        }
      } finally {
        _isRefreshing = false;
      }
    }
    return _handleResponse(response);
  }

  Future<dynamic> uploadMultipart(
    String path, {
    required String fileField,
    required List<int> bytes,
    required String filename,
    required Map<String, String> fields,
    String? contentType,
  }) async {
    try {
      var response = await _sendMultipart(
        path,
        fileField: fileField,
        bytes: bytes,
        filename: filename,
        fields: fields,
        contentType: contentType,
      );
      if (response.statusCode == 401 &&
          onUnauthorized != null &&
          !_isRefreshing) {
        _isRefreshing = true;
        try {
          final refreshed = await onUnauthorized!();
          if (refreshed) {
            response = await _sendMultipart(
              path,
              fileField: fileField,
              bytes: bytes,
              filename: filename,
              fields: fields,
              contentType: contentType,
            );
          }
        } finally {
          _isRefreshing = false;
        }
      }
      return _handleResponse(response);
    } catch (e) {
      throw _wrapNetworkError(e);
    }
  }

  Future<http.Response> _sendMultipart(
    String path, {
    required String fileField,
    required List<int> bytes,
    required String filename,
    required Map<String, String> fields,
    String? contentType,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_authHeaders);
    request.fields.addAll(fields);
    request.files.add(http.MultipartFile.fromBytes(
      fileField,
      bytes,
      filename: filename,
      contentType: contentType != null ? MediaType.parse(contentType) : null,
    ));

    final streamed = await request.send().timeout(ApiConstants.connectTimeout);
    return http.Response.fromStream(streamed);
  }

  ApiException _wrapNetworkError(Object error) {
    if (error is ApiException) return error;
    return ApiException(error.toString(), 0);
  }

  dynamic _handleResponse(http.Response response) {
    dynamic decoded;
    if (response.body.isNotEmpty) {
      decoded = jsonDecode(response.body);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'];
      if (message is List) {
        throw ApiException(message.join(', '), response.statusCode);
      }
      throw ApiException(
        message?.toString() ?? 'Request failed',
        response.statusCode,
      );
    }
    throw ApiException('Request failed', response.statusCode);
  }
}

class ApiException implements Exception {
  ApiException(this.message, this.statusCode);
  final String message;
  final int statusCode;

  @override
  String toString() => message;
}

List<Map<String, dynamic>> asJsonList(dynamic data) {
  if (data is List) {
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
  return [];
}
