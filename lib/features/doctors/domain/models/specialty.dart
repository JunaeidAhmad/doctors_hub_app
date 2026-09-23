class Specialty {
  const Specialty({
    required this.id,
    required this.name,
    this.canonicalName,
    this.bnName,
    required this.slug,
    this.icon,
    this.doctorCount,
  });

  final String id;
  final String name;
  final String? canonicalName;
  final String? bnName;
  final String slug;
  final String? icon;
  final int? doctorCount;

  String localizedName(String locale) {
    if (locale == 'bn' && bnName != null && bnName!.isNotEmpty) {
      return bnName!;
    }
    return canonicalName ?? name;
  }

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      canonicalName: json['canonical_name'] as String?,
      bnName: json['bn_name'] as String?,
      slug: json['slug'] as String? ?? '',
      icon: json['icon'] as String?,
      doctorCount: (json['doctor_count'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'canonical_name': canonicalName,
    'bn_name': bnName,
    'slug': slug,
    'icon': icon,
    'doctor_count': doctorCount,
  };
}
