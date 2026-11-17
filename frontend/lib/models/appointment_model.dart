import 'service_model.dart';
import 'user_model.dart';

class AppointmentModel {
  final String id;
  final ServiceModel? service;
  final UserModel? user;
  final String date;
  final String timeSlot;
  final String status; // PENDING, CONFIRMED, CANCELLED, COMPLETED
  final String? notes;
  final double totalAmount;
  final DateTime? createdAt;

  AppointmentModel({
    required this.id,
    this.service,
    this.user,
    required this.date,
    required this.timeSlot,
    required this.status,
    this.notes,
    required this.totalAmount,
    this.createdAt,
  });

  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isConfirmed => status.toUpperCase() == 'CONFIRMED';
  bool get isCancelled => status.toUpperCase() == 'CANCELLED';
  bool get isCompleted => status.toUpperCase() == 'COMPLETED';

  bool get canBeCancelled => isPending || isConfirmed;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    ServiceModel? serviceObj;
    if (json['service'] is Map<String, dynamic>) {
      serviceObj = ServiceModel.fromJson(json['service']);
    }

    UserModel? userObj;
    if (json['user'] is Map<String, dynamic>) {
      userObj = UserModel.fromJson(json['user']);
    }

    return AppointmentModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      service: serviceObj,
      user: userObj,
      date: json['date']?.toString() ?? '',
      timeSlot: json['timeSlot']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      notes: json['notes']?.toString(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service?.toJson(),
      'user': user?.toJson(),
      'date': date,
      'timeSlot': timeSlot,
      'status': status,
      'notes': notes,
      'totalAmount': totalAmount,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  AppointmentModel copyWith({
    String? status,
  }) {
    return AppointmentModel(
      id: id,
      service: service,
      user: user,
      date: date,
      timeSlot: timeSlot,
      status: status ?? this.status,
      notes: notes,
      totalAmount: totalAmount,
      createdAt: createdAt,
    );
  }
}
