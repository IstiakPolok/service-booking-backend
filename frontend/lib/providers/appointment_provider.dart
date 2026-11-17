import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import '../models/time_slot_model.dart';
import '../services/appointment_service.dart';

class AppointmentProvider extends ChangeNotifier {
  List<AppointmentModel> _upcomingAppointments = [];
  List<AppointmentModel> _previousAppointments = [];
  List<TimeSlotModel> _availableSlots = [];

  bool _isLoading = false;
  bool _isSlotsLoading = false;
  bool _isBooking = false;
  String? _errorMessage;

  List<AppointmentModel> get upcomingAppointments => _upcomingAppointments;
  List<AppointmentModel> get previousAppointments => _previousAppointments;
  List<TimeSlotModel> get availableSlots => _availableSlots;

  bool get isLoading => _isLoading;
  bool get isSlotsLoading => _isSlotsLoading;
  bool get isBooking => _isBooking;
  String? get errorMessage => _errorMessage;

  int get upcomingCount => _upcomingAppointments.length;

  /// Fetch user's appointments (Upcoming and Previous)
  Future<void> fetchAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        AppointmentService.getUserAppointments(filter: 'upcoming'),
        AppointmentService.getUserAppointments(filter: 'previous'),
      ]);

      _upcomingAppointments = results[0];
      _previousAppointments = results[1];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check available time slots for a service on a given date
  Future<void> fetchAvailableSlots({
    required String serviceId,
    required String date,
  }) async {
    _isSlotsLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final slots = await AppointmentService.getAvailableSlots(
        serviceId: serviceId,
        date: date,
      );
      _availableSlots = slots;
      _isSlotsLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isSlotsLoading = false;
      notifyListeners();
    }
  }

  /// Book an appointment
  Future<AppointmentModel?> bookAppointment({
    required String serviceId,
    required String date,
    required String timeSlot,
    String? notes,
  }) async {
    _isBooking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final appointment = await AppointmentService.createAppointment(
        serviceId: serviceId,
        date: date,
        timeSlot: timeSlot,
        notes: notes,
      );

      // Prepend to upcoming
      _upcomingAppointments.insert(0, appointment);
      _isBooking = false;
      notifyListeners();
      return appointment;
    } catch (e) {
      _errorMessage = e.toString();
      _isBooking = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Cancel an appointment
  Future<bool> cancelAppointment(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await AppointmentService.cancelAppointment(id);

      // Update in upcoming or move to previous
      _upcomingAppointments.removeWhere((a) => a.id == id);
      _previousAppointments.insert(0, updated);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
