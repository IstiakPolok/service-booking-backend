import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthService {
  /// Register a new account
  static Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.register,
      requiresAuth: false,
      body: {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );

    final data = response['data'];
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user']);

    await TokenStorage.saveToken(token);
    await TokenStorage.saveUser(user.toJson());

    return user;
  }

  /// Log in with email and password
  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.login,
      requiresAuth: false,
      body: {
        'email': email,
        'password': password,
      },
    );

    final data = response['data'];
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user']);

    await TokenStorage.saveToken(token);
    await TokenStorage.saveUser(user.toJson());

    return user;
  }

  /// Fetch currently authenticated user
  static Future<UserModel> getMe() async {
    final response = await ApiClient.get(ApiEndpoints.me);
    final user = UserModel.fromJson(response['data']);
    await TokenStorage.saveUser(user.toJson());
    return user;
  }

  /// Update user profile
  static Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? avatar,
  }) async {
    final response = await ApiClient.put(
      ApiEndpoints.profile,
      body: {
        'name': ?name,
        'phone': ?phone,
        'avatar': ?avatar,
      },
    );

    final user = UserModel.fromJson(response['data']);
    await TokenStorage.saveUser(user.toJson());
    return user;
  }

  /// Change user password
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await ApiClient.put(
      ApiEndpoints.changePassword,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  /// Logout
  static Future<void> logout() async {
    try {
      await ApiClient.post('${ApiEndpoints.baseUrl}/auth/logout', requiresAuth: false);
    } catch (_) {}
    await TokenStorage.clearAuth();
  }
}
