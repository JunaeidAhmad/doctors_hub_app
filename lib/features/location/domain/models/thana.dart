class Thana {
  const Thana({
    required this.id,
    this.districtId,
    this.districtName,
    this.districtBnName,
    this.divisionId,
    this.divisionName,
    this.divisionBnName,
    required this.name,
    this.bnName,
    required this.slug,
  });

  final int id;
  final int? districtId;
  final String? districtName;
  final String? districtBnName;
  final int? divisionId;
  final String? divisionName;
  final String? divisionBnName;
  final String name;
  final String? bnName;
  final String slug;

  String localizedName(String locale) {
    if (locale == 'bn' && bnName != null && bnName!.isNotEmpty) {
      return bnName!;
    }
    return name;
  }

  factory Thana.fromJson(Map<String, dynamic> json) {
    return Thana(
      id: json['id'] as int,
      districtId: (json['district'] as num?)?.toInt() ??
          (json['district_id'] as num?)?.toInt(),
      districtName: json['district_name'] as String?,
      districtBnName: json['district_bn_name'] as String?,
      divisionId: (json['division_id'] as num?)?.toInt(),
      divisionName: json['division_name'] as String?,
      divisionBnName: json['division_bn_name'] as String?,
      name: json['name'] as String? ?? '',
      bnName: json['bn_name'] as String?,
      slug: json['slug'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'district': districtId,
    'district_name': districtName,
    'district_bn_name': districtBnName,
    'division_id': divisionId,
    'division_name': divisionName,
    'division_bn_name': divisionBnName,
    'name': name,
    'bn_name': bnName,
    'slug': slug,
  };
}
