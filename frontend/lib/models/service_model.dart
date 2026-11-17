class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int duration; // in minutes
  final String image;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final bool isAvailable;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.image,
    required this.category,
    this.rating = 4.8,
    this.reviewCount = 20,
    this.isFeatured = false,
    this.isAvailable = true,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      duration: (json['duration'] as num?)?.toInt() ?? 60,
      image: json['image']?.toString() ??
          'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=800&q=80',
      category: json['category']?.toString() ?? 'General',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 25,
      isFeatured: json['isFeatured'] == true,
      isAvailable: json['isAvailable'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'image': image,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'isAvailable': isAvailable,
    };
  }
}
