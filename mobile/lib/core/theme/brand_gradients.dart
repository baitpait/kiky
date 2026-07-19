import 'package:flutter/material.dart';
import 'app_colors.dart';

/// BRAND_IDENTITY §2.5 — تدرجات العلامة
abstract class BrandGradients {
  static const logoGradient = LinearGradient(
    colors: [AppColors.kiddyBlue, AppColors.linkGreen],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const splashBackground = LinearGradient(
    colors: [AppColors.softSky, AppColors.cloudWhite],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
