class HospitalCategory {
  const HospitalCategory({
    required this.id,
    required this.name,
    this.bnName,
    required this.slug,
  });

  final String id;
  final String name;
  final String? bnName;
  final String slug;

  String localizedName(String locale) {
    if (locale == 'bn' && bnName != null && bnName!.isNotEmpty) {
      return bnName!;
    }
    return name;
  }

  factory HospitalCategory.fromJson(Map<String, dynamic> json) {
    return HospitalCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      bnName: json['bn_name'] as String?,
      slug: json['slug'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bn_name': bnName,
    'slug': slug,
  };
}
