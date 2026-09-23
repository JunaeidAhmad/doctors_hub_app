class FacilityTest {
  const FacilityTest({
    required this.id,
    required this.testId,
    required this.testName,
    required this.facilityId,
    required this.facilityName,
    this.facilityBranch,
    this.facilityAddress,
    this.facilityDivision,
    this.facilityPhone,
    required this.price,
    this.discountPercent,
    this.reportTime,
    this.homeSampleCollection = false,
    this.homeSampleCharge = 0.0,
    this.homeSampleNote,
  });

  final String id;
  final String testId;
  final String testName;
  final String facilityId;
  final String facilityName;
  final String? facilityBranch;
  final String? facilityAddress;
  final String? facilityDivision;
  final String? facilityPhone;
  final double price;
  final double? discountPercent;
  final String? reportTime;
  final bool homeSampleCollection;
  final double homeSampleCharge;
  final String? homeSampleNote;

  String get fullFacilityDisplayName {
    if (facilityBranch != null && facilityBranch!.isNotEmpty) {
      return '$facilityName, $facilityBranch';
    }
    return facilityName;
  }

  factory FacilityTest.fromJson(Map<String, dynamic> json) {
    final facility = json['facility'] as Map<String, dynamic>?;
    final locationDetails = json['location_details'] as Map<String, dynamic>? ??
        facility?['location_details'] as Map<String, dynamic>?;

    final testObj = json['test'] as Map<String, dynamic>?;

    double price = 0.0;
    if (json['price'] != null) {
      price = double.tryParse(json['price'].toString()) ?? 0.0;
    }

    double homeCharge = 0.0;
    if (json['home_sample_charge'] != null) {
      homeCharge = double.tryParse(json['home_sample_charge'].toString()) ?? 0.0;
    }

    return FacilityTest(
      id: json['id']?.toString() ?? '',
      testId: json['test_id']?.toString() ?? testObj?['id']?.toString() ?? '',
      testName: json['test_name'] as String? ?? testObj?['name'] as String? ?? 'Lab Test',
      facilityId: json['facility_id']?.toString() ?? facility?['id']?.toString() ?? '',
      facilityName: json['facility_name'] as String? ?? facility?['name'] as String? ?? locationDetails?['name'] as String? ?? 'Diagnostic Lab',
      facilityBranch: json['facility_branch'] as String? ?? facility?['branch'] as String? ?? locationDetails?['branch'] as String?,
      facilityAddress: json['facility_address'] as String? ?? facility?['address_line'] as String? ?? locationDetails?['address_line'] as String?,
      facilityDivision: json['facility_division'] as String? ?? facility?['division'] as String? ?? locationDetails?['division'] as String?,
      facilityPhone: json['facility_phone'] as String? ?? facility?['phone'] as String? ?? locationDetails?['phone'] as String?,
      price: price,
      discountPercent: (json['discount_percent'] as num?)?.toDouble(),
      reportTime: json['report_time'] as String?,
      homeSampleCollection: json['home_sample_collection'] == true,
      homeSampleCharge: homeCharge,
      homeSampleNote: json['home_sample_note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'test_id': testId,
    'test_name': testName,
    'facility_id': facilityId,
    'facility_name': facilityName,
    'facility_branch': facilityBranch,
    'facility_address': facilityAddress,
    'facility_division': facilityDivision,
    'facility_phone': facilityPhone,
    'price': price,
    'discount_percent': discountPercent,
    'report_time': reportTime,
    'home_sample_collection': homeSampleCollection,
    'home_sample_charge': homeSampleCharge,
    'home_sample_note': homeSampleNote,
  };
}
