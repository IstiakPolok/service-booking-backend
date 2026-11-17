import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/appointment_model.dart';
import '../models/time_slot_model.dart';

class AppointmentService {
  /// Check time slot availability for a service on a given date
  static Future<List<TimeSlotModel>> getAvailableSlots({
    required String serviceId,
    required String date,
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.availableSlots,
      requiresAuth: false,
      queryParams: {
        'serviceId': serviceId,
        'date': date,
      },
    );

    final data = response['data'] as Map<String, dynamic>;
    final slotsList = data['slots'] as List<dynamic>? ?? [];
    return slotsList.map((s) => TimeSlotModel.fromJson(s as Map<String, dynamic>)).toList();
  }

  /// Create a new appointment booking
  static Future<AppointmentModel> createAppointment({
    required String serviceId,
    required String date,
    required String timeSlot,
    String? notes,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.appointments,
      body: {
        'serviceId': serviceId,
        'date': date,
        'timeSlot': timeSlot,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );

    return AppointmentModel.fromJson(response['data']);
  }

  /// Get user appointments (upcoming or previous)
  static Future<List<AppointmentModel>> getUserAppointments({
    String filter = 'upcoming',
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.appointments,
      queryParams: {
        'filter': filter,
        'limit': 50,
      },
    );

    final rawList = response['data'] as List<dynamic>? ?? [];
    return rawList.map((item) => AppointmentModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Get individual appointment details
  static Future<AppointmentModel> getAppointmentById(String id) async {
    final response = await ApiClient.get(ApiEndpoints.appointmentById(id));
    return AppointmentModel.fromJson(response['data']);
  }

  /// Cancel an appointment
  static Future<AppointmentModel> cancelAppointment(String id) async {
    final response = await ApiClient.patch(ApiEndpoints.cancelAppointment(id));
    return AppointmentModel.fromJson(response['data']);
  }
}
