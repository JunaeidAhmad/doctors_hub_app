import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/date_strip.dart';
import '../../../core/widgets/dh_scaffold.dart';
import '../../../core/widgets/kicker.dart';
import '../../../core/widgets/phone_field.dart';
import '../../../core/widgets/sticky_cta_bar.dart';
import '../../booking/domain/models/booking_request.dart';
import '../../booking/presentation/booking_success_screen.dart';
import '../../bookings/domain/models/booking_item.dart';
import '../domain/models/diagnostic_test.dart';
import '../domain/models/facility_test.dart';

final singleTestDetailsProvider =
    FutureProvider.family<DiagnosticTest, String>((ref, testId) async {
  final repo = ref.watch(testRepositoryProvider);
  final res = await repo.getTests();
  return res.results.firstWhere(
    (t) => t.id == testId,
    orElse: () => DiagnosticTest(
      id: testId,
      name: 'Diagnostic Test',
      slug: 'test',
    ),
  );
});

class TestBookingScreen extends ConsumerStatefulWidget {
  const TestBookingScreen({
    super.key,
    required this.testId,
    required this.facilityTestId,
  });

  final String testId;
  final String facilityTestId;

  @override
  ConsumerState<TestBookingScreen> createState() => _TestBookingScreenState();
}

class _TestBookingScreenState extends ConsumerState<TestBookingScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  String? _nameError;
  String? _phoneError;
  String? _addressError;

  bool _isHomePickup = false;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTimeWindow = '7:00–9:00 AM';
  bool _isSubmitting = false;

  final List<String> _timeWindows = [
    '7:00–9:00 AM',
    '9:00–11:00 AM',
    '11:00 AM–1:00 PM',
    '4:00–6:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    final store = ref.read(localBookingStoreProvider);
    _nameController = TextEditingController(text: store.getLastPatientName() ?? '');
    _phoneController = TextEditingController(text: store.getLastPatientPhone() ?? '');
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Patient name is required');
      valid = false;
    } else {
      setState(() => _nameError = null);
    }

    if (!Validators.isValidBdPhone(_phoneController.text.trim())) {
      setState(() => _phoneError = 'Valid 11-digit mobile number required');
      valid = false;
    } else {
      setState(() => _phoneError = null);
    }

    if (_isHomePickup && _addressController.text.trim().isEmpty) {
      setState(() => _addressError = 'Address is required for home pickup');
      valid = false;
    } else {
      setState(() => _addressError = null);
    }

    return valid;
  }

  Future<void> _handleBookTest({
    required DiagnosticTest test,
    required FacilityTest facilityTest,
  }) async {
    if (!_validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(bookingRepositoryProvider);
      final rawPhone = Validators.normalizePhone(_phoneController.text.trim());
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final totalFee = facilityTest.price +
          (_isHomePickup ? facilityTest.homeSampleCharge : 0.0);

      final pickupSuffix = _isHomePickup
          ? ' | Home Pickup Address: ${_addressController.text.trim()}'
          : '';
      final notes = 'Window: $_selectedTimeWindow$pickupSuffix';

      final request = TestBookingRequest(
        facilityTestId: facilityTest.id,
        pickupDate: dateStr,
        patientName: _nameController.text.trim(),
        patientPhone: rawPhone,
        pickupAddressLine: _isHomePickup ? _addressController.text.trim() : null,
        notes: notes,
      );

      final response = await repo.bookTest(request);

      final bookingItem = BookingItem(
        id: response.id.isNotEmpty
            ? response.id
            : 'TEST-${DateTime.now().millisecondsSinceEpoch}',
        bookingRef: response.bookingRef,
        serialDisplay: response.serialDisplay,
        serialNumber: response.serialNumber,
        type: 'test',
        title: test.name,
        subtitle: facilityTest.fullFacilityDisplayName,
        facilityName: facilityTest.fullFacilityDisplayName,
        appointmentDate: _selectedDate,
        timeSlot: _selectedTimeWindow,
        patientName: _nameController.text.trim(),
        patientPhone: rawPhone,
        fee: totalFee,
        paymentMethod: 'counter',
        facilityPhone: facilityTest.facilityPhone,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await ref.read(localBookingsProvider.notifier).addBooking(bookingItem);
      ref.read(lastBookingSuccessProvider.notifier).state = bookingItem;

      if (mounted) {
        context.go('/success');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final testAsync = ref.watch(singleTestDetailsProvider(widget.testId));
    final locale = ref.watch(localeProvider);
    final isBn = locale.languageCode == 'bn';

    return testAsync.when(
      data: (test) {
        final facilityTest = FacilityTest(
          id: widget.facilityTestId,
          testId: test.id,
          testName: test.name,
          facilityId: 'facility-1',
          facilityName: 'Popular Diagnostic Center',
          price: test.minPrice ?? 800.0,
          homeSampleCollection: true,
          homeSampleCharge: 150.0,
        );

        final totalFee = facilityTest.price +
            (_isHomePickup ? facilityTest.homeSampleCharge : 0.0);

        final dates = List.generate(7, (i) {
          final d = DateTime.now().add(Duration(days: i + 1));
          return DateStripItem(date: d, isAvailable: true);
        });

        return DhScaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header bar
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
                        isBn ? 'টেস্ট বুকিং' : 'Book a Test',
                        style: AppTypography.h2.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Kicker(isBn ? 'ডায়াগনস্টিক টেস্ট' : 'DIAGNOSTIC TEST'),
                        const SizedBox(height: 4),
                        Text(
                          test.localizedName(isBn ? 'bn' : 'en'),
                          style: AppTypography.h1.copyWith(fontSize: 22),
                        ),
                        Text(
                          facilityTest.fullFacilityDisplayName,
                          style: AppTypography.secondary,
                        ),
                        const SizedBox(height: 16),

                        // Fasting banner if required
                        if (test.fastingRequired) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accentWash,
                              border: Border.all(
                                color: AppColors.accent,
                                width: AppColors.borderWidth,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.accent,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    isBn
                                        ? 'এই টেস্টের জন্য ৮–১২ ঘণ্টা না খেয়ে থাকা আবশ্যক।'
                                        : 'Fasting required: Please fast for 8–12 hours before sample collection.',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.accentDeep,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Sample collection choice
                        Text(
                          isBn ? 'স্যাম্পল কালেকশন পদ্ধতি' : 'Sample Collection',
                          style: AppTypography.h2.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _isHomePickup = false),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: !_isHomePickup
                                        ? AppColors.ink
                                        : AppColors.paper,
                                    border: Border.all(
                                      color: AppColors.ink,
                                      width: AppColors.borderWidth,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    isBn ? 'ল্যাবে গিয়ে' : 'Visit Lab',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontArchivo,
                                      fontWeight: FontWeight.w700,
                                      color: !_isHomePickup
                                          ? AppColors.paper
                                          : AppColors.ink,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: facilityTest.homeSampleCollection
                                    ? () => setState(() => _isHomePickup = true)
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _isHomePickup
                                        ? AppColors.ink
                                        : (facilityTest.homeSampleCollection
                                            ? AppColors.paper
                                            : AppColors.fillOff),
                                    border: Border.all(
                                      color: facilityTest.homeSampleCollection
                                          ? AppColors.ink
                                          : AppColors.lineSoft,
                                      width: AppColors.borderWidth,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    isBn
                                        ? 'হোম পিকআপ (+৳${facilityTest.homeSampleCharge.toInt()})'
                                        : 'Home (+৳${facilityTest.homeSampleCharge.toInt()})',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontArchivo,
                                      fontWeight: FontWeight.w700,
                                      color: _isHomePickup
                                          ? AppColors.paper
                                          : (facilityTest.homeSampleCollection
                                              ? AppColors.ink
                                              : AppColors.mutedLight),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Home address if pickup selected
                        if (_isHomePickup) ...[
                          const SizedBox(height: 16),
                          Text(
                            isBn ? 'পিকআপ ঠিকানা' : 'Pickup Address',
                            style: AppTypography.secondaryBold,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.paper,
                              border: Border.all(
                                color: _addressError != null
                                    ? AppColors.accent
                                    : AppColors.ink,
                                width: AppColors.borderWidth,
                              ),
                            ),
                            child: TextField(
                              controller: _addressController,
                              style: AppTypography.body,
                              decoration: InputDecoration(
                                hintText: isBn
                                    ? 'বাড়ি, রোড, এলাকা লিখুন...'
                                    : 'House, Road, Area, Landmark...',
                                isDense: true,
                                contentPadding: const EdgeInsets.all(12),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (_addressError != null) ...[
                            const SizedBox(height: 4),
                            Text(_addressError!, style: AppTypography.tagAccent),
                          ],
                        ],

                        const SizedBox(height: 24),

                        // Preferred Date
                        Text(
                          isBn ? 'তারিখ নির্বাচন' : 'Preferred Date',
                          style: AppTypography.h2.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        DateStrip(
                          dates: dates,
                          selectedDate: _selectedDate,
                          onDateSelected: (d) => setState(() => _selectedDate = d),
                        ),

                        const SizedBox(height: 24),

                        // Preferred Time Window
                        Text(
                          isBn ? 'পছন্দের সময়' : 'Preferred Time Window',
                          style: AppTypography.h2.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _timeWindows.map((tw) {
                            final isSel = _selectedTimeWindow == tw;
                            return InkWell(
                              onTap: () => setState(() => _selectedTimeWindow = tw),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.accent : AppColors.paper,
                                  border: Border.all(
                                    color: AppColors.ink,
                                    width: AppColors.borderWidth,
                                  ),
                                ),
                                child: Text(
                                  tw,
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontMono,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSel ? AppColors.paper : AppColors.ink,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Patient Info Block
                        Text(
                          isBn ? 'রোগীর তথ্য' : 'Patient Information',
                          style: AppTypography.h2.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isBn ? 'রোগীর পুরো নাম' : 'Patient Name',
                          style: AppTypography.secondaryBold,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.paper,
                            border: Border.all(
                              color: _nameError != null
                                  ? AppColors.accent
                                  : AppColors.ink,
                              width: AppColors.borderWidth,
                            ),
                          ),
                          child: TextField(
                            controller: _nameController,
                            style: AppTypography.body,
                            decoration: InputDecoration(
                              hintText: isBn ? 'পুরো নাম লিখুন' : 'Enter full name',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_nameError != null) ...[
                          const SizedBox(height: 4),
                          Text(_nameError!, style: AppTypography.tagAccent),
                        ],

                        const SizedBox(height: 16),
                        Text(
                          isBn ? 'মোবাইল নম্বর' : 'Mobile Number',
                          style: AppTypography.secondaryBold,
                        ),
                        const SizedBox(height: 6),
                        PhoneField(
                          controller: _phoneController,
                          errorText: _phoneError,
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Sticky CTA
                StickyCtaBar(
                  kicker: isBn ? 'মোট খরচ' : 'TOTAL AMOUNT',
                  subtitle: CurrencyFormatter.format(
                    totalFee,
                    locale: isBn ? 'bn' : 'en',
                  ),
                  buttonLabel: isBn ? 'টেস্ট বুক করুন' : 'Confirm booking',
                  isLoading: _isSubmitting,
                  onPressed: () => _handleBookTest(
                    test: test,
                    facilityTest: facilityTest,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const DhScaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      ),
      error: (err, _) => DhScaffold(
        body: Center(child: Text(err.toString())),
      ),
    );
  }
}
