import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';

void showAdminSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.linkGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
}

void showAdminError(BuildContext context, Object error) {
  final message = formatAdminError(error);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.coralRed,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 8),
      ),
    );
}

String formatAdminError(Object error) {
  if (error is ApiException) {
    if (error.statusCode == 401) {
      return 'انتهت الجلسة — سجّل دخولك مجدداً';
    }
    if (error.statusCode == 403) {
      return 'ليس لديك صلاحية لهذا الإجراء';
    }
    if (error.statusCode == 409) {
      return error.message.contains('Username')
          ? 'اسم المستخدم مستخدم مسبقاً'
          : error.message;
    }
    if (error.statusCode == 0 || _isConnectionError(error.message)) {
      return 'السيرفر متوقف — شغّل API أولاً:\ncd backend ثم npm run start:dev';
    }
    if (error.message.isNotEmpty) return error.message;
  }
  final text = error.toString();
  if (_isConnectionError(text)) {
    return 'السيرفر متوقف — شغّل API أولاً:\ncd backend ثم npm run start:dev';
  }
  return text;
}

bool isApiConnectionError(Object error) {
  if (error is ApiException && error.statusCode == 0) return true;
  return _isConnectionError(error.toString());
}

bool _isConnectionError(String text) {
  return text.contains('Failed host lookup') ||
      text.contains('Connection refused') ||
      text.contains('SocketException') ||
      text.contains('ClientException') ||
      text.contains('تعذّر الاتصال') ||
      text.contains('Unable to connect') ||
      text.contains('TimeoutException') ||
      text.contains('timed out') ||
      text.contains('السيرفر متوقف');
}

/// شريط تحذير أعلى الشاشة عندما API غير متصل.
class ApiOfflineBanner extends StatelessWidget {
  const ApiOfflineBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.coralRed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
