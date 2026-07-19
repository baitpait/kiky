import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/brand_gradients.dart';
import 'brand_logo.dart';

/// BRAND_IDENTITY §5.1 — Splash Screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: BrandGradients.splashBackground,
          ),
          child: const SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(flex: 2),
                BrandLogo(height: 200),
                Spacer(flex: 3),
                CircularProgressIndicator(color: AppColors.kiddyBlue),
                SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
