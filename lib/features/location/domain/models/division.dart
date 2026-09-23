class Division {
  const Division({
    required this.id,
    required this.name,
    this.bnName,
    required this.slug,
    this.order,
    this.districtsCount,
  });

  final int id;
  final String name;
  final String? bnName;
  final String slug;
  final int? order;
  final int? districtsCount;

  String localizedName(String locale) {
    if (locale == 'bn' && bnName != null && bnName!.isNotEmpty) {
      return bnName!;
    }
    return name;
  }

  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      bnName: json['bn_name'] as String?,
      slug: json['slug'] as String? ?? '',
      order: json['order'] as int?,
      districtsCount: json['districts_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bn_name': bnName,
    'slug': slug,
    'order': order,
    'districts_count': districtsCount,
  };
}
