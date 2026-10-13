import '../../../../core/models/facility_summary.dart';

class HospitalCategoryRef {
  const HospitalCategoryRef({this.id, this.slug, this.name});

  final String? id;
  final String? slug;
  final String? name;

  factory HospitalCategoryRef.fromJson(Map<String, dynamic> json) {
    return HospitalCategoryRef(
      id: json['id']?.toString(),
      slug: json['slug'] as String?,
      name: json['name'] as String?,
    );
  }
}

class HospitalServiceRef {
  const HospitalServiceRef({required this.id, required this.name, this.icon});

  final String id;
  final String name;
  final String? icon;

  factory HospitalServiceRef.fromJson(Map<String, dynamic> json) {
    return HospitalServiceRef(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String?,
    );
  }
}

/// A hospital or diagnostic centre from `GET /hospitals/` /
/// `GET /hospitals/{location}/`. The v1 serializers spread the flat facility
/// summary into the top level (gap G1), so this parses the real payload.
class Hospital {
  const Hospital({
    required this.id,
    required this.displayName,
    this.slug,
    this.name = '',
    this.branch,
    this.category,
    this.address,
    this.area,
    this.areaBn,
    this.district,
    this.districtBn,
    this.division,
    this.divisionBn,
    this.phone,
    this.doctorCount,
    this.testCount,
    this.rating,
    this.reviewsCount,
    this.ownershipType,
    this.locationType,
    this.emergencyPhone,
    this.ambulancePhone,
    this.openTiming,
    this.description,
    this.services = const [],
    this.logo,
    this.image,
  });

  final String id;
  final String displayName;
  final String? slug;
  final String name;
  final String? branch;
  final String? category;
  final String? address;
  final String? area;
  final String? areaBn;
  final String? district;
  final String? districtBn;
  final String? division;
  final String? divisionBn;
  final String? phone;
  final int? doctorCount;
  final int? testCount;
  final double? rating;
  final int? reviewsCount;
  final String? ownershipType;
  final String? locationType;
  final String? emergencyPhone;
  final String? ambulancePhone;
  final String? openTiming;
  final String? description;
  final List<HospitalServiceRef> services;
  final String? logo;
  final String? image;

  String localizedName(String locale) => displayName;

  String localizedArea(String locale) {
    if (locale == 'bn' && areaBn != null && areaBn!.isNotEmpty) return areaBn!;
    return area ?? '';
  }

  String localizedDistrict(String locale) {
    if (locale == 'bn' && districtBn != null && districtBn!.isNotEmpty) {
      return districtBn!;
    }
    return district ?? '';
  }

  String get initials {
    final source = displayName.trim();
    final parts = source.split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'H';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String get fullDisplayName => displayName;

  FacilitySummary get facility => FacilitySummary(
        id: id,
        displayName: displayName,
        slug: slug,
        name: name,
        branch: branch,
        address: address,
        area: area,
        areaBn: areaBn,
        district: district,
        districtBn: districtBn,
        division: division,
        divisionBn: divisionBn,
        phone: phone,
        logo: logo,
        image: image,
        locationType: locationType,
        ownershipType: ownershipType,
        rating: rating,
        reviewsCount: reviewsCount,
      );

  factory Hospital.fromJson(Map<String, dynamic> json) {
    String? str(String key) => json[key] is String ? json[key] as String : null;
    int? integer(String key) => (json[key] as num?)?.toInt();

    String? categoryName;
    final categoryRaw = json['category'];
    if (categoryRaw is Map) {
      categoryName = categoryRaw['name'] is String
          ? categoryRaw['name'] as String
          : categoryRaw['slug'] is String
              ? categoryRaw['slug'] as String
              : null;
    }

    final services = <HospitalServiceRef>[];
    final servicesRaw = json['services'];
    if (servicesRaw is List) {
      for (final item in servicesRaw) {
        if (item is Map) {
          services.add(
            HospitalServiceRef.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final displayName = str('display_name') ?? str('name') ?? '';

    return Hospital(
      id: str('id') ?? '',
      displayName: displayName,
      slug: str('slug'),
      name: str('name') ?? displayName,
      branch: str('branch'),
      category: categoryName,
      address: str('address'),
      area: str('area'),
      areaBn: str('area_bn'),
      district: str('district'),
      districtBn: str('district_bn'),
      division: str('division'),
      divisionBn: str('division_bn'),
      phone: str('phone'),
      doctorCount: integer('doctor_count'),
      testCount: integer('test_count'),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewsCount: integer('reviews_count'),
      ownershipType: str('ownership_type'),
      locationType: str('location_type'),
      emergencyPhone: str('emergency_phone'),
      ambulancePhone: str('ambulance_phone'),
      openTiming: str('open_timing'),
      description: str('description'),
      services: services,
      logo: str('logo'),
      image: str('image'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'display_name': displayName,
        'slug': slug,
        'name': name,
        'branch': branch,
        'category': category == null ? null : {'name': category},
        'address': address,
        'area': area,
        'area_bn': areaBn,
        'district': district,
        'district_bn': districtBn,
        'division': division,
        'division_bn': divisionBn,
        'phone': phone,
        'doctor_count': doctorCount,
        'test_count': testCount,
        'rating': rating,
        'reviews_count': reviewsCount,
        'ownership_type': ownershipType,
        'location_type': locationType,
        'emergency_phone': emergencyPhone,
        'ambulance_phone': ambulancePhone,
        'open_timing': openTiming,
        'description': description,
        'services': services
            .map((s) => {'id': s.id, 'name': s.name, 'icon': s.icon})
            .toList(),
        'logo': logo,
        'image': image,
      };
}
