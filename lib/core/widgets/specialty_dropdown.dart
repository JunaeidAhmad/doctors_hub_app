import 'package:flutter/material.dart';
import '../../features/doctors/domain/models/specialty.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A grouped view-model for the specialty picker sheet.
///
/// [umbrella] is null for the synthetic "Other" group that holds leaves
/// without a matching umbrella parent. The "Other" header is not selectable.
class SpecialtyGroup {
  const SpecialtyGroup({
    required this.umbrella,
    required this.leaves,
    required this.total,
  });

  final Specialty? umbrella;
  final List<Specialty> leaves;
  final int total;
}

/// Groups [specialties] into umbrella sections.
///
/// - Umbrellas are items with `isUmbrella == true`.
/// - A leaf with several parents appears under each matching umbrella.
/// - Leaves without a matching umbrella fall into a trailing "Other" group.
/// - Items sort by `display_order` (curated, when present), then by doctor
///   count desc, then by name.
/// - Returns an empty list when there are no umbrellas (legacy flat data),
///   in which case callers should render a flat list.
List<SpecialtyGroup> buildSpecialtyGroups(List<Specialty> specialties) {
  final umbrellas = specialties.where((s) => s.isUmbrella).toList();
  if (umbrellas.isEmpty) return const [];

  final bySlug = <String, Specialty>{for (final s in umbrellas) s.slug: s};
  final byId = <String, Specialty>{for (final s in umbrellas) s.id: s};
  final leavesByKey = <String, List<Specialty>>{};
  final orphans = <Specialty>[];

  for (final leaf in specialties.where((s) => !s.isUmbrella)) {
    final matched = <String>{};
    for (final parent in leaf.parents) {
      final key = bySlug.containsKey(parent.slug)
          ? parent.slug
          : byId.containsKey(parent.id)
              ? byId[parent.id]!.slug
              : null;
      if (key != null) matched.add(key);
    }
    if (matched.isEmpty) {
      orphans.add(leaf);
    } else {
      for (final key in matched) {
        leavesByKey.putIfAbsent(key, () => []).add(leaf);
      }
    }
  }

  int leafSum(List<Specialty> leaves) =>
      leaves.fold(0, (sum, s) => sum + (s.doctorCount ?? 0));

  final groups = <SpecialtyGroup>[];
  for (final umbrella in umbrellas) {
    final leaves = (leavesByKey[umbrella.slug] ?? []).toList()
      ..sort(compareSpecialties);
    final own = umbrella.doctorCount ?? 0;
    final sum = leafSum(leaves);
    // Prefer the server-provided umbrella count (distinct doctors) when
    // available; otherwise approximate with the sum of leaf counts.
    final total = own > 0 ? own : sum;
    groups.add(SpecialtyGroup(umbrella: umbrella, leaves: leaves, total: total));
  }

  groups.sort((a, b) {
    final aOrder = a.umbrella?.displayOrder;
    final bOrder = b.umbrella?.displayOrder;
    if (aOrder != null && bOrder != null && aOrder != bOrder) {
      return aOrder.compareTo(bOrder);
    }
    if (aOrder != null && bOrder == null) return -1;
    if (aOrder == null && bOrder != null) return 1;
    final countCmp = b.total.compareTo(a.total);
    if (countCmp != 0) return countCmp;
    return (a.umbrella?.name ?? '').compareTo(b.umbrella?.name ?? '');
  });

  if (orphans.isNotEmpty) {
    orphans.sort(compareSpecialties);
    groups.add(
      SpecialtyGroup(
        umbrella: null,
        leaves: orphans,
        total: leafSum(orphans),
      ),
    );
  }

  return groups;
}

/// Curated `display_order` first (when both sides have one), then doctor
/// count desc, then name.
int compareSpecialties(Specialty a, Specialty b) {
  final aOrder = a.displayOrder;
  final bOrder = b.displayOrder;
  if (aOrder != null && bOrder != null && aOrder != bOrder) {
    return aOrder.compareTo(bOrder);
  }
  if (aOrder != null && bOrder == null) return -1;
  if (aOrder == null && bOrder != null) return 1;
  final countCmp = (b.doctorCount ?? 0).compareTo(a.doctorCount ?? 0);
  if (countCmp != 0) return countCmp;
  return a.name.compareTo(b.name);
}

/// Bilingual label matching the web taxonomy picker:
/// "Name · bn_name (count)". Count is omitted when zero/null.
String specialtyBilingualLabel(Specialty spec) {
  final en = (spec.canonicalName?.isNotEmpty ?? false)
      ? spec.canonicalName!
      : spec.name;
  final bn = (spec.bnName?.isNotEmpty ?? false) ? spec.bnName! : '';
  final base = bn.isNotEmpty && bn != en ? '$en · $bn' : en;
  final count = spec.doctorCount ?? 0;
  return count > 0 ? '$base ($count)' : base;
}

