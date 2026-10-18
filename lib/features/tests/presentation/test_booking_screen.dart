import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/network/app_failure.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/dhaka_time.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/date_strip.dart';
import '../../../core/widgets/dh_dropdown.dart';
import '../../../core/widgets/dh_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/kicker.dart';
import '../../../core/widgets/otp_sheet.dart';
import '../../../core/widgets/phone_field.dart';
import '../../../core/widgets/skeleton_row.dart';
import '../../../core/widgets/sticky_cta_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../booking/domain/models/booking_request.dart';
import '../../booking/presentation/booking_success_screen.dart';
import '../../bookings/domain/models/booking_item.dart';
import '../domain/models/test_search.dart';
import 'test_selection_provider.dart';

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
  late final TextEditingController _ageController;
  late final TextEditingController _addressController;

  String? _nameError;
  String? _phoneError;
  String? _addressError;
  String? _thanaError;
  String? _facilityTestError;
  String? _gender;

  bool _isHomePickup = false;
  int? _divisionId;
  int? _districtId;
  int? _thanaId;

  DateTime _selectedDate = DateTime.parse(DhakaTime.todayIso());
  String _selectedTimeWindow = '7:00–9:00 am';
  bool _didInitSelection = false;

  static const List<String> _timeWindows = [
    '7:00–9:00 am',
    '9:00–11:00 am',
    '11:00 am–1:00 pm',
    '4:00–6:00 pm',
  ];

  /// Window label → `preferred_time` start ("HH:MM") sent to the API.
  static const Map<String, String> _windowStart = {
    '7:00–9:00 am': '07:00',
    '9:00–11:00 am': '09:00',
    '11:00 am–1:00 pm': '11:00',
    '4:00–6:00 pm': '16:00',
  };

  @override
  void initState() {
    super.initState();
    final store = ref.read(localBookingStoreProvider);
    _nameController =
        TextEditingController(text: store.getLastPatientName() ?? '');
    _phoneController =
        TextEditingController(text: store.getLastPatientPhone() ?? '');
    _ageController = TextEditingController();
    _addressController = TextEditingController();

    final selection = ref.read(testBookingSelectionProvider);
    if (selection != null) {
      _divisionId = selection.divisionId;
      _districtId = selection.districtId;
      _thanaId = selection.thanaId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool _validate(AppLocalizations l10n) {
    bool valid = true;
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = l10n.nameRequired);
      valid = false;
    } else {
      setState(() => _nameError = null);
    }

    if (!Validators.isValidBdPhone(_phoneController.text.trim())) {
      setState(() => _phoneError = l10n.invalidPhone);
      valid = false;
    } else {
      setState(() => _phoneError = null);
    }

    if (_isHomePickup) {
      if (_thanaId == null) {
        setState(() => _thanaError = l10n.pickupThanaRequired);
        valid = false;
      } else {
        setState(() => _thanaError = null);
      }
      if (_addressController.text.trim().isEmpty) {
        setState(() => _addressError = l10n.addressRequired);
        valid = false;
      } else {
        setState(() => _addressError = null);
      }
    }

    return valid;
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(testBookingSelectionProvider);
    final locale = ref.watch(localeProvider);
    final isBn = locale.languageCode == 'bn';
    final l10n = AppLocalizations.of(context)!;

    if (selection == null ||
        !selection.matches(widget.testId, widget.facilityTestId)) {
      return DhScaffold(
        body: SafeArea(
          child: EmptyState(
            title: l10n.testNotLoaded,
            message: l10n.testNotLoadedDesc,
            actionLabel: l10n.backToTests,
            onAction: () => context.go('/tests'),
          ),
        ),
      );
    }

    if (!_didInitSelection) {
      _didInitSelection = true;
      final cached = ref.read(testBookingSelectionProvider);
      _divisionId = cached?.divisionId ?? _divisionId;
      _districtId = cached?.districtId ?? _districtId;
      _thanaId = cached?.thanaId ?? _thanaId;
    }

    final group = selection.group;
    final offering = selection.offering;
    final shownPrice = offering.shownPrice;
    final total = shownPrice == null
        ? null
        : shownPrice +
            (_isHomePickup ? (offering.homeSampleCharge ?? 0) : 0);
    final dates = List.generate(7, (i) {
      final today = DateTime.parse(DhakaTime.todayIso());
      final d = today.add(Duration(days: i));
      return DateStripItem(date: d, isAvailable: true);
    });
    final divisionsAsync = ref.watch(divisionsProvider);
    final districtsAsync = ref.watch(districtsProvider(_divisionId));
    final thanasAsync = ref.watch(thanasProvider(_districtId));

    return DhScaffold(
      body: SafeArea(
        child: Column(
          children: [
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Kicker(isBn ? 'ডায়াগনস্টিক টেস্ট' : 'DIAGNOSTIC TEST'),
                    const SizedBox(height: 4),
                    Text(
                      group.name,
                      style: AppTypography.h1.copyWith(fontSize: 22),
                    ),
                    Text(
                      offering.facility.displayName,
                      style: AppTypography.secondary,
                    ),
                    if (_facilityTestError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _facilityTestError!,
                        style: AppTypography.tagAccent,
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (group.fastingRequired ||
                        (group.preparationInstructions != null &&
                            group.preparationInstructions!.isNotEmpty)) ...[
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.accent,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                group.preparationInstructions != null &&
                                        group.preparationInstructions!.isNotEmpty
                                    ? group.preparationInstructions!
                                    : (isBn
                                        ? 'এই টেস্টের জন্য ৮–১২ ঘণ্টা না খেয়ে থাকা আবশ্যক।'
                                        : 'Fasting required: Please fast for 8–12 hours before sample collection.'),
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
                          child: _buildCollectionOption(
                            label: l10n.visitLabOption,
                            selected: !_isHomePickup,
                            enabled: true,
                            onTap: () => setState(() => _isHomePickup = false),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCollectionOption(
                            label: offering.homeSampleCharge == null
                                ? (isBn ? 'হোম পিকআপ' : 'Home pickup')
                                : l10n.homePickupOption(CurrencyFormatter.format(
                                    offering.homeSampleCharge,
                                    locale: isBn ? 'bn' : 'en',
                                    symbol: false,
                                  )),
                            selected: _isHomePickup,
                            enabled: offering.homeSampleCollection,
                            onTap: () => setState(() => _isHomePickup = true),
                          ),
                        ),
                      ],
                    ),
                    if (!offering.homeSampleCollection &&
                        offering.homeSampleNote != null &&
                        offering.homeSampleNote!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        offering.homeSampleNote!,
                        style: AppTypography.secondary,
                      ),
                    ],

                    if (_isHomePickup) ...[
                      const SizedBox(height: 16),
                      Text(
                        l10n.pickupThana,
                        style: AppTypography.secondaryBold,
                      ),
                      const SizedBox(height: 6),
                      divisionsAsync.when(
                        data: (divisions) => DhDropdown<int?>(
                          value: _divisionId,
                          items: [
                            DhDropdownItem<int?>(
                              value: null,
                              label: isBn ? 'বিভাগ' : 'Division',
                            ),
                            ...divisions.map(
                              (d) => DhDropdownItem<int?>(
                                value: d.id,
                                label: d.localizedName(isBn ? 'bn' : 'en'),
                              ),
                            ),
                          ],
                          onChanged: (val) => setState(() {
                            _divisionId = val;
                            _districtId = null;
                            _thanaId = null;
                          }),
                        ),
                        loading: () => const SkeletonRow(height: 48),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 8),
                      districtsAsync.when(
                        data: (districts) => DhDropdown<int?>(
                          value: _districtId,
                          items: [
                            DhDropdownItem<int?>(
                              value: null,
                              label: isBn ? 'জেলা' : 'District',
                            ),
                            ...districts.map(
                              (d) => DhDropdownItem<int?>(
                                value: d.id,
                                label: d.localizedName(isBn ? 'bn' : 'en'),
                              ),
                            ),
                          ],
                          onChanged: (val) => setState(() {
                            _districtId = val;
                            _thanaId = null;
                          }),
                        ),
                        loading: () => const SkeletonRow(height: 48),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 8),
                      thanasAsync.when(
                        data: (thanas) => DhDropdown<int?>(
                          value: _thanaId,
                          items: [
                            DhDropdownItem<int?>(
                              value: null,
                              label: l10n.selectThana,
                            ),
                            ...thanas.map(
                              (t) => DhDropdownItem<int?>(
                                value: t.id,
                                label: t.localizedName(isBn ? 'bn' : 'en'),
                              ),
                            ),
                          ],
                          onChanged: (val) => setState(() => _thanaId = val),
                        ),
                        loading: () => const SkeletonRow(height: 48),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      if (_thanaError != null) ...[
                        const SizedBox(height: 4),
                        Text(_thanaError!, style: AppTypography.tagAccent),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        l10n.pickupAddress,
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
                            hintText: l10n.pickupAddressHint,
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
                      onDateSelected: (d) =>
                          setState(() => _selectedDate = d),
                    ),

                    const SizedBox(height: 24),

                    // Preferred Time Window
                    Text(
                      l10n.timeWindow,
                      style: AppTypography.h2.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _timeWindows.map((tw) {
                        final isSel = _selectedTimeWindow == tw;
                        return InkWell(
                          onTap: () =>
                              setState(() => _selectedTimeWindow = tw),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSel ? AppColors.accent : AppColors.paper,
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
                                color: isSel
                                    ? AppColors.paper
                                    : AppColors.ink,
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
                    _buildTextField(
                      controller: _nameController,
                      hintText: isBn ? 'পুরো নাম লিখুন' : 'Enter full name',
                      hasError: _nameError != null,
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
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.patientAge,
                                style: AppTypography.secondaryBold,
                              ),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _ageController,
                                hintText: l10n.patientAgeHint,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.patientGender,
                                style: AppTypography.secondaryBold,
                              ),
                              const SizedBox(height: 6),
                              _buildGenderChips(l10n),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            StickyCtaBar(
              kicker: isBn ? 'মোট খরচ' : 'TOTAL AMOUNT',
              subtitle: total == null
                  ? l10n.priceConfirmedAtLab
                  : CurrencyFormatter.format(total, locale: isBn ? 'bn' : 'en'),
              buttonLabel: isBn ? 'টেস্ট বুক করুন' : 'Confirm booking',
              onPressed: () => _handleBookTest(group, offering),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionOption({
    required String label,
    required bool selected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.ink
              : (enabled ? AppColors.paper : AppColors.fillOff),
          border: Border.all(
            color: enabled ? AppColors.ink : AppColors.lineSoft,
            width: AppColors.borderWidth,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontArchivo,
            fontWeight: FontWeight.w700,
            color: selected
                ? AppColors.paper
                : (enabled ? AppColors.ink : AppColors.mutedLight),
          ),
        ),
      ),
    );
  }

  Future<void> _handleBookTest(
    TestSearchGroup group,
    LabOffering offering,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_validate(l10n)) return;

    final phone = Validators.normalizePhone(_phoneController.text.trim());
    await OtpSheet.show(
      context,
      phone: phone,
      purpose: 'test_booking',
      onSubmit: (code) => _submitBooking(group, offering, code),
    );
  }

  Future<AppFailure?> _submitBooking(
    TestSearchGroup group,
    LabOffering offering,
    String otpCode,
  ) async {
    final rawPhone = Validators.normalizePhone(_phoneController.text.trim());
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final shownPrice = offering.shownPrice;
    final total = shownPrice == null
        ? null
        : shownPrice +
            (_isHomePickup ? (offering.homeSampleCharge ?? 0) : 0);

    try {
      final repo = ref.read(bookingRepositoryProvider);
      final response = await repo.bookTest(
        TestBookingRequest(
          facilityTestId: offering.id,
          pickupDate: dateStr,
          collectionType: _isHomePickup ? 'home' : 'center',
          patientName: _nameController.text.trim(),
          patientPhone: rawPhone,
          pickupThanaId: _isHomePickup ? _thanaId : null,
          pickupAddressLine:
              _isHomePickup ? _addressController.text.trim() : null,
          otpCode: otpCode,
          patientAge: int.tryParse(_ageController.text.trim()),
          patientGender: _gender,
          preferredTime: _windowStart[_selectedTimeWindow],
        ),
      );

      final bookingItem = BookingItem(
        id: response.id,
        bookingRef: response.shortRef,
        type: 'test',
        title: response.testName.isNotEmpty ? response.testName : group.name,
        subtitle: response.facility?.displayName ?? offering.facility.displayName,
        facilityName:
            response.facility?.displayName ?? offering.facility.displayName,
        appointmentDate: DateTime.parse(response.pickupDate ?? dateStr),
        timeSlot: _selectedTimeWindow,
        patientName: _nameController.text.trim(),
        patientPhone: rawPhone,
        fee: total,
        paymentMethod: 'counter',
        facilityPhone: offering.facility.phone,
        createdAt: DateTime.now(),
        status: response.status,
      );

      await ref.read(localBookingsProvider.notifier).addBooking(bookingItem);
      ref.read(lastBookingSuccessProvider.notifier).state = bookingItem;
      if (mounted) context.go('/success');
      return null;
    } on AppFailure catch (failure) {
      if (failure is ValidationFailure) {
        if (failure.code == 'facility_test_unavailable' ||
            failure.firstErrorFor('facility_test_id') != null) {
          if (mounted) {
            setState(() {
              _facilityTestError = failure.firstErrorFor('facility_test_id') ??
                  failure.message;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_facilityTestError!),
                backgroundColor: AppColors.accent,
              ),
            );
            context.go('/tests');
          }
          return null;
        }
        final thanaError = failure.firstErrorFor('pickup_thana_id');
        final addressError = failure.firstErrorFor('pickup_address_line');
        final collectionError = failure.firstErrorFor('collection_type');
        final dateError = failure.firstErrorFor('pickup_date');
        if (collectionError != null) {
          if (mounted) {
            setState(() => _facilityTestError = collectionError);
          }
          return failure;
        }
        if (thanaError != null || addressError != null || dateError != null) {
          if (mounted) {
            setState(() {
              _thanaError = thanaError ?? _thanaError;
              _addressError = addressError ?? _addressError;
              if (dateError != null) _facilityTestError = dateError;
            });
          }
          return failure;
        }
      }
      return failure;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    bool hasError = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(
          color: hasError ? AppColors.accent : AppColors.ink,
          width: AppColors.borderWidth,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: AppTypography.body,
        decoration: InputDecoration(
          hintText: hintText,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildGenderChips(AppLocalizations l10n) {
    final options = <String, String>{
      'male': l10n.genderMale,
      'female': l10n.genderFemale,
      'other': l10n.genderOther,
    };
    return SizedBox(
      height: 48,
      child: Row(
        children: options.entries.map((entry) {
          final selected = _gender == entry.key;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: InkWell(
                onTap: () => setState(
                  () => _gender = selected ? null : entry.key,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected ? AppColors.ink : AppColors.paper,
                    border: Border.all(
                      color: AppColors.ink,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    entry.value,
                    style: AppTypography.tag.copyWith(
                      color: selected ? AppColors.paper : AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
