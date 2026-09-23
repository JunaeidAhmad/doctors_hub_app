class DoctorSchedule {
  const DoctorSchedule({
    this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  final String? id;
  final String dayOfWeek; // e.g. "Saturday", "Sunday"
  final String startTime; // e.g. "18:00:00"
  final String endTime; // e.g. "21:00:00"

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) {
    return DoctorSchedule(
      id: json['id']?.toString(),
      dayOfWeek: json['day_of_week'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'day_of_week': dayOfWeek,
    'start_time': startTime,
    'end_time': endTime,
  };
}
