import 'schedule.dart';

class DoctorAffiliation {
  const DoctorAffiliation({
    required this.id,
    required this.facilityName,
    this.branch,
    this.addressLine,
    this.area,
    this.district,
    this.division,
    required this.fee,
    this.chamberType,
    this.statusLabel,
    this.phone,
    this.schedules = const [],
  });

  final String id;
  final String facilityName;
  final String? branch;
  final String? addressLine;
  final String? area;
  final String? district;
  final String? division;
  final double fee;
  final String? chamberType;
  final String? statusLabel;
  final String? phone;
  final List<DoctorSchedule> schedules;

  String get fullDisplayName {
    if (branch != null && branch!.isNotEmpty) {
      return '$facilityName, $branch';
    }
    return facilityName;
  }

  factory DoctorAffiliation.fromJson(Map<String, dynamic> json) {
    final locationDetails = json['location_details'] as Map<String, dynamic>?;

    String? phone = locationDetails?['phone'] as String?;
    String? address = locationDetails?['address_line'] as String? ?? json['address_line'] as String?;
    String? branch = json['branch'] as String? ?? locationDetails?['branch'] as String?;
    String? area = json['area'] as String? ?? locationDetails?['area'] as String?;
    String? district = json['district'] as String? ?? locationDetails?['district'] as String?;
    String? division = json['division'] as String? ?? locationDetails?['division'] as String?;

    final schedulesRaw = json['schedules'] as List<dynamic>? ?? [];
    final schedules = schedulesRaw
        .map((s) => DoctorSchedule.fromJson(s as Map<String, dynamic>))
        .toList();

    double fee = 0.0;
    if (json['fee'] != null) {
      fee = double.tryParse(json['fee'].toString()) ?? 0.0;
    }

    return DoctorAffiliation(
      id: json['id']?.toString() ?? '',
      facilityName: json['facility_name'] as String? ?? locationDetails?['name'] as String? ?? 'Chamber',
      branch: branch,
      addressLine: address,
      area: area,
      district: district,
      division: division,
      fee: fee,
      chamberType: json['chamber_type'] as String?,
      statusLabel: json['status_label'] as String?,
      phone: phone,
      schedules: schedules,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'facility_name': facilityName,
    'branch': branch,
    'address_line': addressLine,
    'area': area,
    'district': district,
    'division': division,
    'fee': fee,
    'chamber_type': chamberType,
    'status_label': statusLabel,
    'phone': phone,
    'schedules': schedules.map((s) => s.toJson()).toList(),
  };
}
