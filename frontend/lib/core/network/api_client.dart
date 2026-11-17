import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  static const Duration _timeoutDuration = Duration(seconds: 15);

  static Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Process HTTP response and return parsed JSON data
  static dynamic _processResponse(http.Response response) {
    dynamic jsonBody;
    try {
      jsonBody = jsonDecode(response.body);
    } catch (_) {
      jsonBody = null;
    }

    final statusCode = response.statusCode;
    final message = jsonBody is Map && jsonBody.containsKey('message')
        ? jsonBody['message'].toString()
        : 'Request failed with status $statusCode';

    if (statusCode >= 200 && statusCode < 300) {
      return jsonBody;
    }

    if (statusCode == 401) {
      throw UnauthorizedException(message);
    }

    if (statusCode == 409) {
      throw ConflictException(message);
    }

    if (statusCode == 400) {
      throw ValidationException(message, errors: jsonBody is Map ? jsonBody['errors'] : null);
    }

    throw ApiException(message, statusCode: statusCode, errors: jsonBody is Map ? jsonBody['errors'] : null);
  }

  /// GET Request
  static Future<dynamic> get(String url, {bool requiresAuth = true, Map<String, dynamic>? queryParams}) async {
    try {
      var uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        final stringParams = queryParams.map((key, value) => MapEntry(key, value.toString()));
        uri = uri.replace(queryParameters: stringParams);
      }

      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http.get(uri, headers: headers).timeout(_timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  /// POST Request
  static Future<dynamic> post(String url, {dynamic body, bool requiresAuth = true}) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final encodedBody = body != null ? jsonEncode(body) : null;

      final response = await http.post(uri, headers: headers, body: encodedBody).timeout(_timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  /// PUT Request
  static Future<dynamic> put(String url, {dynamic body, bool requiresAuth = true}) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final encodedBody = body != null ? jsonEncode(body) : null;

      final response = await http.put(uri, headers: headers, body: encodedBody).timeout(_timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  /// PATCH Request
  static Future<dynamic> patch(String url, {dynamic body, bool requiresAuth = true}) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final encodedBody = body != null ? jsonEncode(body) : null;

      final response = await http.patch(uri, headers: headers, body: encodedBody).timeout(_timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }
}
