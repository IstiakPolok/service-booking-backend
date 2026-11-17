import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/service_model.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../main_navigation_view.dart';
import 'widgets/booking_success_dialog.dart';
import 'widgets/time_slot_grid.dart';

class BookingView extends StatefulWidget {
  final ServiceModel service;

  const BookingView({super.key, required this.service});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  late DateTime _selectedDate;
  String? _selectedSlot;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default to tomorrow or today
    _selectedDate = DateTime.now().add(const Duration(days: 1));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSlots();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String get _formattedDateString => DateFormat('yyyy-MM-dd').format(_selectedDate);

  void _loadSlots() {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    appointmentProvider.fetchAvailableSlots(
      serviceId: widget.service.id,
      date: _formattedDateString,
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now, // Prevents past dates!
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null; // Reset slot on date change
      });
      _loadSlots();
    }
  }

  Future<void> _submitBooking() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an available time slot'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

    try {
      final appointment = await appointmentProvider.bookAppointment(
        serviceId: widget.service.id,
        date: _formattedDateString,
        timeSlot: _selectedSlot!,
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;

      if (appointment != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => BookingSuccessDialog(
            appointment: appointment,
            onViewBookings: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainNavigationView(initialIndex: 1), // Go to Bookings tab
                ),
                (route) => false,
              );
            },
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // In case of conflict, refresh slots so the newly booked slot shows disabled
      _loadSlots();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Summary Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.service.image,
                      width: 65,
                      height: 65,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 65,
                        height: 65,
                        color: AppColors.primary,
                        child: const Icon(Icons.spa, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.service.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              Formatters.duration(widget.service.duration),
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const Text(' • ', style: TextStyle(color: AppColors.textMuted)),
                            Text(
                              widget.service.category,
                              style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.currency(widget.service.price),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date Selection
            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Time Slots Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Time Slots',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (!appointmentProvider.isSlotsLoading)
                  Text(
                    '${appointmentProvider.availableSlots.where((s) => s.isAvailable).length} open',
                    style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            TimeSlotGrid(
              slots: appointmentProvider.availableSlots,
              selectedSlot: _selectedSlot,
              isLoading: appointmentProvider.isSlotsLoading,
              onSlotSelected: (slot) {
                setState(() {
                  _selectedSlot = slot;
                });
              },
            ),
            const SizedBox(height: 24),

            // Notes / Special Requests
            CustomTextField(
              label: 'Notes / Special Requests (Optional)',
              hint: 'Any preferences, allergies, or instructions for the specialist...',
              controller: _notesController,
              maxLines: 3,
              prefixIcon: Icons.notes_rounded,
            ),
            const SizedBox(height: 24),

            // Price Breakdown Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Service Fee', style: TextStyle(color: AppColors.textSecondary)),
                      Text(Formatters.currency(widget.service.price), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Booking & Tax Fee', style: TextStyle(color: AppColors.textSecondary)),
                      Text('\$0.00 (Free)', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Divider(height: 20, color: AppColors.divider),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total to Pay',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      Text(
                        Formatters.currency(widget.service.price),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            CustomButton(
              text: 'Confirm & Book Appointment',
              icon: Icons.check_circle_outline_rounded,
              isLoading: appointmentProvider.isBooking,
              onPressed: _submitBooking,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
