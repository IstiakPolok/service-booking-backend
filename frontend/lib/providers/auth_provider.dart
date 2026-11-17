import 'package:flutter/foundation.dart';
import '../core/storage/token_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;

  /// Check persisted session on app launch
  Future<void> initialize() async {
    _isInitializing = true;
    notifyListeners();

    try {
      final token = await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        // First set cached user for instant rendering
        final cachedUserMap = await TokenStorage.getUser();
        if (cachedUserMap != null) {
          _currentUser = UserModel.fromJson(cachedUserMap);
          _isAuthenticated = true;
        }

        // Fetch fresh profile from API
        try {
          final freshUser = await AuthService.getMe();
          _currentUser = freshUser;
          _isAuthenticated = true;
        } catch (_) {
          // If token expired, clear auth
          if (_currentUser == null) {
            await TokenStorage.clearAuth();
            _isAuthenticated = false;
          }
        }
      } else {
        _isAuthenticated = false;
        _currentUser = null;
      }
    } catch (_) {
      _isAuthenticated = false;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Log In
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await AuthService.login(email: email, password: password);
      _currentUser = user;
      _isAuthenticated = true;
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

  /// Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await AuthService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      _currentUser = user;
      _isAuthenticated = true;
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

  /// Update Profile
  Future<bool> updateProfile({String? name, String? phone, String? avatar}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await AuthService.updateProfile(
        name: name,
        phone: phone,
        avatar: avatar,
      );
      _currentUser = updated;
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

  /// Change Password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
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

  /// Logout
  Future<void> logout() async {
    await AuthService.logout();
    _currentUser = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
