import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// BRAND_IDENTITY §9 — الشعار من assets/brand/logo.png
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.height = 160,
    this.fit = BoxFit.contain,
  });

  final double height;
  final BoxFit fit;

  static const assetPath = 'assets/brand/logo.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => Icon(
        Icons.link_rounded,
        size: height * 0.45,
        color: AppColors.kiddyBlue,
      ),
    );
  }
}
