class District {
  const District({
    required this.id,
    this.divisionId,
    this.divisionName,
    this.divisionBnName,
    required this.name,
    this.bnName,
    required this.slug,
    this.thanasCount,
  });

  final int id;
  final int? divisionId;
  final String? divisionName;
  final String? divisionBnName;
  final String name;
  final String? bnName;
  final String slug;
  final int? thanasCount;

  String localizedName(String locale) {
    if (locale == 'bn' && bnName != null && bnName!.isNotEmpty) {
      return bnName!;
    }
    return name;
  }

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] as int,
      divisionId: (json['division'] as num?)?.toInt() ??
          (json['division_id'] as num?)?.toInt(),
      divisionName: json['division_name'] as String?,
      divisionBnName: json['division_bn_name'] as String?,
      name: json['name'] as String? ?? '',
      bnName: json['bn_name'] as String?,
      slug: json['slug'] as String? ?? '',
      thanasCount: (json['thanas_count'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'division': divisionId,
    'division_name': divisionName,
    'division_bn_name': divisionBnName,
    'name': name,
    'bn_name': bnName,
    'slug': slug,
    'thanas_count': thanasCount,
  };
}
