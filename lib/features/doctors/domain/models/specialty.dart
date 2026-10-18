class SpecialtyParent {
  const SpecialtyParent({
    required this.id,
    required this.slug,
    required this.name,
  });

  final String id;
  final String slug;
  final String name;

  factory SpecialtyParent.fromJson(Map<String, dynamic> json) {
    return SpecialtyParent(
      id: json['id']?.toString() ?? '',
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'name': name,
      };
}

class Specialty {
  const Specialty({
    required this.id,
    required this.name,
    this.canonicalName,
    this.bnName,
    this.formalName,
    required this.slug,
    this.icon,
    this.doctorCount,
    this.displayOrder,
    this.isUmbrella = false,
    this.isPopular = false,
    this.parents = const [],
  });

  final String id;
  final String name;
  final String? canonicalName;
  final String? bnName;
  final String? formalName;
  final String slug;
  final String? icon;
  final int? doctorCount;

  /// Taxonomy curation order (1–24) from the server; null when absent.
  final int? displayOrder;
  final bool isUmbrella;
  final bool isPopular;
  final List<SpecialtyParent> parents;

  String localizedName(String locale) {
    if (locale == 'bn' && bnName != null && bnName!.isNotEmpty) {
      return bnName!;
    }
    return canonicalName ?? name;
  }

  factory Specialty.fromJson(Map<String, dynamic> json) {
    final parentsRaw = json['parents'] as List<dynamic>? ?? const [];
    return Specialty(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      canonicalName: json['canonical_name'] as String?,
      bnName: json['bn_name'] as String?,
      formalName: json['formal_name'] as String?,
      slug: json['slug'] as String? ?? '',
      icon: json['icon'] as String?,
      doctorCount: (json['doctor_count'] as num?)?.toInt(),
      displayOrder: (json['display_order'] as num?)?.toInt(),
      isUmbrella: json['is_umbrella'] as bool? ?? false,
      isPopular: json['is_popular'] as bool? ?? false,
      parents: parentsRaw
          .whereType<Map<String, dynamic>>()
          .map(SpecialtyParent.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'canonical_name': canonicalName,
    'bn_name': bnName,
    'formal_name': formalName,
    'slug': slug,
    'icon': icon,
    'doctor_count': doctorCount,
    'display_order': displayOrder,
    'is_umbrella': isUmbrella,
    'is_popular': isPopular,
    'parents': parents.map((p) => p.toJson()).toList(),
  };
}
