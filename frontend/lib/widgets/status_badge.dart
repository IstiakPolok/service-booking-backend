import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label = status.toUpperCase();

    switch (label) {
      case 'CONFIRMED':
        bg = AppColors.successBg;
        text = AppColors.success;
        label = 'Confirmed';
        break;
      case 'PENDING':
        bg = AppColors.warningBg;
        text = AppColors.warning;
        label = 'Pending';
        break;
      case 'CANCELLED':
        bg = AppColors.errorBg;
        text = AppColors.error;
        label = 'Cancelled';
        break;
      case 'COMPLETED':
        bg = AppColors.infoBg;
        text = AppColors.info;
        label = 'Completed';
        break;
      default:
        bg = AppColors.divider;
        text = AppColors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: text.withAlpha(50)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
