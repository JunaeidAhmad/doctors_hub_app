import '../../../../core/models/facility_summary.dart';

/// A test returned by `GET /facility-tests/search/`, with the labs offering
/// it nested under `offerings`.
class TestSearchGroup {
  const TestSearchGroup({
    required this.id,
    required this.name,
    this.slug,
    this.code,
    this.categoryId,
    this.categoryName,
    this.categorySlug,
    this.description,
    this.fastingRequired = false,
    this.preparationInstructions,
    this.sampleType,
    this.reportTimeHours,
    this.minPrice,
    this.maxPrice,
    this.offeringCount = 0,
    this.pricedOfferingCount = 0,
    this.homeCollectionCount = 0,
    this.locationCount = 0,
    this.offerings = const [],
  });

  final String id;
  final String name;
  final String? slug;
  final String? code;
  final String? categoryId;
  final String? categoryName;
  final String? categorySlug;
  final String? description;
  final bool fastingRequired;
  final String? preparationInstructions;
  final String? sampleType;
  final int? reportTimeHours;
  final double? minPrice;
  final double? maxPrice;
  final int offeringCount;
  final int pricedOfferingCount;
  final int homeCollectionCount;
  final int locationCount;
  final List<LabOffering> offerings;

  bool get hasPriceRange => minPrice != null || maxPrice != null;

  bool get hasHomeCollection => homeCollectionCount > 0;

  factory TestSearchGroup.fromJson(Map<String, dynamic> json) {
    final offerings = <LabOffering>[];
    final offeringsRaw = json['offerings'];
    if (offeringsRaw is List) {
      for (final item in offeringsRaw) {
        if (item is Map) {
          offerings.add(LabOffering.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    double? decimal(dynamic value) =>
        value == null ? null : double.tryParse(value.toString());

    return TestSearchGroup(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      code: json['code'] as String?,
      categoryId: json['category_id']?.toString(),
      categoryName: json['category_name'] as String?,
      categorySlug: json['category_slug'] as String?,
      description: json['description'] as String?,
      fastingRequired: json['fasting_required'] == true,
      preparationInstructions: json['preparation_instructions'] as String?,
      sampleType: json['sample_type'] as String?,
      reportTimeHours: (json['report_time_hours'] as num?)?.toInt(),
      minPrice: decimal(json['min_price']),
      maxPrice: decimal(json['max_price']),
      offeringCount: (json['offering_count'] as num?)?.toInt() ?? 0,
      pricedOfferingCount: (json['priced_offering_count'] as num?)?.toInt() ?? 0,
      homeCollectionCount: (json['home_collection_count'] as num?)?.toInt() ?? 0,
      locationCount: (json['location_count'] as num?)?.toInt() ?? 0,
      offerings: offerings,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'code': code,
        'category_id': categoryId,
        'category_name': categoryName,
        'category_slug': categorySlug,
        'description': description,
        'fasting_required': fastingRequired,
        'preparation_instructions': preparationInstructions,
        'sample_type': sampleType,
        'report_time_hours': reportTimeHours,
        'min_price': minPrice,
        'max_price': maxPrice,
        'offering_count': offeringCount,
        'priced_offering_count': pricedOfferingCount,
        'home_collection_count': homeCollectionCount,
        'location_count': locationCount,
        'offerings': offerings.map((o) => o.toJson()).toList(),
      };
}

/// One lab's offering of a test (`offerings[]` in the search response).
class LabOffering {
  const LabOffering({
    required this.id,
    required this.facility,
    this.price,
    this.calculatedPrice,
    this.discountPercent,
    this.homeSampleCollection = false,
    this.homeSampleCharge,
    this.homeSampleNote,
    this.reportTimeHours,
    this.isAvailable = true,
  });

  final String id;
  final FacilitySummary facility;
  final double? price;
  final double? calculatedPrice;
  final double? discountPercent;
  final bool homeSampleCollection;
  final double? homeSampleCharge;
  final String? homeSampleNote;
  final int? reportTimeHours;
  final bool isAvailable;

  /// Shown price rule: `calculated_price`, else `price`, else null.
  double? get shownPrice => calculatedPrice ?? price;

  /// Both prices null means "price at counter" (no ৳0).
  bool get priceAtCounter => calculatedPrice == null && price == null;

  /// Offering hours, else the test's hours, else nothing.
  int? effectiveReportTimeHours(int? testReportTimeHours) =>
      reportTimeHours ?? testReportTimeHours;

  factory LabOffering.fromJson(Map<String, dynamic> json) {
    double? decimal(dynamic value) =>
        value == null ? null : double.tryParse(value.toString());

    final facilityRaw = json['facility'];

    return LabOffering(
      id: json['id']?.toString() ?? '',
      facility: facilityRaw is Map
          ? FacilitySummary.fromJson(Map<String, dynamic>.from(facilityRaw))
          : const FacilitySummary.empty(),
      price: decimal(json['price']),
      calculatedPrice: decimal(json['calculated_price']),
      discountPercent: decimal(json['discount_percent']),
      homeSampleCollection: json['home_sample_collection'] == true,
      homeSampleCharge: decimal(json['home_sample_charge']),
      homeSampleNote: json['home_sample_note'] as String?,
      reportTimeHours: (json['report_time_hours'] as num?)?.toInt(),
      isAvailable: json['is_available'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'facility': facility.toJson(),
        'price': price,
        'calculated_price': calculatedPrice,
        'discount_percent': discountPercent,
        'home_sample_collection': homeSampleCollection,
        'home_sample_charge': homeSampleCharge,
        'home_sample_note': homeSampleNote,
        'report_time_hours': reportTimeHours,
        'is_available': isAvailable,
      };
}

/// Facet counts from the tests search response.
class TestSearchFacets {
  const TestSearchFacets({
    this.fulfillmentHome = 0,
    this.fulfillmentCenter = 0,
    this.ownershipPrivate = 0,
    this.ownershipGovernment = 0,
    this.ownershipHospitalAffiliated = 0,
    this.ownershipNgo = 0,
  });

  final int fulfillmentHome;
  final int fulfillmentCenter;
  final int ownershipPrivate;
  final int ownershipGovernment;
  final int ownershipHospitalAffiliated;
  final int ownershipNgo;

  factory TestSearchFacets.fromJson(Map<String, dynamic>? json) {
    int count(Map<String, dynamic>? map, String key) =>
        (map?[key] as num?)?.toInt() ?? 0;
    final fulfillment = json?['fulfillment'] is Map
        ? Map<String, dynamic>.from(json!['fulfillment'] as Map)
        : null;
    final ownership = json?['ownership'] is Map
        ? Map<String, dynamic>.from(json!['ownership'] as Map)
        : null;
    return TestSearchFacets(
      fulfillmentHome: count(fulfillment, 'home'),
      fulfillmentCenter: count(fulfillment, 'center'),
      ownershipPrivate: count(ownership, 'private'),
      ownershipGovernment: count(ownership, 'government'),
      ownershipHospitalAffiliated: count(ownership, 'hospital_affiliated'),
      ownershipNgo: count(ownership, 'ngo'),
    );
  }
}
