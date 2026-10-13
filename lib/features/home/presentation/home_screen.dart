import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_config/update_banner.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../booking/domain/booking_mode.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/dh_dropdown.dart';
import '../../../core/widgets/specialty_dropdown.dart';
import '../../../core/widgets/dh_scaffold.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/photo_placeholder.dart';
import '../../../core/widgets/primary_cta_button.dart';
import '../../../core/widgets/rule_grid.dart';
import '../../../core/widgets/skeleton_row.dart';
import '../../doctors/domain/models/doctor.dart';
import '../../hospitals/domain/models/hospital.dart';

// Home Screen State Providers
final homePopularDoctorsProvider = FutureProvider<List<Doctor>>((ref) async {
  final repo = ref.watch(doctorRepositoryProvider);
  final res = await repo.searchDoctors(pageSize: 6);
  return res.results;
});

final homeTopHospitalsProvider = FutureProvider<List<Hospital>>((ref) async {
  final repo = ref.watch(hospitalRepositoryProvider);
  final res = await repo.getHospitals(pageSize: 3);
  return res.results;
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _searchTabIndex = 0; // 0 = Doctors, 1 = Diagnostics, 2 = Hospitals
  String? _selectedCategory;
  int? _selectedDivision;
  bool _updateBannerDismissed = false;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isBn = locale.languageCode == 'bn';

    return DhScaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.paper,
          onRefresh: () async {
            ref.invalidate(divisionsProvider);
            ref.invalidate(specialtiesProvider);
            ref.invalidate(homePopularDoctorsProvider);
            ref.invalidate(testCategoriesProvider);
            ref.invalidate(hospitalCategoriesProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, isBn),
                if (!_updateBannerDismissed)
                  UpdateBanner(
                    onDismiss: () =>
                        setState(() => _updateBannerDismissed = true),
                  ),
                _buildSearchCard(context, isBn),
                const SizedBox(height: 24),
                _buildSpecialtiesSection(context, isBn),
                const SizedBox(height: 24),
                _buildPopularDoctorsSection(context, isBn),
                const SizedBox(height: 24),
                _buildDiagnosticsSection(context, isBn),
                const SizedBox(height: 24),
                _buildHospitalsSection(context, isBn),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isBn) {
    return Container(
      color: AppColors.paper,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'ডক্টরস হাব' : 'DOCTORS HUB',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontMono,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              // Language switch button
              InkWell(
                onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.fill,
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  child: Text(
                    isBn ? 'EN' : 'বাং',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontMono,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isBn
                ? 'সারা বাংলাদেশে ডাক্তার ও\nল্যাব টেস্ট বুক করুন'
                : 'Book doctors and lab tests\nacross Bangladesh',
            style: AppTypography.h1,
          ),
          const SizedBox(height: 8),
          Text(
            isBn
                ? 'কোন অ্যাকাউন্ট ছাড়াই সরাসরি বুক করুন।'
                : 'No account required. Instant confirmation.',
            style: AppTypography.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context, bool isBn) {
    final divisionsAsync = ref.watch(divisionsProvider);
    final specialtiesAsync = ref.watch(specialtiesProvider);
    final testCategoriesAsync = ref.watch(testCategoriesProvider);
    final hospitalCategoriesAsync = ref.watch(hospitalCategoriesProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(color: AppColors.ink, width: AppColors.borderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 3-way tabs: Doctors / Diagnostics / Hospitals
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.ink, width: AppColors.borderWidth),
              ),
            ),
            child: Row(
              children: [
                _buildSearchTab(0, isBn ? 'ডাক্তার' : 'Doctors'),
                _buildSearchTab(1, isBn ? 'ডায়াগনস্টিক' : 'Diagnostics'),
                _buildSearchTab(2, isBn ? 'হাসপাতাল' : 'Hospitals'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category dropdown based on selected tab
                if (_searchTabIndex == 0)
                  specialtiesAsync.when(
                    data: (specialties) {
                      return SpecialtyDropdown(
                        specialties: specialties,
                        selectedSlug: _selectedCategory ?? '',
                        onChanged: (val) => setState(() => _selectedCategory =
                            val.isEmpty ? null : val),
                        isBn: isBn,
                        allLabel:
                            isBn ? 'সকল বিশেষজ্ঞ' : 'All Specialties',
                        otherLabel: isBn ? 'অন্যান্য' : 'Other',
                      );
                    },
                    loading: () => const SkeletonRow(height: 48),
                    error: (_, __) => const SizedBox.shrink(),
                  )
                else if (_searchTabIndex == 1)
                  testCategoriesAsync.when(
                    data: (categories) {
                      final items = [
                        DhDropdownItem<String>(
                          value: '',
                          label: isBn ? 'সকল টেস্ট ক্যাটাগরি' : 'All Test Categories',
                        ),
                        ...categories.map(
                          (c) => DhDropdownItem<String>(
                            value: c.slug,
                            label: c.localizedName(isBn ? 'bn' : 'en'),
                          ),
                        ),
                      ];
                      return DhDropdown<String>(
                        value: _selectedCategory ?? '',
                        items: items,
                        onChanged: (val) => setState(() => _selectedCategory = val),
                      );
                    },
                    loading: () => const SkeletonRow(height: 48),
                    error: (_, __) => const SizedBox.shrink(),
                  )
                else
                  hospitalCategoriesAsync.when(
                    data: (categories) {
                      final items = [
                        DhDropdownItem<String>(
                          value: '',
                          label: isBn ? 'সকল হাসপাতাল' : 'All Facilities',
                        ),
                        ...categories.map(
                          (c) => DhDropdownItem<String>(
                            value: c.slug,
                            label: c.localizedName(isBn ? 'bn' : 'en'),
                          ),
                        ),
                      ];
                      return DhDropdown<String>(
                        value: _selectedCategory ?? '',
                        items: items,
                        onChanged: (val) => setState(() => _selectedCategory = val),
                      );
                    },
                    loading: () => const SkeletonRow(height: 48),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                const SizedBox(height: 12),

                // Division dropdown
                divisionsAsync.when(
                  data: (divisions) {
                    final items = [
                      const DhDropdownItem<int?>(
                        value: null,
                        label: 'All Bangladesh',
                      ),
                      ...divisions.map(
                        (d) => DhDropdownItem<int?>(
                          value: d.id,
                          label: d.localizedName(isBn ? 'bn' : 'en'),
                        ),
                      ),
                    ];
                    return DhDropdown<int?>(
                      value: _selectedDivision,
                      items: items,
                      onChanged: (val) => setState(() => _selectedDivision = val),
                    );
                  },
                  loading: () => const SkeletonRow(height: 48),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 16),

                // Search Red Button
                PrimaryCtaButton(
                  label: isBn ? 'অনুসন্ধান' : 'Search',
                  onPressed: () {
                    final queryParams = <String, String>{};
                    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
                      if (_searchTabIndex == 0) {
                        queryParams['specialty'] = _selectedCategory!;
                      } else if (_searchTabIndex == 1) {
                        queryParams['category'] = _selectedCategory!;
                      } else {
                        queryParams['category'] = _selectedCategory!;
                      }
                    }
                    if (_selectedDivision != null) {
                      queryParams['division_id'] = _selectedDivision!.toString();
                    }

                    if (_searchTabIndex == 0) {
                      final uri = Uri(path: '/doctors', queryParameters: queryParams);
                      context.push(uri.toString());
                    } else if (_searchTabIndex == 1) {
                      final uri = Uri(path: '/tests', queryParameters: queryParams);
                      context.push(uri.toString());
                    } else {
                      final uri = Uri(path: '/hospitals', queryParameters: queryParams);
                      context.push(uri.toString());
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab(int index, String label) {
    final isSelected = _searchTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _searchTabIndex = index;
            _selectedCategory = null;
          });
        },
        child: Container(
          height: 44,
          color: isSelected ? AppColors.ink : AppColors.surface,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontArchivo,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.paper : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtiesSection(BuildContext context, bool isBn) {
    final specialtiesAsync = ref.watch(specialtiesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isBn ? 'বিশেষজ্ঞ বিভাগ' : 'Specialties', style: AppTypography.h2),
              InkWell(
                onTap: () => context.push('/doctors'),
                child: Text(
                  isBn ? 'সব দেখুন →' : 'See all →',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontArchivo,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentLink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          specialtiesAsync.when(
            data: (specialties) {
              final top8 = specialties.take(8).toList();
              return RuleGrid(
                crossAxisCount: 2,
                itemCount: top8.length,
                childAspectRatio: 2.2,
                itemBuilder: (context, index) {
                  final spec = top8[index];
                  final numStr = (index + 1).toString().padLeft(2, '0');

                  return InkWell(
                    onTap: () => context.push('/doctors?specialty=${spec.slug}'),
                    child: Container(
                      color: AppColors.paper,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Text(
                            numStr,
                            style: AppTypography.gridNumber,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  spec.localizedName(isBn ? 'bn' : 'en'),
                                  style: AppTypography.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (spec.doctorCount != null && spec.doctorCount! > 0)
                                  Text(
                                    isBn
                                        ? '${spec.doctorCount} জন ডাক্তার'
                                        : '${spec.doctorCount} doctors',
                                    style: AppTypography.secondary,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Column(
              children: [
                SkeletonRow(height: 56),
                SizedBox(height: 2),
                SkeletonRow(height: 56),
              ],
            ),
            error: (err, _) => ErrorState(
              message: err.toString(),
              onRetry: () => ref.invalidate(specialtiesProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularDoctorsSection(BuildContext context, bool isBn) {
    final doctorsAsync = ref.watch(homePopularDoctorsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isBn ? 'জনপ্রিয় ডাক্তারগণ' : 'Popular Doctors', style: AppTypography.h2),
              InkWell(
                onTap: () => context.push('/doctors'),
                child: Text(
                  isBn ? 'সব দেখুন →' : 'See all →',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontArchivo,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentLink,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        doctorsAsync.when(
          data: (doctors) {
            if (doctors.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: 195,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: doctors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final doc = doctors[index];
                  return InkWell(
                    onTap: () => context.push('/doctors/${doc.slug}'),
                    child: Container(
                      width: 240,
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        border: Border.all(color: AppColors.ink, width: AppColors.borderWidth),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              PhotoPlaceholder(
                                name: doc.name,
                                imageUrl: doc.image,
                                width: 48,
                                height: 48,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc.localizedName(isBn ? 'bn' : 'en'),
                                      style: AppTypography.bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      doc.primarySpecialtyName,
                                      style: AppTypography.secondary,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (doc.primaryChamber != null) ...[
                            Text(
                              doc.primaryChamber!.fullDisplayName,
                              style: AppTypography.secondary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (nextAvailableLabel(
                                  doc.primaryChamber!,
                                  AppLocalizations.of(context)!,
                                ) !=
                                null)
                              Text(
                                nextAvailableLabel(
                                  doc.primaryChamber!,
                                  AppLocalizations.of(context)!,
                                )!,
                                style: AppTypography.secondary.copyWith(
                                  fontSize: 11,
                                  color: AppColors.accentLink,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (doc.minFee != null)
                                Text(
                                  isBn
                                      ? 'ভিজিট ৳${doc.minFee!.toInt()}'
                                      : 'from ৳${doc.minFee!.toInt()}',
                                  style: AppTypography.secondaryBold.copyWith(
                                    color: AppColors.accent,
                                  ),
                                ),
                              const Text(
                                'Book →',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontArchivo,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SkeletonRow(height: 180),
          ),
          error: (err, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildDiagnosticsSection(BuildContext context, bool isBn) {
    final categoriesAsync = ref.watch(testCategoriesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isBn ? 'ডায়াগনস্টিক টেস্ট' : 'Diagnostic Tests', style: AppTypography.h2),
              InkWell(
                onTap: () => context.push('/tests'),
                child: Text(
                  isBn ? 'সব দেখুন →' : 'See all →',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontArchivo,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentLink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          categoriesAsync.when(
            data: (categories) {
              final top6 = categories.take(6).toList();
              return RuleGrid(
                crossAxisCount: 3,
                itemCount: top6.length,
                childAspectRatio: 1.4,
                itemBuilder: (context, index) {
                  final cat = top6[index];
                  return InkWell(
                    onTap: () => context.push('/tests?category=${cat.slug}'),
                    child: Container(
                      color: AppColors.paper,
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text(
                        cat.localizedName(isBn ? 'bn' : 'en'),
                        style: AppTypography.tag.copyWith(fontSize: 12),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const SkeletonRow(height: 80),
            error: (err, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalsSection(BuildContext context, bool isBn) {
    final hospitalsAsync = ref.watch(homeTopHospitalsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isBn ? 'হাসপাতাল ও সেন্টার' : 'Hospitals', style: AppTypography.h2),
              InkWell(
                onTap: () => context.push('/hospitals'),
                child: Text(
                  isBn ? 'সব দেখুন →' : 'See all →',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontArchivo,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentLink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          hospitalsAsync.when(
            loading: () => const SkeletonRow(height: 140),
            error: (_, __) => const SizedBox.shrink(),
            data: (hospitals) {
              if (hospitals.isEmpty) return const SizedBox.shrink();

              return Column(
                children: hospitals.map((h) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.ink, width: AppColors.borderWidth),
                    ),
                    child: Material(
                      color: AppColors.paper,
                      child: ListTile(
                      onTap: () => context.push(
                        '/hospitals/${h.slug ?? h.id}',
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.fill,
                          border: Border.all(color: AppColors.ink, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          h.initials,
                          style: const TextStyle(
                            fontFamily: AppTypography.fontArchivo,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      title: Text(
                        h.localizedName(isBn ? 'bn' : 'en'),
                        style: AppTypography.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${h.category ?? 'Hospital'} · ${h.area ?? h.division ?? ''}',
                        style: AppTypography.secondary,
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.ink),
                    ),
                  ),
                );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
