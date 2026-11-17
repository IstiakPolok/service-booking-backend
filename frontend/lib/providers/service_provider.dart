import 'package:flutter/foundation.dart';
import '../models/service_model.dart';
import '../services/service_service.dart';

class ServiceProvider extends ChangeNotifier {
  List<ServiceModel> _services = [];
  List<ServiceModel> _featuredServices = [];
  List<String> _categories = ['All'];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<ServiceModel> get services => _services;
  List<ServiceModel> get featuredServices => _featuredServices;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Filtered services according to active search query and category
  List<ServiceModel> get filteredServices {
    return _services.where((service) {
      final matchesCategory = _selectedCategory == 'All' ||
          service.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.category.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Initial load of services, featured items, and categories
  Future<void> fetchInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        ServiceService.getServices(),
        ServiceService.getFeaturedServices(),
        ServiceService.getCategories(),
      ]);

      _services = results[0] as List<ServiceModel>;
      _featuredServices = results[1] as List<ServiceModel>;
      _categories = results[2] as List<String>;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh services list
  Future<void> refresh() async {
    try {
      final results = await Future.wait([
        ServiceService.getServices(category: _selectedCategory == 'All' ? null : _selectedCategory),
        ServiceService.getFeaturedServices(),
      ]);

      _services = results[0];
      _featuredServices = results[1];
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Set Category filter
  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  /// Set Search Query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
