import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/service_model.dart';

class ServiceService {
  /// Fetch all services with optional search, category, and sorting
  static Future<List<ServiceModel>> getServices({
    String? search,
    String? category,
    bool? featured,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? order,
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (category != null && category != 'All') 'category': category,
      if (featured != null) 'featured': featured.toString(),
      'minPrice': ?minPrice?.toString(),
      'maxPrice': ?maxPrice?.toString(),
      'sortBy': ?sortBy,
      'order': ?order,
    };

    final response = await ApiClient.get(
      ApiEndpoints.services,
      requiresAuth: false,
      queryParams: queryParams,
    );

    final rawList = response['data'] as List<dynamic>? ?? [];
    return rawList.map((item) => ServiceModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Fetch featured services for home screen carousel
  static Future<List<ServiceModel>> getFeaturedServices() async {
    final response = await ApiClient.get(
      ApiEndpoints.featuredServices,
      requiresAuth: false,
    );

    final rawList = response['data'] as List<dynamic>? ?? [];
    return rawList.map((item) => ServiceModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Fetch list of categories
  static Future<List<String>> getCategories() async {
    final response = await ApiClient.get(
      ApiEndpoints.categories,
      requiresAuth: false,
    );

    final rawList = response['data'] as List<dynamic>? ?? [];
    final categories = <String>['All'];
    for (final item in rawList) {
      if (item is Map && item['name'] != null) {
        categories.add(item['name'].toString());
      }
    }
    return categories;
  }

  /// Fetch single service by ID
  static Future<ServiceModel> getServiceById(String id) async {
    final response = await ApiClient.get(
      ApiEndpoints.serviceById(id),
      requiresAuth: false,
    );

    return ServiceModel.fromJson(response['data']);
  }
}
