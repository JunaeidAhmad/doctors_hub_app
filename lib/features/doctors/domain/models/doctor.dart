import 'affiliation.dart';
import 'specialty.dart';

class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    this.bnName,
    required this.slug,
    this.academicTitle,
    this.institution,
    this.specialties = const [],
    this.qualification,
    this.experience,
    this.about,
    this.image,
    this.gender,
    this.rating,
    this.reviewCount = 0,
    this.affiliations = const [],
  });

  final String id;
  final String name;
  final String? bnName;
  final String slug;
  final String? academicTitle;
  final String? institution;
  final List<Specialty> specialties;
  final String? qualification;
  final String? experience;
  final String? about;
  final String? image;
  final String? gender;
  final double? rating;
  final int reviewCount;
  final List<DoctorAffiliation> affiliations;

  String localizedName(String locale) {
    if (locale == 'bn' && bnName != null && bnName!.isNotEmpty) {
      return bnName!;
    }
    return name;
  }

  String get primarySpecialtyName =>
      specialties.isNotEmpty ? specialties.first.name : 'General Physician';

  double? get minFee {
    if (affiliations.isEmpty) return null;
    double? min;
    for (final aff in affiliations) {
      if (aff.fee > 0) {
        if (min == null || aff.fee < min) {
          min = aff.fee;
        }
      }
    }
    return min;
  }

  DoctorAffiliation? get primaryChamber =>
      affiliations.isNotEmpty ? affiliations.first : null;

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final specialtiesRaw = json['specialties'] as List<dynamic>? ?? [];
    final specialties = specialtiesRaw
        .map((s) => Specialty.fromJson(s as Map<String, dynamic>))
        .toList();

    final affiliationsRaw = json['affiliations'] as List<dynamic>? ?? [];
    final affiliations = affiliationsRaw
        .map((a) => DoctorAffiliation.fromJson(a as Map<String, dynamic>))
        .toList();

    double? rating;
    if (json['rating'] != null) {
      rating = double.tryParse(json['rating'].toString());
    }

    return Doctor(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      bnName: json['bn_name'] as String?,
      slug: json['slug'] as String? ?? '',
      academicTitle: json['academic_title'] as String?,
      institution: json['institution'] as String?,
      specialties: specialties,
      qualification: json['qualification'] as String?,
      experience: json['experience'] as String?,
      about: json['about'] as String? ?? json['description'] as String?,
      image: json['image'] as String?,
      gender: json['gender'] as String?,
      rating: rating,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      affiliations: affiliations,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bn_name': bnName,
    'slug': slug,
    'academic_title': academicTitle,
    'institution': institution,
    'specialties': specialties.map((s) => s.toJson()).toList(),
    'qualification': qualification,
    'experience': experience,
    'about': about,
    'image': image,
    'gender': gender,
    'rating': rating,
    'review_count': reviewCount,
    'affiliations': affiliations.map((a) => a.toJson()).toList(),
  };
}
