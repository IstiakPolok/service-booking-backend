class ApiEndpoints {
  // Live Cloud Production URL (Render)
  static const String liveCloudUrl = 'https://service-booking-backend-82zz.onrender.com/api';

  // Local PC Wi-Fi IP
  static const String pcWifiIp = '192.168.0.102';

  // Default host determination - points directly to the live Render backend!
  static String get defaultBaseUrl => liveCloudUrl;

  // Active base URL (can be customized via in-app settings at runtime)
  static String baseUrl = defaultBaseUrl;

  // Preset quick endpoints for easy switching in settings
  static const String urlRender = liveCloudUrl;
  static const String urlWifi = 'http://$pcWifiIp:5000/api';
  static const String urlUsbAdb = 'http://localhost:5000/api';
  static const String urlEmulator = 'http://10.0.2.2:5000/api';

  // Auth Routes
  static String get register => '$baseUrl/auth/register';
  static String get login => '$baseUrl/auth/login';
  static String get me => '$baseUrl/auth/me';
  static String get changePassword => '$baseUrl/auth/change-password';

  // User Routes
  static String get profile => '$baseUrl/users/profile';
  static String get uploadAvatar => '$baseUrl/users/avatar';

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
