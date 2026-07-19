import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// BRAND_IDENTITY §6 — شارة الدور في بطاقة الترحيب
class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role});

  final String role;

  String get _label {
    switch (role) {
      case 'teacher':
        return 'معلمة';
      case 'parent':
        return 'ولي أمر';
      case 'admin':
        return 'مديرة';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.roleAccent(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
