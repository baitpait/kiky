import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/splash_screen.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  runApp(const KiddyLinkApp());
}

class KiddyLinkApp extends StatefulWidget {
  const KiddyLinkApp({super.key});

  @override
  State<KiddyLinkApp> createState() => _KiddyLinkAppState();
}

class _KiddyLinkAppState extends State<KiddyLinkApp> {
  late final AuthProvider _auth;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = AuthProvider()..init();
    _router = AppRouter(_auth).router;
  }

  @override
  void dispose() {
    _router.dispose();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _auth,
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isInitialized) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              locale: const Locale('ar'),
              builder: (context, child) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: DefaultTextStyle(
                    style: const TextStyle(fontFamily: AppTheme.fontFamily),
                    child: child ?? const SizedBox.shrink(),
                  ),
                );
              },
              home: const SplashScreen(),
            );
          }

          return MaterialApp.router(
            title: 'Kiddy Link',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.textPrimary,
                  ),
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