/// Grouped specialty picker trigger styled like [DhDropdown].
///
/// The closed button is 48 high with a 2px ink border. Tapping it opens a
/// bottom sheet (no radius, ink borders) with umbrella-grouped options,
/// mirroring the web taxonomy dropdown in a mobile-friendly form.
class SpecialtyDropdown extends StatelessWidget {
  const SpecialtyDropdown({
    super.key,
    required this.specialties,
    required this.selectedSlug,
    required this.onChanged,
    required this.isBn,
    required this.allLabel,
    required this.otherLabel,
  });

  final List<Specialty> specialties;
  final String selectedSlug;
  final ValueChanged<String> onChanged;
  final bool isBn;
  final String allLabel;
  final String otherLabel;

  String _closedLabel() {
    if (selectedSlug.isEmpty) return allLabel;
    for (final s in specialties) {
      if (s.slug == selectedSlug) return s.localizedName(isBn ? 'bn' : 'en');
    }
    return selectedSlug;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: allLabel,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            builder: (_) => _SpecialtySheet(
              specialties: specialties,
              selectedSlug: selectedSlug,
              onChanged: onChanged,
              allLabel: allLabel,
              otherLabel: otherLabel,
            ),
          );
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.paper,
            border: Border.all(
              color: AppColors.ink,
              width: AppColors.borderWidth,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _closedLabel(),
                  style: AppTypography.body,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: AppColors.ink,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialtySheet extends StatelessWidget {
  const _SpecialtySheet({
    required this.specialties,
    required this.selectedSlug,
    required this.onChanged,
    required this.allLabel,
    required this.otherLabel,
  });

  final List<Specialty> specialties;
  final String selectedSlug;
  final ValueChanged<String> onChanged;
  final String allLabel;
  final String otherLabel;

  void _select(BuildContext context, String slug) {
    onChanged(slug);
    Navigator.pop(context);
  }

  Widget _optionRow({
    required BuildContext context,
    required String label,
    required bool selected,
    required TextStyle textStyle,
    required EdgeInsetsGeometry padding,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        color: selected ? AppColors.ink : AppColors.paper,
        padding: padding,
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: textStyle.copyWith(
            color: selected ? AppColors.paper : AppColors.ink,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = buildSpecialtyGroups(specialties);

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.paper,
            border: Border(
              top: BorderSide(
                color: AppColors.ink,
                width: AppColors.borderWidth,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  color: AppColors.line,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: groups.isNotEmpty
                    ? _buildGrouped(context, groups)
                    : _buildFlatList(context, specialties),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlatList(BuildContext context, List<Specialty> items) {
    final sorted = items.toList()..sort(compareSpecialties);
    return ListView.separated(
      itemCount: sorted.length + 1,
      separatorBuilder: (_, __) => const Divider(
        color: AppColors.lineSoft,
        height: 1,
        thickness: 1,
      ),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _optionRow(
            context: context,
            label: allLabel,
            selected: selectedSlug.isEmpty,
            textStyle: AppTypography.body,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onTap: () => _select(context, ''),
          );
        }
        final spec = sorted[index - 1];
        return _optionRow(
          context: context,
          label: specialtyBilingualLabel(spec),
          selected: selectedSlug == spec.slug,
          textStyle: AppTypography.body,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onTap: () => _select(context, spec.slug),
        );
      },
    );
  }

  Widget _buildGrouped(BuildContext context, List<SpecialtyGroup> groups) {
    return ListView(
      children: [
        _optionRow(
          context: context,
          label: allLabel,
          selected: selectedSlug.isEmpty,
          textStyle: AppTypography.body,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onTap: () => _select(context, ''),
        ),
        const Divider(
          color: AppColors.ink,
          height: 1,
          thickness: 1,
        ),
        for (final group in groups) ...[
          if (group.umbrella != null)
            _optionRow(
              context: context,
              label: specialtyBilingualLabel(group.umbrella!),
              selected: selectedSlug == group.umbrella!.slug,
              textStyle: AppTypography.bodyMedium,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onTap: () => _select(context, group.umbrella!.slug),
            )
          else
            Container(
              constraints: const BoxConstraints(minHeight: 40),
              color: AppColors.fill,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Text(
                otherLabel,
                style: AppTypography.tag.copyWith(color: AppColors.muted),
              ),
            ),
          for (final leaf in group.leaves)
            _optionRow(
              context: context,
              label: specialtyBilingualLabel(leaf),
              selected: selectedSlug == leaf.slug,
              textStyle: AppTypography.body,
              padding: const EdgeInsets.fromLTRB(32, 12, 16, 12),
              onTap: () => _select(context, leaf.slug),
            ),
          const Divider(
            color: AppColors.lineSoft,
            height: 1,
            thickness: 1,
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
