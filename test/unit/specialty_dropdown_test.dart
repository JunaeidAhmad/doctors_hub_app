import 'package:doctors_hub_app/core/widgets/specialty_dropdown.dart';
import 'package:doctors_hub_app/features/doctors/domain/models/specialty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Specialty _umbrella({
  required String id,
  required String slug,
  required String name,
  String? bnName,
  int? count,
}) {
  return Specialty(
    id: id,
    name: name,
    bnName: bnName,
    slug: slug,
    doctorCount: count,
    isUmbrella: true,
  );
}

Specialty _leaf({
  required String id,
  required String slug,
  required String name,
  String? bnName,
  int? count,
  List<SpecialtyParent> parents = const [],
}) {
  return Specialty(
    id: id,
    name: name,
    bnName: bnName,
    slug: slug,
    doctorCount: count,
    parents: parents,
  );
}

void main() {
  test('Specialty.fromJson parses umbrella fields and parents', () {
    final spec = Specialty.fromJson({
      'id': 'u1',
      'name': 'Cancer Care',
      'canonical_name': 'Cancer Care',
      'bn_name': 'ক্যান্সার',
      'formal_name': 'Oncology & Cancer Care',
      'slug': 'cancer-care',
      'icon': 'Ribbon',
      'doctor_count': 62,
      'is_umbrella': true,
      'is_popular': false,
      'parents': [],
    });
    expect(spec.isUmbrella, isTrue);
    expect(spec.bnName, 'ক্যান্সার');
    expect(spec.formalName, 'Oncology & Cancer Care');

    final leaf = Specialty.fromJson({
      'id': 'l1',
      'name': 'Cardiologist',
      'bn_name': 'হৃদরোগ বিশেষজ্ঞ',
      'slug': 'cardiologist',
      'doctor_count': 92,
      'is_umbrella': false,
      'parents': [
        {'id': 'u2', 'slug': 'heart-vascular', 'name': 'Heart & Vascular'},
      ],
    });
    expect(leaf.isUmbrella, isFalse);
    expect(leaf.parents.single.slug, 'heart-vascular');
  });

  test('specialtyBilingualLabel combines en, bn and count', () {
    final spec = _leaf(
      id: 'l1',
      slug: 'cardiologist',
      name: 'Cardiologist',
      bnName: 'হৃদরোগ বিশেষজ্ঞ',
      count: 92,
    );
    expect(
      specialtyBilingualLabel(spec),
      'Cardiologist · হৃদরোগ বিশেষজ্ঞ (92)',
    );
    final noCount = _leaf(id: 'l2', slug: 'x', name: 'X');
    expect(specialtyBilingualLabel(noCount), 'X');
  });

  test('buildSpecialtyGroups groups, sorts and handles multi-parent', () {
    final groups = buildSpecialtyGroups([
      _umbrella(
          id: 'u1',
          slug: 'medicine-primary-care',
          name: 'Medicine & Primary Care',
          count: 402),
      _umbrella(
          id: 'u2', slug: 'heart-vascular', name: 'Heart & Vascular', count: 128),
      _leaf(
        id: 'l1',
        slug: 'cardiologist',
        name: 'Cardiologist',
        count: 92,
        parents: const [
          SpecialtyParent(id: 'u2', slug: 'heart-vascular', name: 'Heart & Vascular'),
        ],
      ),
      _leaf(
        id: 'l2',
        slug: 'thoracic-surgeon',
        name: 'Thoracic Surgeon',
        count: 8,
        parents: const [
          SpecialtyParent(id: 'u2', slug: 'heart-vascular', name: 'Heart & Vascular'),
          SpecialtyParent(id: 'u9', slug: 'chest-lungs', name: 'Chest & Lungs'),
        ],
      ),
      _leaf(id: 'l3', slug: 'lonely', name: 'Lonely'),
    ]);

    // Medicine (402) before Heart (128); orphan group trailing.
    expect(groups.length, 3);
    expect(groups[0].umbrella!.slug, 'medicine-primary-care');
    expect(groups[1].umbrella!.slug, 'heart-vascular');
    expect(groups[1].leaves.first.slug, 'cardiologist');
    expect(groups[2].umbrella, isNull);
    expect(groups[2].leaves.single.slug, 'lonely');
  });

  test('buildSpecialtyGroups returns empty for legacy flat data', () {
    final groups = buildSpecialtyGroups([
      _leaf(id: 'l1', slug: 'cardio', name: 'Cardiology'),
    ]);
    expect(groups, isEmpty);
  });

  testWidgets('SpecialtyDropdown opens sheet and selects a leaf',
      (tester) async {
    String? selected;
    final specialties = [
      _umbrella(
        id: 'u2',
        slug: 'heart-vascular',
        name: 'Heart & Vascular',
        bnName: 'হৃদরোগ ও রক্তনালী',
        count: 128,
      ),
      _leaf(
        id: 'l1',
        slug: 'cardiologist',
        name: 'Cardiologist',
        bnName: 'হৃদরোগ বিশেষজ্ঞ',
        count: 92,
        parents: const [
          SpecialtyParent(id: 'u2', slug: 'heart-vascular', name: 'Heart & Vascular'),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpecialtyDropdown(
            specialties: specialties,
            selectedSlug: '',
            onChanged: (v) => selected = v,
            isBn: false,
            allLabel: 'All Specialties',
            otherLabel: 'Other',
          ),
        ),
      ),
    );

    expect(find.text('All Specialties'), findsOneWidget);

    await tester.tap(find.text('All Specialties'));
    await tester.pumpAndSettle();

    expect(
      find.text('Heart & Vascular · হৃদরোগ ও রক্তনালী (128)'),
      findsOneWidget,
    );
    expect(
      find.text('Cardiologist · হৃদরোগ বিশেষজ্ঞ (92)'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cardiologist · হৃদরোগ বিশেষজ্ঞ (92)'));
    await tester.pumpAndSettle();
    expect(selected, 'cardiologist');
  });
}
