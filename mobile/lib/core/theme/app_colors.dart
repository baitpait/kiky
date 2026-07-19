import 'package:flutter/material.dart';

/// BRAND_IDENTITY §2 — لوحة ألوان Kiddy Link
abstract class AppColors {
  static const kiddyBlue = Color(0xFF4A90D9);
  static const linkGreen = Color(0xFF6BC04B);
  static const warmOrange = Color(0xFFF5A623);
  static const coralRed = Color(0xFFE8634A);
  static const cloudWhite = Color(0xFFF7FAFC);
  static const softSky = Color(0xFFE8F4FC);
  static const textPrimary = Color(0xFF2D3748);
  static const textSecondary = Color(0xFF718096);
  static const borderLight = Color(0xFFE2E8F0);

  /// BRAND_IDENTITY §6 — لون تمييز AppBar حسب الدور
  static Color roleAccent(String role) {
    switch (role) {
      case 'teacher':
        return linkGreen;
      case 'parent':
        return warmOrange;
      case 'admin':
      default:
        return kiddyBlue;
    }
  }
}
