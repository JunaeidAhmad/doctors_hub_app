import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/dh_dropdown.dart';
import '../../../core/widgets/dh_scaffold.dart';
import '../../../core/widgets/dh_search_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/filter_chip_dark.dart';
import '../../../core/widgets/kicker.dart';
import '../../../core/widgets/skeleton_row.dart';
import '../domain/models/diagnostic_test.dart';
import '../domain/models/facility_test.dart';

class TestsCatalogueScreen extends ConsumerStatefulWidget {
  const TestsCatalogueScreen({
    super.key,
    this.initialCategory,
    this.initialSearch,
    this.initialDivision,
  });

  final String? initialCategory;
  final String? initialSearch;
  final String? initialDivision;

  @override
  ConsumerState<TestsCatalogueScreen> createState() =>
      _TestsCatalogueScreenState();
}

class _TestsCatalogueScreenState extends ConsumerState<TestsCatalogueScreen> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  String? _category;
  String? _division;
  String _searchQuery = '';

  final List<DiagnosticTest> _tests = [];
  int _totalCount = 0;
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String? _errorMessage;

  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _expandedTests = {};
  final Map<String, List<FacilityTest>> _facilityTestsMap = {};

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _division = widget.initialDivision;
    _searchQuery = widget.initialSearch ?? '';
    _searchController = TextEditingController(text: _searchQuery);

    _scrollController.addListener(_onScroll);
    _fetchTests(page: 1);
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
      _fetchTests(page: _currentPage + 1, isLoadMore: true);
    }
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      setState(() => _searchQuery = val);
      _fetchTests(page: 1);
    });
  }

  Future<void> _fetchTests({required int page, bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final repo = ref.read(testRepositoryProvider);
      final result = await repo.getTests(
        category: _category,
        search: _searchQuery,
        page: page,
        pageSize: 20,
      );

      setState(() {
        if (isLoadMore) {
          _tests.addAll(result.results);
          _isLoadingMore = false;
        } else {
          _tests.clear();
          _tests.addAll(result.results);
          _isLoading = false;
        }
        _totalCount = result.count;
        _currentPage = page;
        _hasMore = result.hasMore;
      });

      // Load facility tests for the first few items
      for (final test in result.results.take(5)) {
        _loadLabsForTest(test.id);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadLabsForTest(String testId) async {
    if (_facilityTestsMap.containsKey(testId)) return;
    try {
      final repo = ref.read(testRepositoryProvider);
      final labs = await repo.getFacilityTestsForTest(testId, division: _division);
      if (mounted) {
        setState(() {
          _facilityTestsMap[testId] = labs;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isBn = locale.languageCode == 'bn';
    final categoriesAsync = ref.watch(testCategoriesProvider);

    return DhScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Filter / Search Bar
            Container(
              color: AppColors.paper,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Kicker(
                    isBn
                        ? '$_totalCount টি টেস্ট · ডায়াগনস্টিক'
                        : '$_totalCount TESTS · DIAGNOSTICS',
                  ),
                  const SizedBox(height: 10),
                  DhSearchField(
                    controller: _searchController,
                    hintText: isBn
                        ? 'টেস্টের নাম লিখে খুঁজুন...'
                        : 'Search test name (e.g. CBC, Lipid Profile)...',
                    onChanged: _onSearchChanged,
                    onClear: () {
                      _debounceTimer?.cancel();
                      setState(() => _searchQuery = '');
                      _fetchTests(page: 1);
                    },
                  ),
                  const SizedBox(height: 10),
                  // Categories Dropdown
                  categoriesAsync.when(
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
                        value: _category ?? '',
                        items: items,
                        onChanged: (val) {
                          setState(() => _category = val);
                          _fetchTests(page: 1);
                        },
                      );
                    },
                    loading: () => const SkeletonRow(height: 48),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // Division Chip if filtered
                  if (_division != null && _division!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    FilterChipDark(
                      label: _division!,
                      onDeleted: () {
                        setState(() => _division = null);
                        _facilityTestsMap.clear();
                        _fetchTests(page: 1);
                      },
                    ),
                  ],
                ],
              ),
            ),
            const Divider(color: AppColors.ink, height: 1),

            // Tests List Content
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
        itemBuilder: (_, __) => const SkeletonRow(height: 160),
      );
    }

    if (_errorMessage != null) {
      return ErrorState(
        message: _errorMessage!,
        onRetry: () => _fetchTests(page: 1),
      );
    }

    if (_tests.isEmpty) {
      return EmptyState(
        title: isBn ? 'কোন টেস্ট পাওয়া যায়নি' : 'No tests found',
        message: isBn
            ? 'অন্য কোনো টেস্টের নাম দিয়ে খুঁজুন।'
            : 'Try adjusting your search query or category.',
        actionLabel: isBn ? 'ফিল্টার মুছুন' : 'Clear filters',
        onAction: () {
          setState(() {
            _category = null;
            _division = null;
            _searchQuery = '';
            _searchController.clear();
          });
          _fetchTests(page: 1);
        },
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () => _fetchTests(page: 1),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _tests.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == _tests.length) {
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

          final test = _tests[index];
          return _buildTestCard(context, test, isBn);
        },
      ),
    );
  }

  Widget _buildTestCard(BuildContext context, DiagnosticTest test, bool isBn) {
    final isExpanded = _expandedTests[test.id] ?? false;
    final labs = _facilityTestsMap[test.id] ?? [];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(color: AppColors.ink, width: AppColors.borderWidth),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags row
          Row(
            children: [
              if (test.categoryName != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(color: AppColors.fill),
                  child: Text(
                    test.categoryName!.toUpperCase(),
                    style: AppTypography.tag,
                  ),
                ),
              const SizedBox(width: 6),
              if (test.reportTimeHours != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(color: AppColors.fill),
                  child: Text(
                    isBn
                        ? 'রিপোর্ট ${test.reportTimeHours} ঘণ্টায়'
                        : 'Report in ${test.reportTimeHours}h',
                    style: AppTypography.tag,
                  ),
                ),
              const SizedBox(width: 6),
              if (test.fastingRequired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(color: AppColors.accentTint),
                  child: Text(
                    isBn ? 'না খেয়ে থাকা আবশ্যক' : 'Fasting req.',
                    style: AppTypography.tagAccent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Test Title
          Text(
            test.localizedName(isBn ? 'bn' : 'en'),
            style: AppTypography.h2.copyWith(fontSize: 17),
          ),

          if (test.description != null && test.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              test.description!,
              style: AppTypography.secondary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 10),

          // Usual Price Range
          if (test.minPrice != null && test.maxPrice != null)
            Text(
              isBn
                  ? 'আনুমানিক খরচ: ${CurrencyFormatter.format(test.minPrice, locale: 'bn')} – ${CurrencyFormatter.format(test.maxPrice, locale: 'bn')}'
                  : 'Usual price: ৳${test.minPrice!.toInt()} – ৳${test.maxPrice!.toInt()}',
              style: AppTypography.secondaryBold.copyWith(color: AppColors.ink2),
            ),

          const SizedBox(height: 12),
          const Divider(color: AppColors.lineSoft, height: 1),
          const SizedBox(height: 10),

          // Offering Labs
          if (labs.isNotEmpty) ...[
            ...((isExpanded ? labs : labs.take(2)).map((lab) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.lineSoft, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lab.fullFacilityDisplayName,
                            style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            lab.homeSampleCollection
                                ? (isBn ? 'হোম স্যাম্পল কালেকশন উপলব্ধ' : 'Home pickup available')
                                : (isBn ? 'শুধুমাত্র ল্যাবে' : 'At lab only'),
                            style: AppTypography.secondary.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.format(lab.price, locale: isBn ? 'bn' : 'en'),
                          style: AppTypography.h2.copyWith(
                            fontSize: 15,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () {
                            context.push('/tests/${test.id}/labs/${lab.id}/book');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.ink,
                            ),
                            child: Text(
                              isBn ? 'বুক করুন' : 'Book',
                              style: const TextStyle(
                                fontFamily: AppTypography.fontArchivo,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.paper,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            })),

            if (labs.length > 2)
              InkWell(
                onTap: () => setState(() => _expandedTests[test.id] = !isExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isExpanded
                            ? (isBn ? 'কম ল্যাব দেখুন ▲' : 'Show fewer labs ▲')
                            : (isBn ? '+ আরও ${labs.length - 2} টি ল্যাব দেখুন ▼' : '+ ${labs.length - 2} more labs ▼'),
                        style: const TextStyle(
                          fontFamily: AppTypography.fontArchivo,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentLink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ] else ...[
            InkWell(
              onTap: () => _loadLabsForTest(test.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  isBn ? 'ল্যাব ও খরচ দেখুন →' : 'View labs offering this test →',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontArchivo,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentLink,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
