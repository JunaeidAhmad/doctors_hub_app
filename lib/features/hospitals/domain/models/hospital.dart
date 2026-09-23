class Hospital {
  const Hospital({
    required this.id,
    required this.name,
    this.bnName,
    required this.slug,
    this.category,
    this.branch,
    this.addressLine,
    this.area,
    this.district,
    this.division,
    this.phone,
    this.doctorCount,
    this.rating,
    this.reviewsCount,
  });

  final String id;
  final String name;
  final String? bnName;
  final String slug;
  final String? category;
  final String? branch;
  final String? addressLine;
  final String? area;
  final String? district;
  final String? division;
  final String? phone;
  final int? doctorCount;
  final double? rating;
  final int? reviewsCount;

  String localizedName(String locale) {
    if (locale == 'bn' && bnName != null && bnName!.isNotEmpty) {
      return bnName!;
    }
    return name;
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'H';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String get fullDisplayName {
    if (branch != null && branch!.isNotEmpty) {
      return '$name, $branch';
    }
    return name;
  }

  factory Hospital.fromJson(Map<String, dynamic> json) {
    // Port flattenFacility logic: attributes might be top-level or under location_details
    final loc = json['location_details'] as Map<String, dynamic>?;

    final name = json['name'] as String? ?? loc?['name'] as String? ?? '';
    final bnName = json['bn_name'] as String? ?? loc?['bn_name'] as String?;
    final slug = json['slug'] as String? ?? loc?['slug'] as String? ?? '';
    final branch = json['branch'] as String? ?? loc?['branch'] as String?;
    final addressLine = json['address_line'] as String? ?? loc?['address_line'] as String?;
    final area = json['area'] as String? ?? loc?['area'] as String?;
    final district = json['district'] as String? ?? loc?['district'] as String?;
    final division = json['division'] as String? ?? loc?['division'] as String?;
    final phone = json['phone'] as String? ?? loc?['phone'] as String?;
    final category = json['category'] as String? ?? json['location_type'] as String? ?? loc?['location_type'] as String?;

    return Hospital(
      id: json['id']?.toString() ?? loc?['id']?.toString() ?? '',
      name: name,
      bnName: bnName,
      slug: slug,
      category: category,
      branch: branch,
      addressLine: addressLine,
      area: area,
      district: district,
      division: division,
      phone: phone,
      doctorCount: (json['doctor_count'] as num?)?.toInt() ?? (json['doctors_count'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toDouble() ?? (loc?['rating'] as num?)?.toDouble(),
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? (loc?['reviews_count'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bn_name': bnName,
    'slug': slug,
    'category': category,
    'branch': branch,
    'address_line': addressLine,
    'area': area,
    'district': district,
    'division': division,
    'phone': phone,
    'doctor_count': doctorCount,
    'rating': rating,
    'reviews_count': reviewsCount,
  };
}
