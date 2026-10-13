import 'chamber.dart';
import 'specialty.dart';

class SpecialtyDisplay {
  const SpecialtyDisplay({this.en = '', this.bn = ''});

  final String en;
  final String bn;

  String forLocale(String locale) {
    if (locale == 'bn' && bn.isNotEmpty) return bn;
    return en;
  }

  factory SpecialtyDisplay.fromJson(Map<String, dynamic> json) {
    return SpecialtyDisplay(
      en: json['en'] is String ? json['en'] as String : '',
      bn: json['bn'] is String ? json['bn'] as String : '',
    );
  }
}

class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    this.bnName,
    required this.slug,
    this.academicTitle,
    this.institution,
    this.primarySpecialty,
    this.specialties = const [],
    this.qualification,
    this.experience,
    this.about,
    this.image,
    this.gender,
    this.rating,
    this.reviewCount = 0,
    this.isVerified = false,
    this.bmdcNumber,
    this.specialtyDisplay,
    this.chambers = const [],
  });

  final String id;
  final String name;
  final String? bnName;
  final String slug;
  final String? academicTitle;
  final String? institution;
  final Specialty? primarySpecialty;
  final List<Specialty> specialties;
  final String? qualification;
  final String? experience;
  final String? about;
  final String? image;
  final String? gender;
  final double? rating;
  final int reviewCount;
  final bool isVerified;
  final String? bmdcNumber;
  final SpecialtyDisplay? specialtyDisplay;
  final List<Chamber> chambers;

  String localizedName(String locale) {
    if (locale == 'bn' && bnName != null && bnName!.isNotEmpty) {
      return bnName!;
    }
    return name;
  }

  String get primarySpecialtyName {
    final primary = primarySpecialty?.name;
    if (primary != null && primary.isNotEmpty) return primary;
    if (specialties.isNotEmpty) return specialties.first.name;
    return '';
  }

  double? get minFee {
    double? min;
    for (final chamber in chambers) {
      final fee = chamber.fee;
      if (fee == null) continue;
      if (min == null || fee < min) min = fee;
    }
    return min;
  }

  Chamber? get primaryChamber => chambers.isNotEmpty ? chambers.first : null;

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final specialtiesRaw = json['specialties'];
    final specialties = <Specialty>[];
    if (specialtiesRaw is List) {
      for (final item in specialtiesRaw) {
        if (item is Map) {
          specialties.add(Specialty.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final chambersRaw = json['chambers'];
    final chambers = <Chamber>[];
    if (chambersRaw is List) {
      for (final item in chambersRaw) {
        if (item is Map) {
          chambers.add(Chamber.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final primarySpecialtyRaw = json['primary_specialty'];
    final specialtyDisplayRaw = json['specialty_display'];

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
      primarySpecialty: primarySpecialtyRaw is Map
          ? Specialty.fromJson(Map<String, dynamic>.from(primarySpecialtyRaw))
          : null,
      specialties: specialties,
      qualification: json['qualification'] as String?,
      experience: json['experience'] as String?,
      about: json['about'] as String?,
      image: json['image'] as String?,
      gender: json['gender'] as String?,
      rating: rating,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      isVerified: json['is_verified'] == true,
      bmdcNumber: json['bmdc_number'] as String?,
      specialtyDisplay: specialtyDisplayRaw is Map
          ? SpecialtyDisplay.fromJson(
              Map<String, dynamic>.from(specialtyDisplayRaw))
          : null,
      chambers: chambers,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bn_name': bnName,
        'slug': slug,
        'academic_title': academicTitle,
        'institution': institution,
        'primary_specialty': primarySpecialty?.toJson(),
        'specialties': specialties.map((s) => s.toJson()).toList(),
        'qualification': qualification,
        'experience': experience,
        'about': about,
        'image': image,
        'gender': gender,
        'rating': rating,
        'review_count': reviewCount,
        'is_verified': isVerified,
        'bmdc_number': bmdcNumber,
        'specialty_display': specialtyDisplay == null
            ? null
            : {'en': specialtyDisplay!.en, 'bn': specialtyDisplay!.bn},
        'chambers': chambers.map((c) => c.toJson()).toList(),
      };
}
