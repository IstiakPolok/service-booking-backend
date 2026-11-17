import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/appointment_model.dart';
import '../../../widgets/custom_button.dart';

class BookingSuccessDialog extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onViewBookings;

  const BookingSuccessDialog({
    super.key,
    required this.appointment,
    required this.onViewBookings,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.successBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 52, color: AppColors.success),
            ),
            const SizedBox(height: 18),

            const Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your appointment has been successfully scheduled.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildRow('Service', appointment.service?.name ?? 'Service'),
                  const Divider(height: 16, color: AppColors.divider),
                  _buildRow('Date', Formatters.formatDate(appointment.date)),
                  const Divider(height: 16, color: AppColors.divider),
                  _buildRow('Time', appointment.timeSlot),
                  const Divider(height: 16, color: AppColors.divider),
                  _buildRow('Total Fee', Formatters.currency(appointment.totalAmount)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: 'View My Bookings',
              onPressed: () {
                Navigator.pop(context);
                onViewBookings();
              },
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: 'Done',
              isOutlined: true,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
