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
import '../../../core/widgets/skeleton_row.dart';
import '../domain/models/hospital.dart';

class HospitalsScreen extends ConsumerStatefulWidget {
  const HospitalsScreen({
    super.key,
    this.initialCategory,
    this.initialDivision,
    this.initialSearch,
  });

  final String? initialCategory;
  final String? initialDivision;
  final String? initialSearch;

  @override
  ConsumerState<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends ConsumerState<HospitalsScreen> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  String? _category;
  int? _divisionId;
  String? _divisionName;
  int? _districtId;
  String? _districtName;
  int? _thanaId;
  String? _thanaName;
  String _ownershipType = 'all';
  bool _showFilters = false;
  String _searchQuery = '';

  final List<Hospital> _hospitals = [];
  int _totalCount = 0;
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String? _errorMessage;

  final ScrollController _scrollController = ScrollController();

  static const _ownershipOptions = [
    'all',
    'private',
    'government',
    'ngo',
  ];

  String _ownershipLabel(String key, bool isBn) {
    switch (key) {
      case 'private':
        return isBn ? 'বেসরকারি' : 'Private';
      case 'government':
        return isBn ? 'সরকারি' : 'Govt';
      case 'ngo':
        return isBn ? 'এনজিও' : 'NGO';
      case 'all':
      default:
        return isBn ? 'সকল' : 'All';
    }
  }

  int get _activeFiltersCount {
    int count = 0;
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
    if (_ownershipType != 'all') {
      count++;
    }
    return count;
  }

