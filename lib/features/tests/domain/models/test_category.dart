class TestCategory {
  const TestCategory({
    required this.id,
    required this.name,
    this.bnName,
    required this.slug,
    this.testCount,
  });

  final String id;
  final String name;
  final String? bnName;
  final String slug;
  final int? testCount;

  String localizedName(String locale) {
    if (locale == 'bn' && bnName != null && bnName!.isNotEmpty) {
      return bnName!;
    }
    return name;
  }

  factory TestCategory.fromJson(Map<String, dynamic> json) {
    return TestCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      bnName: json['bn_name'] as String?,
      slug: json['slug'] as String? ?? '',
      testCount: (json['test_count'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bn_name': bnName,
    'slug': slug,
    'test_count': testCount,
  };
}
