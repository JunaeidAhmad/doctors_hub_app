import 'facility_test.dart';

class DiagnosticTest {
  const DiagnosticTest({
    required this.id,
    required this.name,
    this.bnName,
    required this.slug,
    this.categoryName,
    this.categoryId,
    this.description,
    this.fastingRequired = false,
    this.reportTimeHours,
    this.preparationInstructions,
    this.facilityTests = const [],
    this.minPrice,
    this.maxPrice,
  });

  final String id;
  final String name;
  final String? bnName;
  final String slug;
  final String? categoryName;
  final String? categoryId;
  final String? description;
  final bool fastingRequired;
  final int? reportTimeHours;
  final String? preparationInstructions;
  final List<FacilityTest> facilityTests;
  final double? minPrice;
  final double? maxPrice;

  String localizedName(String locale) {
    if (locale == 'bn' && bnName != null && bnName!.isNotEmpty) {
      return bnName!;
    }
    return name;
  }

  factory DiagnosticTest.fromJson(Map<String, dynamic> json) {
    final facilityTestsRaw = json['facility_tests'] as List<dynamic>? ?? [];
    final facilityTests = facilityTestsRaw
        .map((f) => FacilityTest.fromJson(f as Map<String, dynamic>))
        .toList();

    double? minPrice = (json['min_price'] as num?)?.toDouble();
    double? maxPrice = (json['max_price'] as num?)?.toDouble();

    if (minPrice == null && facilityTests.isNotEmpty) {
      for (final ft in facilityTests) {
        if (minPrice == null || ft.price < minPrice) minPrice = ft.price;
        if (maxPrice == null || ft.price > maxPrice) maxPrice = ft.price;
      }
    }

    return DiagnosticTest(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      bnName: json['bn_name'] as String?,
      slug: json['slug'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? json['category']?['name'] as String?,
      categoryId: json['category']?['id']?.toString() ?? json['category_id']?.toString(),
      description: json['description'] as String?,
      fastingRequired: json['fasting_required'] == true,
      reportTimeHours: (json['report_time_hours'] as num?)?.toInt(),
      preparationInstructions: json['preparation_instructions'] as String?,
      facilityTests: facilityTests,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bn_name': bnName,
    'slug': slug,
    'category_name': categoryName,
    'category_id': categoryId,
    'description': description,
    'fasting_required': fastingRequired,
    'report_time_hours': reportTimeHours,
    'preparation_instructions': preparationInstructions,
    'facility_tests': facilityTests.map((f) => f.toJson()).toList(),
    'min_price': minPrice,
    'max_price': maxPrice,
  };
}
