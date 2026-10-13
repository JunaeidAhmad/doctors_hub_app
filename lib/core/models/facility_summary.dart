/// Shared facility shape used by chambers, hospitals, bookings and test
/// offerings. Parses both `FacilitySummary` (full) and `FacilityMini` (list)
/// payloads from v1: every field is optional except `id` and `displayName`.
class FacilitySummary {
  const FacilitySummary({
    required this.id,
    required this.displayName,
    this.slug,
    this.name,
    this.branch,
    this.address,
    this.area,
    this.areaBn,
    this.district,
    this.districtBn,
    this.division,
    this.divisionBn,
    this.thanaId,
    this.districtId,
    this.divisionId,
    this.phone,
    this.logo,
    this.image,
    this.locationType,
    this.ownershipType,
    this.rating,
    this.reviewsCount,
  });

  const FacilitySummary.empty()
      : id = '',
        displayName = '',
        slug = null,
        name = null,
        branch = null,
        address = null,
        area = null,
        areaBn = null,
        district = null,
        districtBn = null,
        division = null,
        divisionBn = null,
        thanaId = null,
        districtId = null,
        divisionId = null,
        phone = null,
        logo = null,
        image = null,
        locationType = null,
        ownershipType = null,
        rating = null,
        reviewsCount = null;

  final String id;
  final String displayName;
  final String? slug;
  final String? name;
  final String? branch;
  final String? address;
  final String? area;
  final String? areaBn;
  final String? district;
  final String? districtBn;
  final String? division;
  final String? divisionBn;
  final int? thanaId;
  final int? districtId;
  final int? divisionId;
  final String? phone;
  final String? logo;
  final String? image;
  final String? locationType;
  final String? ownershipType;
  final double? rating;
  final int? reviewsCount;

  bool get isHospital => locationType == 'hospital';

  String localizedArea(String locale) =>
      _localized(locale, area, areaBn);

  String localizedDistrict(String locale) =>
      _localized(locale, district, districtBn);

  String localizedDivision(String locale) =>
      _localized(locale, division, divisionBn);

  static String _localized(String locale, String? en, String? bn) {
    if (locale == 'bn' && bn != null && bn.isNotEmpty) return bn;
    return en ?? '';
  }

  factory FacilitySummary.fromJson(Map<String, dynamic> json) {
    String? str(String key) => json[key] is String ? json[key] as String : null;
    int? integer(String key) => (json[key] as num?)?.toInt();

    return FacilitySummary(
      id: str('id') ?? '',
      displayName: str('display_name') ?? str('name') ?? '',
      slug: str('slug'),
      name: str('name'),
      branch: str('branch'),
      address: str('address'),
      area: str('area'),
      areaBn: str('area_bn'),
      district: str('district'),
      districtBn: str('district_bn'),
      division: str('division'),
      divisionBn: str('division_bn'),
      thanaId: integer('thana_id'),
      districtId: integer('district_id'),
      divisionId: integer('division_id'),
      phone: str('phone'),
      logo: str('logo'),
      image: str('image'),
      locationType: str('location_type'),
      ownershipType: str('ownership_type'),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewsCount: integer('reviews_count'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'display_name': displayName,
        'slug': slug,
        'name': name,
        'branch': branch,
        'address': address,
        'area': area,
        'area_bn': areaBn,
        'district': district,
        'district_bn': districtBn,
        'division': division,
        'division_bn': divisionBn,
        'thana_id': thanaId,
        'district_id': districtId,
        'division_id': divisionId,
        'phone': phone,
        'logo': logo,
        'image': image,
        'location_type': locationType,
        'ownership_type': ownershipType,
        'rating': rating,
        'reviews_count': reviewsCount,
      };
}
