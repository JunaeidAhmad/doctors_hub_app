import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/dh_dropdown.dart';
import '../../../core/widgets/dh_scaffold.dart';
import '../../../core/widgets/dh_search_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/filter_chip_dark.dart';
import '../../../core/widgets/kicker.dart';
import '../../../core/widgets/photo_placeholder.dart';
import '../../../core/widgets/skeleton_row.dart';
import '../domain/models/doctor.dart';

class DoctorsListScreen extends ConsumerStatefulWidget {
  const DoctorsListScreen({
    super.key,
    this.initialSpecialty,
    this.initialDivision,
    this.initialHospital,
    this.initialSearch,
  });

  final String? initialSpecialty;
  final String? initialDivision;
  final String? initialHospital;
  final String? initialSearch;

  @override
  ConsumerState<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends ConsumerState<DoctorsListScreen> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  String? _specialty;
  String? _division;
  String? _hospital;
  String _searchQuery = '';

  final List<Doctor> _doctors = [];
  int _totalCount = 0;
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String? _errorMessage;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _specialty = widget.initialSpecialty;
    _division = widget.initialDivision;
    _hospital = widget.initialHospital;
    _searchQuery = widget.initialSearch ?? '';
    _searchController = TextEditingController(text: _searchQuery);

    _scrollController.addListener(_onScroll);
    _fetchDoctors(page: 1);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMore) {
      _fetchDoctors(page: _currentPage + 1, isLoadMore: true);
    }
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      setState(() {
        _searchQuery = val;
      });
      _fetchDoctors(page: 1);
    });
  }

  Future<void> _fetchDoctors({required int page, bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final repo = ref.read(doctorRepositoryProvider);
      final result = await repo.searchDoctors(
        search: _searchQuery,
        specialty: _specialty,
        division: _division,
        hospital: _hospital,
        page: page,
        pageSize: 20,
      );

      setState(() {
        if (isLoadMore) {
          _doctors.addAll(result.results);
          _isLoadingMore = false;
        } else {
          _doctors.clear();
          _doctors.addAll(result.results);
          _isLoading = false;
        }
        _totalCount = result.count;
        _currentPage = page;
        _hasMore = result.hasMore;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isBn = locale.languageCode == 'bn';
    final specialtiesAsync = ref.watch(specialtiesProvider);

    final activeSpecialtyName = _specialty != null && _specialty!.isNotEmpty
        ? _specialty!.toUpperCase()
        : (isBn ? 'সকল ডাক্তার' : 'ALL DOCTORS');

    return DhScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Filter & Search Section
            Container(
              color: AppColors.paper,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Kicker(
                    isBn
                        ? '$_totalCount জন ডাক্তার · $activeSpecialtyName'
                        : '$_totalCount DOCTORS · $activeSpecialtyName',
                  ),
                  const SizedBox(height: 10),
                  // Search field
                  DhSearchField(
                    controller: _searchController,
                    hintText: isBn
                        ? 'ডাক্তার, হাসপাতাল বা বিশেষজ্ঞ খুঁজুন...'
                        : 'Search doctor, hospital, specialty...',
                    onChanged: _onSearchChanged,
                    onClear: () {
                      _debounceTimer?.cancel();
                      setState(() => _searchQuery = '');
                      _fetchDoctors(page: 1);
                    },
                  ),
                  const SizedBox(height: 10),
                  // Specialty Dropdown
                  specialtiesAsync.when(
                    data: (specialties) {
                      final items = [
                        DhDropdownItem<String>(
                          value: '',
                          label: isBn ? 'সকল বিশেষজ্ঞ' : 'All Specialties',
                        ),
                        ...specialties.map(
                          (s) => DhDropdownItem<String>(
                            value: s.slug,
                            label: s.localizedName(isBn ? 'bn' : 'en'),
                          ),
                        ),
                      ];
                      return DhDropdown<String>(
                        value: _specialty ?? '',
                        items: items,
                        onChanged: (val) {
                          setState(() => _specialty = val);
                          _fetchDoctors(page: 1);
                        },
                      );
                    },
                    loading: () => const SkeletonRow(height: 48),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // Removable Filter Chips (Division, Hospital)
                  if ((_division != null && _division!.isNotEmpty) ||
                      (_hospital != null && _hospital!.isNotEmpty)) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_division != null && _division!.isNotEmpty)
                          FilterChipDark(
                            label: _division!,
                            onDeleted: () {
                              setState(() => _division = null);
                              _fetchDoctors(page: 1);
                            },
                          ),
                        if (_hospital != null && _hospital!.isNotEmpty)
                          FilterChipDark(
                            label: 'At $_hospital',
                            onDeleted: () {
                              setState(() => _hospital = null);
                              _fetchDoctors(page: 1);
                            },
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.ink),

            // Doctor List / States
            Expanded(
              child: _buildBody(context, isBn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isBn) {
    if (_isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => const SkeletonRow(height: 140),
      );
    }

    if (_errorMessage != null) {
      return ErrorState(
        message: _errorMessage!,
        onRetry: () => _fetchDoctors(page: 1),
      );
    }

    if (_doctors.isEmpty) {
      return EmptyState(
        title: isBn ? 'কোন ডাক্তার পাওয়া যায়নি' : 'No doctors found',
        message: isBn
            ? 'অনুগ্রহ করে অনুসন্ধানের শব্দ বা ফিল্টার পরিবর্তন করুন।'
            : 'Try adjusting your search query or filters.',
        actionLabel: isBn ? 'ফিল্টার মুছুন' : 'Clear filters',
        onAction: () {
          setState(() {
            _specialty = null;
            _division = null;
            _hospital = null;
            _searchQuery = '';
            _searchController.clear();
          });
          _fetchDoctors(page: 1);
        },
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () => _fetchDoctors(page: 1),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _doctors.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == _doctors.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
              ),
            );
          }

          final doctor = _doctors[index];
          return _buildDoctorCard(context, doctor, isBn);
        },
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doctor, bool isBn) {
    final primaryChamber = doctor.primaryChamber;
    final otherChambersCount =
        doctor.affiliations.length > 1 ? doctor.affiliations.length - 1 : 0;

    return InkWell(
      onTap: () => context.push('/doctors/${doctor.slug}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.paper,
          border: Border.all(color: AppColors.ink, width: AppColors.borderWidth),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhotoPlaceholder(
                  name: doctor.name,
                  imageUrl: doctor.image,
                  width: 56,
                  height: 56,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.localizedName(isBn ? 'bn' : 'en'),
                        style: AppTypography.h2.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${doctor.primarySpecialtyName}${doctor.qualification != null ? ' · ${doctor.qualification}' : ''}',
                        style: AppTypography.secondary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.lineSoft, height: 1),
            const SizedBox(height: 10),

            // Chamber information
            if (primaryChamber != null)
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      primaryChamber.fullDisplayName,
                      style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (otherChambersCount > 0)
                    Text(
                      isBn ? '+ $otherChambersCount টি চেম্বার' : '+ $otherChambersCount more',
                      style: AppTypography.tag.copyWith(color: AppColors.muted),
                    ),
                ],
              ),

            const SizedBox(height: 10),

            // Bottom stats & fee
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (doctor.rating != null && doctor.rating! > 0) ...[
                      const Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
                      const SizedBox(width: 2),
                      Text(
                        doctor.rating!.toStringAsFixed(1),
                        style: AppTypography.secondaryBold,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (doctor.experience != null && doctor.experience!.isNotEmpty)
                      Text(
                        isBn ? '${doctor.experience} অভিজ্ঞতা' : '${doctor.experience} exp',
                        style: AppTypography.secondary,
                      ),
                  ],
                ),
                if (doctor.minFee != null)
                  Text(
                    isBn ? '৳${doctor.minFee!.toInt()} থেকে' : 'from ৳${doctor.minFee!.toInt()}',
                    style: AppTypography.h2.copyWith(
                      fontSize: 15,
                      color: AppColors.accent,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
