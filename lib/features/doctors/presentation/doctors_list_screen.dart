import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/dh_dropdown.dart';
import '../../../core/widgets/specialty_dropdown.dart';
import '../../../core/widgets/dh_scaffold.dart';
import '../../../core/widgets/dh_search_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/filter_chip_dark.dart';
import '../../../core/widgets/kicker.dart';
import '../../../core/widgets/photo_placeholder.dart';
import '../../../core/widgets/skeleton_row.dart';
import '../domain/models/doctor.dart';

const List<String> _daysList = [
  'All Days',
  'Fri',
  'Sat',
  'Sun',
  'Mon',
  'Tue',
  'Wed',
  'Thu',
];

const List<String> _genderList = [
  'All',
  'Male',
  'Female',
];

String _dayLabel(String day, bool isBn) {
  if (!isBn) return day;
  switch (day) {
    case 'All Days':
      return 'সকল দিন';
    case 'Fri':
      return 'শুক্রবার';
    case 'Sat':
      return 'শনিবার';
    case 'Sun':
      return 'রবিবার';
    case 'Mon':
      return 'সোমবার';
    case 'Tue':
      return 'মঙ্গলবার';
    case 'Wed':
      return 'বুধবার';
    case 'Thu':
      return 'বৃহস্পতিবার';
    default:
      return day;
  }
}

