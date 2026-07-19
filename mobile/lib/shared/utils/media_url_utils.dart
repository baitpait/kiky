import '../../core/constants/api_constants.dart';

/// Resolves photo/media URLs for the current app host (localhost vs 127.0.0.1).
String resolveMediaUrl(String? url) {
  if (url == null || url.isEmpty) return '';

  final apiBase = ApiConstants.baseUrl;
  final origin = apiBase.endsWith('/api')
      ? apiBase.substring(0, apiBase.length - 4)
      : apiBase;

  if (url.startsWith('/')) return '$origin$url';

  final uri = Uri.tryParse(url);
  if (uri != null && uri.hasScheme && uri.path.isNotEmpty) {
    if (uri.path.startsWith('/uploads/') || uri.path.contains('/uploads/')) {
      return '$origin${uri.path}';
    }
    return url;
  }

  return '$origin/$url';
}
