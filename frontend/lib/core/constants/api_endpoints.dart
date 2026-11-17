import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Default host determination
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    try {
      if (Platform.isAndroid) {
        // Android Emulator accesses host loopback via 10.0.2.2
        return 'http://10.0.2.2:5000/api';
      }
    } catch (_) {
      // In case platform is not supported or web
    }
    return 'http://localhost:5000/api';
  }

  // Active base URL (can be customized via settings at runtime)
  static String baseUrl = defaultBaseUrl;

  // Auth Routes
  static String get register => '$baseUrl/auth/register';
  static String get login => '$baseUrl/auth/login';
  static String get me => '$baseUrl/auth/me';
  static String get changePassword => '$baseUrl/auth/change-password';

  // User Routes
  static String get profile => '$baseUrl/users/profile';

  // Services Routes
  static String get services => '$baseUrl/services';
  static String get featuredServices => '$baseUrl/services/featured';
  static String get categories => '$baseUrl/services/categories';
  static String serviceById(String id) => '$baseUrl/services/$id';

  // Appointments Routes
  static String get appointments => '$baseUrl/appointments';
  static String get availableSlots => '$baseUrl/appointments/available-slots';
  static String appointmentById(String id) => '$baseUrl/appointments/$id';
  static String cancelAppointment(String id) => '$baseUrl/appointments/$id/cancel';

  // AI Assistant Routes
  static String get aiChat => '$baseUrl/ai/chat';
  static String get aiRecommend => '$baseUrl/ai/recommend';

  // Health
  static String get health => '$baseUrl/health';
}
