import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_indicator.dart';
import 'widgets/booking_item_card.dart';

class MyBookingsView extends StatefulWidget {
  const MyBookingsView({super.key});

  @override
  State<MyBookingsView> createState() => _MyBookingsViewState();
}

class _MyBookingsViewState extends State<MyBookingsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBookings() {
    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    provider.fetchAppointments();
  }

  Future<void> _confirmCancel(AppointmentModel appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Cancel Appointment?'),
          content: Text(
            'Are you sure you want to cancel your appointment for "${appointment.service?.name ?? 'Service'}" on ${appointment.date} at ${appointment.timeSlot}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep Appointment', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<AppointmentProvider>(context, listen: false);
      final success = await provider.cancelAppointment(appointment.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment cancelled successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Could not cancel appointment'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Upcoming'),
                  if (appointmentProvider.upcomingCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${appointmentProvider.upcomingCount}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Previous / Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upcoming Tab
          _buildBookingList(
            appointments: appointmentProvider.upcomingAppointments,
            isLoading: appointmentProvider.isLoading,
            errorMessage: appointmentProvider.errorMessage,
            emptyTitle: 'No Upcoming Appointments',
            emptyDescription: 'You have no scheduled bookings at the moment. Explore services on Home and book your appointment!',
            isUpcomingTab: true,
          ),

          // Previous Tab
          _buildBookingList(
            appointments: appointmentProvider.previousAppointments,
            isLoading: appointmentProvider.isLoading,
            errorMessage: appointmentProvider.errorMessage,
            emptyTitle: 'No Previous Bookings',
            emptyDescription: 'Your completed or cancelled bookings will appear here.',
            isUpcomingTab: false,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList({
    required List<AppointmentModel> appointments,
    required bool isLoading,
    required String? errorMessage,
    required String emptyTitle,
    required String emptyDescription,
    required bool isUpcomingTab,
  }) {
    if (isLoading && appointments.isEmpty) {
      return const LoadingIndicator(message: 'Loading bookings...');
    }

    if (errorMessage != null && appointments.isEmpty) {
      return ErrorStateWidget(
        message: errorMessage,
        onRetry: _loadBookings,
      );
    }

    if (appointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => _loadBookings(),
        color: AppColors.primary,
        child: ListView(
          children: [
            const SizedBox(height: 60),
            EmptyStateWidget(
              icon: Icons.event_busy_rounded,
              title: emptyTitle,
              description: emptyDescription,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadBookings(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return BookingItemCard(
            appointment: appointment,
            onCancel: isUpcomingTab ? () => _confirmCancel(appointment) : null,
          );
        },
      ),
    );
  }
}
