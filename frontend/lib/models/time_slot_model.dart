class TimeSlotModel {
  final String timeSlot;
  final bool isAvailable;

  TimeSlotModel({
    required this.timeSlot,
    required this.isAvailable,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      timeSlot: json['timeSlot']?.toString() ?? '',
      isAvailable: json['isAvailable'] == true,
    );
  }
}