  bool get _hasActiveFilters =>
      _activeFiltersCount > 0 || (_category != null && _category!.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _divisionName = widget.initialDivision;
    _searchQuery = widget.initialSearch ?? '';
    _searchController = TextEditingController(text: _searchQuery);
    _scrollController.addListener(_onScroll);
    _fetchHospitals(page: 1);
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
      _fetchHospitals(page: _currentPage + 1, isLoadMore: true);
    }
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      setState(() => _searchQuery = val);
      _fetchHospitals(page: 1);
    });
  }

  void _resetAllFilters() {
    setState(() {
      _divisionId = null;
      _divisionName = null;
      _districtId = null;
      _districtName = null;
      _thanaId = null;
      _thanaName = null;
      _ownershipType = 'all';
    });
    _fetchHospitals(page: 1);
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
    _fetchHospitals(page: 1);
  }

  void _clearAll() {
    setState(() {
      _category = null;
      _divisionId = null;
      _divisionName = null;
      _districtId = null;
      _districtName = null;
      _thanaId = null;
      _thanaName = null;
      _ownershipType = 'all';
      _searchQuery = '';
      _searchController.clear();
    });
    _fetchHospitals(page: 1);
  }

  Future<void> _fetchHospitals({required int page, bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final repo = ref.read(hospitalRepositoryProvider);
      final result = await repo.getHospitals(
        category: _category,
        division: _divisionName,
        divisionId: _divisionId,
        district: _districtName,
        districtId: _districtId,
        area: _thanaName,
        thanaId: _thanaId,
        ownershipType: _ownershipType != 'all' ? _ownershipType : null,
        search: _searchQuery,
        page: page,
        pageSize: 20,
      );

      setState(() {
        if (isLoadMore) {
          _hospitals.addAll(result.results);
          _isLoadingMore = false;
        } else {
          _hospitals.clear();
          _hospitals.addAll(result.results);
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
    final categoriesAsync = ref.watch(hospitalCategoriesProvider);
    final divisionsAsync = ref.watch(divisionsProvider);
    final districtsAsync = ref.watch(districtsProvider(_divisionId));
    final thanasAsync = ref.watch(thanasProvider(_districtId));

    return DhScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                color: AppColors.paper,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.ink,
                    width: AppColors.borderWidth,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'হাসপাতাল ও সেন্টার' : 'Hospitals & Diagnostics',
                    style: AppTypography.h2.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),

            // Filter Bar
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
                            ? '$_totalCount টি হাসপাতাল · তালিকা'
                            : '$_totalCount FACILITIES · DIRECTORY',
                      ),
                      const SizedBox(height: 10),
                      DhSearchField(
                        controller: _searchController,
                        hintText: isBn
                            ? 'হাসপাতাল বা এলাকার নাম খুঁজুন...'
                            : 'Search hospital name or area...',
                        onChanged: _onSearchChanged,
                        onClear: () {
                          _debounceTimer?.cancel();
                          setState(() => _searchQuery = '');
                          _fetchHospitals(page: 1);
                        },
                      ),
                      const SizedBox(height: 10),

                      // Category Dropdown + Hideable Filter Toggle Button
                      Row(
                        children: [
                          Expanded(
                            child: categoriesAsync.when(
                              data: (categories) {
                                final items = [
                                  DhDropdownItem<String>(
                                    value: '',
                                    label: isBn
                                        ? 'সকল হাসপাতাল'
                                        : 'All Facility Categories',
                                  ),
                                  ...categories.map(
                                    (c) => DhDropdownItem<String>(
                                      value: c.slug,
                                      label:
                                          c.localizedName(isBn ? 'bn' : 'en'),
                                    ),
                                  ),
                                ];
                                return DhDropdown<String>(
                                  value: _category ?? '',
                                  items: items,
                                  onChanged: (val) {
                                    setState(() => _category = val);
                                    _fetchHospitals(page: 1);
                                  },
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
                                    color:
                                        _showFilters || _activeFiltersCount > 0
                                            ? AppColors.paper
                                            : AppColors.ink,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _showFilters
                                        ? (isBn ? 'লুকান' : 'Hide')
                                        : (isBn ? 'ফিল্টার' : 'Filters'),
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontMono,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _showFilters ||
                                              _activeFiltersCount > 0
                                          ? AppColors.paper
                                          : AppColors.ink,
                                    ),
                                  ),
                                  if (_activeFiltersCount > 0) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _showFilters
                                            ? AppColors.accent
                                            : AppColors.paper,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$_activeFiltersCount',
                                        style: TextStyle(
                                          fontFamily:
                                              AppTypography.fontMono,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: _showFilters
                                              ? AppColors.paper
                                              : AppColors.ink,
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
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.fill,
                            border: Border.all(
                              color: AppColors.ink,
                              width: AppColors.borderWidth,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                        isBn
                                            ? 'ফিল্টার অপশন'
                                            : 'FILTER OPTIONS',
                                        style: AppTypography.kicker.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (_activeFiltersCount > 0) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '$_activeFiltersCount',
                                            style: const TextStyle(
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

                              // 1. LOCATION (DIVISION, DISTRICT, THANA/AREA)
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
                                      _fetchHospitals(page: 1);
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
                                      _fetchHospitals(page: 1);
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
                                      final thana = thanas
                                          .where((t) => t.id == val)
                                          .firstOrNull;
                                      setState(() {
                                        _thanaId = val;
                                        _thanaName = thana?.name;
                                      });
                                      _fetchHospitals(page: 1);
                                    },
                                  );
                                },
                                loading: () =>
                                    const SkeletonRow(height: 48),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                              const SizedBox(height: 14),

                              // 2. OWNERSHIP TYPE
                              Row(
                                children: [
                                  const Icon(Icons.business,
                                      size: 15, color: AppColors.ink),
                                  const SizedBox(width: 6),
                                  Text(
                                    isBn
                                        ? 'মালিকানার ধরণ'
                                        : 'OWNERSHIP TYPE',
                                    style: AppTypography.kicker
                                        .copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: _ownershipOptions.map((opt) {
                                  final isActive = _ownershipType.toLowerCase() ==
                                      opt.toLowerCase();
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() => _ownershipType = opt);
                                          _fetchHospitals(page: 1);
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
                                            _ownershipLabel(opt, isBn),
                                            style: AppTypography.tag.copyWith(
                                              color: isActive
                                                  ? AppColors.paper
                                                  : AppColors.ink,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
                            if (_category != null && _category!.isNotEmpty)
                              FilterChipDark(
                                label: _category!,
                                onDeleted: () {
                                  setState(() => _category = null);
                                  _fetchHospitals(page: 1);
                                },
                              ),
                            if (_divisionName != null &&
                                _divisionName!.isNotEmpty &&
                                _divisionName != 'All Bangladesh')
                              FilterChipDark(
                                label: 'Div: $_divisionName',
                                onDeleted: () {
                                  setState(() {
                                    _divisionId = null;
                                    _divisionName = null;
                                    _districtId = null;
                                    _districtName = null;
                                    _thanaId = null;
                                    _thanaName = null;
                                  });
                                  _fetchHospitals(page: 1);
                                },
                              ),
                            if (_districtName != null &&
                                _districtName!.isNotEmpty &&
                                _districtName != 'All Districts')
                              FilterChipDark(
                                label: 'Dist: $_districtName',
                                onDeleted: () {
                                  setState(() {
                                    _districtId = null;
                                    _districtName = null;
                                    _thanaId = null;
                                    _thanaName = null;
                                  });
                                  _fetchHospitals(page: 1);
                                },
                              ),
                            if (_thanaName != null &&
                                _thanaName!.isNotEmpty &&
                                _thanaName != 'All Areas')
                              FilterChipDark(
                                label: 'Area: $_thanaName',
                                onDeleted: () {
                                  setState(() {
                                    _thanaId = null;
                                    _thanaName = null;
                                  });
                                  _fetchHospitals(page: 1);
                                },
                              ),
                            if (_ownershipType != 'all')
                              FilterChipDark(
                                label: _ownershipLabel(_ownershipType, isBn),
                                onDeleted: () {
                                  setState(() => _ownershipType = 'all');
                                  _fetchHospitals(page: 1);
                                },
                              ),
                            InkWell(
                              onTap: _clearAll,
                              child: Container(
                                height: 32,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.fill,
                                  border: Border.all(
                                    color: AppColors.ink,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  isBn ? 'সব মুছুন' : 'Clear all',
                                  style: AppTypography.tag.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
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
            const Divider(color: AppColors.ink, height: 1),

            // Hospitals List
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
        itemBuilder: (_, __) => const SkeletonRow(height: 80),
      );
    }

    if (_errorMessage != null) {
      return ErrorState(
        message: _errorMessage!,
        onRetry: () => _fetchHospitals(page: 1),
      );
    }

    if (_hospitals.isEmpty) {
      return EmptyState(
        title: isBn ? 'কোন হাসপাতাল পাওয়া যায়নি' : 'No hospitals found',
        message: isBn
            ? 'অনুসন্ধানের শব্দ বা ফিল্টার পরিবর্তন করুন।'
            : 'Try adjusting your search query or filters.',
        actionLabel: isBn ? 'ফিল্টার মুছুন' : 'Clear filters',
        onAction: _clearAll,
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () => _fetchHospitals(page: 1),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _hospitals.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == _hospitals.length) {
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

          final h = _hospitals[index];
          return InkWell(
            onTap: () {
              context.push('/doctors?hospital=${Uri.encodeComponent(h.name)}');
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.paper,
                border: Border.all(
                  color: AppColors.ink,
                  width: AppColors.borderWidth,
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.fill,
                      border: Border.all(color: AppColors.ink, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      h.initials,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontArchivo,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.localizedName(isBn ? 'bn' : 'en'),
                          style: AppTypography.h2.copyWith(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${h.category ?? 'Hospital'} · ${h.area ?? h.division ?? ''}',
                          style: AppTypography.secondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (h.doctorCount != null && h.doctorCount! > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: AppColors.fill,
                      ),
                      child: Text(
                        isBn ? '${h.doctorCount} জন ডাক্তার' : '${h.doctorCount} docs',
                        style: AppTypography.tag,
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: AppColors.ink, size: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