String _genderLabel(String gender, bool isBn) {
  if (!isBn) return gender;
  switch (gender) {
    case 'All':
      return 'সকল';
    case 'Male':
      return 'পুরুষ';
    case 'Female':
      return 'মহিলা';
    default:
      return gender;
  }
}

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
  String? _hospital;
  String? _hospitalDisplayName;

  int? _divisionId;
  String? _divisionName;

  int? _districtId;
  String? _districtName;

  int? _thanaId;
  String? _thanaName;

  String? _selectedDay = 'All';
  String? _gender = 'All';
  String _searchQuery = '';

  bool _showFilters = false;

  final List<Doctor> _doctors = [];
  int _totalCount = 0;
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String? _errorMessage;

  final ScrollController _scrollController = ScrollController();

  int get _activeFiltersCount {
    int count = 0;
    if (_hospital != null && _hospital!.isNotEmpty && _hospital != 'all') {
      count++;
    }
    if (_divisionId != null ||
        (_divisionName != null &&
            _divisionName!.isNotEmpty &&
            _divisionName != 'All Bangladesh')) {
      count++;
    }
    if (_districtId != null ||
        (_districtName != null &&
            _districtName!.isNotEmpty &&
            _districtName != 'All Districts')) {
      count++;
    }
    if (_thanaId != null ||
        (_thanaName != null &&
            _thanaName!.isNotEmpty &&
            _thanaName != 'All Areas')) {
      count++;
    }
    if (_selectedDay != null &&
        _selectedDay != 'All' &&
        _selectedDay != 'All Days') {
      count++;
    }
    if (_gender != null && _gender != 'All') {
      count++;
    }
    return count;
  }

  bool get _hasActiveFilters =>
      _activeFiltersCount > 0 || (_specialty != null && _specialty!.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _specialty = widget.initialSpecialty;
    _divisionName = widget.initialDivision;
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

  void _resetAllFilters() {
    setState(() {
      _hospital = null;
      _hospitalDisplayName = null;
      _divisionId = null;
      _divisionName = null;
      _districtId = null;
      _districtName = null;
      _thanaId = null;
      _thanaName = null;
      _selectedDay = 'All';
      _gender = 'All';
    });
    _fetchDoctors(page: 1);
  }

  void _clearLocationFilters() {
    setState(() {
      _divisionId = null;
      _divisionName = null;
      _districtId = null;
      _districtName = null;
      _thanaId = null;
      _thanaName = null;
    });
    _fetchDoctors(page: 1);
  }

  void _clearAll() {
    setState(() {
      _specialty = null;
      _hospital = null;
      _hospitalDisplayName = null;
      _divisionId = null;
      _divisionName = null;
      _districtId = null;
      _districtName = null;
      _thanaId = null;
      _thanaName = null;
      _selectedDay = 'All';
      _gender = 'All';
      _searchQuery = '';
      _searchController.clear();
    });
    _fetchDoctors(page: 1);
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
        division: _divisionName,
        divisionId: _divisionId,
        district: _districtName,
        districtId: _districtId,
        area: _thanaName,
        thanaId: _thanaId,
        hospital: _hospital,
        day: (_selectedDay != null &&
                _selectedDay != 'All' &&
                _selectedDay != 'All Days')
            ? _selectedDay
            : null,
        gender: (_gender != null && _gender != 'All') ? _gender : null,
        page: page,
        pageSize: 20,
      );

      if (!mounted) return;
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
      if (!mounted) return;
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
    final facilitiesAsync = ref.watch(facilitiesProvider);
    final divisionsAsync = ref.watch(divisionsProvider);
    final districtsAsync = ref.watch(districtsProvider(_divisionId));
    final thanasAsync = ref.watch(thanasProvider(_districtId));

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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.65,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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

                      // Specialty Dropdown + Hideable Filter Toggle Button
                      Row(
                        children: [
                          Expanded(
                            child: specialtiesAsync.when(
                              data: (specialties) {
                                return SpecialtyDropdown(
                                  specialties: specialties,
                                  selectedSlug: _specialty ?? '',
                                  onChanged: (val) {
                                    setState(() => _specialty =
                                        val.isEmpty ? null : val);
                                    _fetchDoctors(page: 1);
                                  },
                                  isBn: isBn,
                                  allLabel: isBn
                                      ? 'সকল বিশেষজ্ঞ'
                                      : 'All Specialties',
                                  otherLabel:
                                      isBn ? 'অন্যান্য' : 'Other',
                                );
                              },
                              loading: () => const SkeletonRow(height: 48),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Hideable Filter Button
                          InkWell(
                            onTap: () {
                              setState(() {
                                _showFilters = !_showFilters;
                              });
                            },
                            child: Container(
                              height: 48,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: _showFilters || _activeFiltersCount > 0
                                    ? AppColors.ink
                                    : AppColors.paper,
                                border: Border.all(
                                  color: AppColors.ink,
                                  width: AppColors.borderWidth,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _showFilters ? Icons.close : Icons.tune,
                                    size: 20,
                                    color: _showFilters || _activeFiltersCount > 0
                                        ? AppColors.paper
                                        : AppColors.ink,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _showFilters
                                        ? (isBn ? 'লুকান' : 'Hide')
                                        : (isBn ? 'ফিল্টার' : 'Filters'),
                                    style: AppTypography.tag.copyWith(
                                      color:
                                          _showFilters || _activeFiltersCount > 0
                                              ? AppColors.paper
                                              : AppColors.ink,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (!_showFilters &&
                                      _activeFiltersCount > 0) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      color: AppColors.accent,
                                      child: Text(
                                        '$_activeFiltersCount',
                                        style: AppTypography.kicker.copyWith(
                                          color: AppColors.paper,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Collapsible Filter Panel
                      if (_showFilters) ...[
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(
                              color: AppColors.ink,
                              width: AppColors.borderWidth,
                            ),
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Panel Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.tune,
                                          size: 16, color: AppColors.ink),
                                      const SizedBox(width: 6),
                                      Text(
                                        isBn ? 'ফিল্টার অপশন' : 'FILTER OPTIONS',
                                        style: AppTypography.kicker
                                            .copyWith(fontSize: 12),
                                      ),
                                      if (_activeFiltersCount > 0) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 1),
                                          color: AppColors.accent,
                                          child: Text(
                                            '$_activeFiltersCount',
                                            style: AppTypography.kicker.copyWith(
                                              color: AppColors.paper,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (_activeFiltersCount > 0)
                                    InkWell(
                                      onTap: _resetAllFilters,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 2),
                                        child: Text(
                                          isBn ? 'সব রিসেট' : 'Reset All',
                                          style: AppTypography.tag.copyWith(
                                            color: AppColors.accent,
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(
                                  color: AppColors.ink,
                                  height: 1,
                                  thickness: 1),
                              const SizedBox(height: 12),

                              // 1. HOSPITAL & DIAGNOSTIC CENTER
                              Text(
                                isBn
                                    ? 'হাসপাতাল ও ডায়াগনস্টিক সেন্টার'
                                    : 'HOSPITAL & DIAGNOSTIC CENTER',
                                style:
                                    AppTypography.kicker.copyWith(fontSize: 11),
                              ),
                              const SizedBox(height: 6),
                              facilitiesAsync.when(
                                data: (facilities) {
                                  final sorted = facilities.toList()
                                    ..sort((a, b) =>
                                        a.name.compareTo(b.name));
                                  final items = [
                                    DhDropdownItem<String>(
                                      value: '',
                                      label: isBn
                                          ? 'সকল হাসপাতাল ও ডায়াগনস্টিক'
                                          : 'Select Hospital & Diagnostic Center',
                                    ),
                                    ...sorted.map(
                                      (f) => DhDropdownItem<String>(
                                        value: f.id.isNotEmpty
                                            ? f.id
                                            : f.slug,
                                        label: f.fullDisplayName,
                                      ),
                                    ),
                                  ];
                                  return DhDropdown<String>(
                                    value: _hospital ?? '',
                                    items: items,
                                    onChanged: (val) {
                                      setState(() {
                                        _hospital = (val != null &&
                                                val.isNotEmpty)
                                            ? val
                                            : null;
                                        final found = facilities
                                            .where((f) =>
                                                f.id == val || f.slug == val)
                                            .firstOrNull;
                                        _hospitalDisplayName =
                                            found?.fullDisplayName;
                                      });
                                      _fetchDoctors(page: 1);
                                    },
                                  );
                                },
                                loading: () =>
                                    const SkeletonRow(height: 48),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                              const SizedBox(height: 14),

                              // 2. LOCATION (DIVISION, DISTRICT, THANA/AREA)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isBn ? 'অবস্থান (লোকেশন)' : 'LOCATION',
                                    style: AppTypography.kicker
                                        .copyWith(fontSize: 11),
                                  ),
                                  if (_divisionId != null ||
                                      _districtId != null ||
                                      _thanaId != null ||
                                      (_divisionName != null &&
                                          _divisionName!.isNotEmpty &&
                                          _divisionName != 'All Bangladesh'))
                                    InkWell(
                                      onTap: _clearLocationFilters,
                                      child: Text(
                                        isBn ? 'মুছুন' : 'Clear',
                                        style: AppTypography.tag.copyWith(
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Division Dropdown
                              divisionsAsync.when(
                                data: (divisions) {
                                  final items = [
                                    DhDropdownItem<int?>(
                                      value: null,
                                      label: isBn
                                          ? 'সমগ্র বাংলাদেশ (বিভাগ)'
                                          : 'All Bangladesh (Division)',
                                    ),
                                    ...divisions.map(
                                      (d) => DhDropdownItem<int?>(
                                        value: d.id,
                                        label: d.localizedName(
                                            isBn ? 'bn' : 'en'),
                                      ),
                                    ),
                                  ];
                                  return DhDropdown<int?>(
                                    value: _divisionId,
                                    items: items,
                                    onChanged: (val) {
                                      final div = divisions
                                          .where((d) => d.id == val)
                                          .firstOrNull;
                                      setState(() {
                                        _divisionId = val;
                                        _divisionName = div?.name;
                                        _districtId = null;
                                        _districtName = null;
                                        _thanaId = null;
                                        _thanaName = null;
                                      });
                                      _fetchDoctors(page: 1);
                                    },
                                  );
                                },
                                loading: () =>
                                    const SkeletonRow(height: 48),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                              const SizedBox(height: 8),
                              // District Dropdown
                              districtsAsync.when(
                                data: (districts) {
                                  final items = [
                                    DhDropdownItem<int?>(
                                      value: null,
                                      label: isBn
                                          ? 'সকল জেলা'
                                          : 'All Districts',
                                    ),
                                    ...districts.map(
                                      (d) => DhDropdownItem<int?>(
                                        value: d.id,
                                        label: d.localizedName(
                                            isBn ? 'bn' : 'en'),
                                      ),
                                    ),
                                  ];
                                  return DhDropdown<int?>(
                                    value: _districtId,
                                    items: items,
                                    onChanged: (val) {
                                      final dist = districts
                                          .where((d) => d.id == val)
                                          .firstOrNull;
                                      setState(() {
                                        _districtId = val;
                                        _districtName = dist?.name;
                                        _thanaId = null;
                                        _thanaName = null;
                                      });
                                      _fetchDoctors(page: 1);
                                    },
                                  );
                                },
                                loading: () =>
                                    const SkeletonRow(height: 48),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                              const SizedBox(height: 8),
                              // Thana / Area Dropdown
                              thanasAsync.when(
                                data: (thanas) {
                                  final items = [
                                    DhDropdownItem<int?>(
                                      value: null,
                                      label: isBn
                                          ? 'সকল এলাকা / থানা'
                                          : 'All Areas / Thanas',
                                    ),
                                    ...thanas.map(
                                      (t) => DhDropdownItem<int?>(
                                        value: t.id,
                                        label: t.localizedName(
                                            isBn ? 'bn' : 'en'),
                                      ),
                                    ),
                                  ];
                                  return DhDropdown<int?>(
                                    value: _thanaId,
                                    items: items,
                                    onChanged: (val) {
                                      final th = thanas
                                          .where((t) => t.id == val)
                                          .firstOrNull;
                                      setState(() {
                                        _thanaId = val;
                                        _thanaName = th?.name;
                                      });
                                      _fetchDoctors(page: 1);
                                    },
                                  );
                                },
                                loading: () =>
                                    const SkeletonRow(height: 48),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                              const SizedBox(height: 14),

                              // 3. VISITING DAYS
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 14, color: AppColors.ink),
                                  const SizedBox(width: 6),
                                  Text(
                                    isBn ? 'রোগী দেখার দিন' : 'VISITING DAYS',
                                    style: AppTypography.kicker
                                        .copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              GridView.count(
                                crossAxisCount: 4,
                                mainAxisSpacing: 6,
                                crossAxisSpacing: 6,
                                childAspectRatio: 2.2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: _daysList.map((day) {
                                  final isActive = (day == 'All Days' &&
                                          (_selectedDay == null ||
                                              _selectedDay == 'All' ||
                                              _selectedDay == 'All Days')) ||
                                      (day != 'All Days' &&
                                          _selectedDay == day);

                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedDay =
                                            day == 'All Days' ? 'All' : day;
                                      });
                                      _fetchDoctors(page: 1);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? AppColors.ink
                                            : AppColors.paper,
                                        border: Border.all(
                                          color: AppColors.ink,
                                          width: 1.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _dayLabel(day, isBn),
                                        style: AppTypography.tag.copyWith(
                                          color: isActive
                                              ? AppColors.paper
                                              : AppColors.ink,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 14),

                              // 4. DOCTOR GENDER
                              Row(
                                children: [
                                  const Icon(Icons.person_outline,
                                      size: 14, color: AppColors.ink),
                                  const SizedBox(width: 6),
                                  Text(
                                    isBn ? 'ডাক্তারের লিঙ্গ' : 'DOCTOR GENDER',
                                    style: AppTypography.kicker
                                        .copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: _genderList.map((g) {
                                  final isActive = (g == 'All' &&
                                          (_gender == null ||
                                              _gender == 'All')) ||
                                      (g != 'All' &&
                                          _gender?.toLowerCase() ==
                                              g.toLowerCase());

                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _gender = g;
                                          });
                                          _fetchDoctors(page: 1);
                                        },
                                        child: Container(
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? AppColors.ink
                                                : AppColors.paper,
                                            border: Border.all(
                                              color: AppColors.ink,
                                              width: 1.5,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            _genderLabel(g, isBn),
                                            style: AppTypography.tag.copyWith(
                                              color: isActive
                                                  ? AppColors.paper
                                                  : AppColors.ink,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 14),

                              // Apply Filters CTA Button
                              InkWell(
                                onTap: () =>
                                    setState(() => _showFilters = false),
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    border: Border.all(
                                      color: AppColors.ink,
                                      width: AppColors.borderWidth,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check,
                                          size: 16, color: AppColors.paper),
                                      const SizedBox(width: 6),
                                      Text(
                                        isBn
                                            ? 'ফিল্টার প্রয়োগ করুন ($_totalCount)'
                                            : 'Apply Filters ($_totalCount)',
                                        style: AppTypography.button.copyWith(
                                          color: AppColors.paper,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Active Filter Chips
                      if (_hasActiveFilters) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (_specialty != null && _specialty!.isNotEmpty)
                              FilterChipDark(
                                label: _specialty!,
                                onDeleted: () {
                                  setState(() => _specialty = null);
                                  _fetchDoctors(page: 1);
                                },
                              ),
                            if (_hospital != null && _hospital!.isNotEmpty)
                              FilterChipDark(
                                label:
                                    'At ${_hospitalDisplayName ?? _hospital!}',
                                onDeleted: () {
                                  setState(() {
                                    _hospital = null;
                                    _hospitalDisplayName = null;
                                  });
                                  _fetchDoctors(page: 1);
                                },
                              ),
                            if (_divisionName != null &&
                                _divisionName!.isNotEmpty &&
                                _divisionName != 'All Bangladesh')
                              FilterChipDark(
                                label: _divisionName!,
                                onDeleted: () {
                                  setState(() {
                                    _divisionId = null;
                                    _divisionName = null;
                                    _districtId = null;
                                    _districtName = null;
                                    _thanaId = null;
                                    _thanaName = null;
                                  });
                                  _fetchDoctors(page: 1);
                                },
                              ),
                            if (_districtName != null &&
                                _districtName!.isNotEmpty &&
                                _districtName != 'All Districts')
                              FilterChipDark(
                                label: _districtName!,
                                onDeleted: () {
                                  setState(() {
                                    _districtId = null;
                                    _districtName = null;
                                    _thanaId = null;
                                    _thanaName = null;
                                  });
                                  _fetchDoctors(page: 1);
                                },
                              ),
                            if (_thanaName != null &&
                                _thanaName!.isNotEmpty &&
                                _thanaName != 'All Areas')
                              FilterChipDark(
                                label: _thanaName!,
                                onDeleted: () {
                                  setState(() {
                                    _thanaId = null;
                                    _thanaName = null;
                                  });
                                  _fetchDoctors(page: 1);
                                },
                              ),
                            if (_selectedDay != null &&
                                _selectedDay != 'All' &&
                                _selectedDay != 'All Days')
                              FilterChipDark(
                                label: _dayLabel(_selectedDay!, isBn),
                                onDeleted: () {
                                  setState(() => _selectedDay = 'All');
                                  _fetchDoctors(page: 1);
                                },
                              ),
                            if (_gender != null && _gender != 'All')
                              FilterChipDark(
                                label: _genderLabel(_gender!, isBn),
                                onDeleted: () {
                                  setState(() => _gender = 'All');
                                  _fetchDoctors(page: 1);
                                },
                              ),
                            // Clear all button
                            InkWell(
                              onTap: _resetAllFilters,
                              child: Container(
                                height: 32,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.paper,
                                  border: Border.all(
                                    color: AppColors.ink,
                                    width: 1.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  isBn ? 'সব মুছুন' : 'Clear all',
                                  style: AppTypography.tag.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
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
        onAction: _clearAll,
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
                      if (doctor.qualification != null &&
                          doctor.qualification!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          doctor.qualification!,
                          style: AppTypography.secondary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (doctor.academicTitle != null &&
                          doctor.academicTitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          doctor.academicTitle!,
                          style: AppTypography.secondaryBold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (doctor.institution != null &&
                          doctor.institution!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          doctor.institution!,
                          style: AppTypography.secondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (doctor.specialties.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: doctor.specialties
                    .map(
                      (s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration:
                            const BoxDecoration(color: AppColors.fill),
                        child: Text(
                          s.name,
                          style: AppTypography.tag,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
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
                Expanded(
                  child: Row(
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
                        Flexible(
                          child: Text(
                            isBn ? '${doctor.experience} অভিজ্ঞতা' : '${doctor.experience} exp',
                            style: AppTypography.secondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
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
