import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/time_slot_model.dart';

class TimeSlotGrid extends StatelessWidget {
  final List<TimeSlotModel> slots;
  final String? selectedSlot;
  final ValueChanged<String> onSlotSelected;
  final bool isLoading;

  const TimeSlotGrid({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
            SizedBox(height: 10),
            Text(
              'Checking slot availability...',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (slots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No slots available for this date. Please pick another date.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: slots.map((slot) {
        final isSelected = selectedSlot == slot.timeSlot;
        final isAvailable = slot.isAvailable;

        return InkWell(
          onTap: isAvailable ? () => onSlotSelected(slot.timeSlot) : null,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: !isAvailable
                  ? const Color(0xFFF1F5F9) // Disabled background
                  : isSelected
                      ? AppColors.primary
                      : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: !isAvailable
                    ? AppColors.border
                    : isSelected
                        ? AppColors.primary
                        : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  !isAvailable
                      ? Icons.block_rounded
                      : isSelected
                          ? Icons.check_circle_rounded
                          : Icons.access_time_rounded,
                  size: 15,
                  color: !isAvailable
                      ? AppColors.textMuted
                      : isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  slot.timeSlot,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: !isAvailable
                        ? AppColors.textMuted
                        : isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                    decoration: !isAvailable ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (!isAvailable) ...[
                  const SizedBox(width: 4),
                  const Text(
                    '(Booked)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
