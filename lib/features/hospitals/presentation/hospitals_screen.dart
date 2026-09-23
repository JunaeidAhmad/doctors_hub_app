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
  const HospitalsScreen({super.key});

  @override
  ConsumerState<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends ConsumerState<HospitalsScreen> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  String? _category;
  String? _division;
  String _searchQuery = '';

  final List<Hospital> _hospitals = [];
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
    _searchController = TextEditingController();
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
        division: _division,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  categoriesAsync.when(
                    data: (categories) {
                      final items = [
                        DhDropdownItem<String>(
                          value: '',
                          label: isBn ? 'সকল হাসপাতাল' : 'All Facility Categories',
                        ),
                        ...categories.map(
                          (c) => DhDropdownItem<String>(
                            value: c.slug,
                            label: c.localizedName(isBn ? 'bn' : 'en'),
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
                  if (_division != null && _division!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    FilterChipDark(
                      label: _division!,
                      onDeleted: () {
                        setState(() => _division = null);
                        _fetchHospitals(page: 1);
                      },
                    ),
                  ],
                ],
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
            ? 'অনুসন্ধানের শব্দ পরিবর্তন করুন।'
            : 'Try adjusting your search query.',
        actionLabel: isBn ? 'ফিল্টার মুছুন' : 'Clear filters',
        onAction: () {
          setState(() {
            _category = null;
            _division = null;
            _searchQuery = '';
            _searchController.clear();
          });
          _fetchHospitals(page: 1);
        },
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
