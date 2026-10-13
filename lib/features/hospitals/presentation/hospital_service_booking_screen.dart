import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/network/app_failure.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/dhaka_time.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/date_strip.dart';
import '../../../core/widgets/dh_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/kicker.dart';
import '../../../core/widgets/otp_sheet.dart';
import '../../../core/widgets/phone_field.dart';
import '../../../core/widgets/skeleton_row.dart';
import '../../../core/widgets/sticky_cta_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../booking/presentation/booking_success_screen.dart';
import '../../bookings/domain/models/booking_item.dart';
import '../domain/models/hospital.dart';
import 'hospital_page_screen.dart';
import 'hospital_service_selection.dart';

/// Preferred-time chip values are sent in English so staff can read them in
/// either app language.
const List<String> kServicePreferredTimes = [
  'Morning (9 am–12 pm)',
  'Afternoon (12–4 pm)',
  'Evening (4–8 pm)',
  'Any time',
];

class HospitalServiceBookingScreen extends ConsumerStatefulWidget {
  const HospitalServiceBookingScreen({
    super.key,
    required this.idOrSlug,
    required this.serviceId,
  });

  final String idOrSlug;
  final String serviceId;

  @override
  ConsumerState<HospitalServiceBookingScreen> createState() =>
      _HospitalServiceBookingScreenState();
}

class _HospitalServiceBookingScreenState
    extends ConsumerState<HospitalServiceBookingScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _ageController;
  late final TextEditingController _notesController;

  String? _nameError;
  String? _phoneError;
  String? _dateError;
  String? _gender;
  String _preferredTime = kServicePreferredTimes.first;
  DateTime _selectedDate = DateTime.parse(DhakaTime.todayIso());

  @override
  void initState() {
    super.initState();
    final store = ref.read(localBookingStoreProvider);
    _nameController =
        TextEditingController(text: store.getLastPatientName() ?? '');
    _phoneController =
        TextEditingController(text: store.getLastPatientPhone() ?? '');
    _ageController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String phone) async {
    if (phone.length == 11 && Validators.isValidBdPhone(phone)) {
      final res = await ref.read(bookingRepositoryProvider).lookupPatient(phone);
      if (!mounted || !res.found) return;
      setState(() {
        if (_nameController.text.isEmpty && res.name != null) {
          _nameController.text = res.name!;
        }
        if (_ageController.text.isEmpty && res.age != null) {
          _ageController.text = res.age.toString();
        }
        if (_gender == null && res.gender != null) {
          _gender = res.gender;
        }
      });
    }
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
    return valid;
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(hospitalServiceSelectionProvider);
    final hospitalAsync = ref.watch(hospitalDetailsProvider(widget.idOrSlug));
    final locale = ref.watch(localeProvider);
    final isBn = locale.languageCode == 'bn';
    final l10n = AppLocalizations.of(context)!;

    Hospital? hospital = selection?.hospital;
    HospitalServiceRef? service = selection?.service;

    if (hospital == null ||
        service == null ||
        !selection!.matches(widget.serviceId)) {
      // Cold deep link: read the hospital again and find the service.
      final fetched = hospitalAsync.valueOrNull;
      if (fetched == null) {
        if (hospitalAsync.isLoading) {
          return const DhScaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SkeletonRow(height: 200),
              ),
            ),
          );
        }
        return DhScaffold(
          body: SafeArea(
            child: EmptyState(
              title: l10n.errorOccurred,
              message: hospitalAsync.error?.toString(),
              actionLabel: l10n.retry,
              onAction: () =>
                  ref.invalidate(hospitalDetailsProvider(widget.idOrSlug)),
            ),
          ),
        );
      }
      hospital = fetched;
      service = fetched.services
          .where((s) => s.id == widget.serviceId)
          .firstOrNull;
      if (service == null) {
        return DhScaffold(
          body: SafeArea(
            child: EmptyState(
              title: l10n.serviceNotOffered,
              actionLabel: l10n.retry,
              onAction: () => context.go('/hospitals/${widget.idOrSlug}'),
            ),
          ),
        );
      }
    }

    final serviceSummary = service;
    final hospitalSummary = hospital;
    final dates = List.generate(7, (i) {
      final today = DateTime.parse(DhakaTime.todayIso());
      final d = today.add(Duration(days: i));
      return DateStripItem(date: d, isAvailable: true);
    });

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
                    isBn ? 'সেবা বুকিং' : 'Book a service',
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
                    Kicker(hospitalSummary.displayName),
                    const SizedBox(height: 4),
                    Text(
                      serviceSummary.name,
                      style: AppTypography.h1.copyWith(fontSize: 22),
                    ),
                    if (hospitalSummary.localizedArea(isBn ? 'bn' : 'en')
                        .isNotEmpty)
                      Text(
                        hospitalSummary.localizedArea(isBn ? 'bn' : 'en'),
                        style: AppTypography.secondary,
                      ),
                    const SizedBox(height: 20),
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
                    if (_dateError != null) ...[
                      const SizedBox(height: 4),
                      Text(_dateError!, style: AppTypography.tagAccent),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      l10n.preferredTimeLabel,
                      style: AppTypography.h2.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kServicePreferredTimes.map((value) {
                        final selected = _preferredTime == value;
                        return InkWell(
                          onTap: () =>
                              setState(() => _preferredTime = value),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.paper,
                              border: Border.all(
                                color: AppColors.ink,
                                width: AppColors.borderWidth,
                              ),
                            ),
                            child: Text(
                              _preferredTimeLabel(value, l10n),
                              style: TextStyle(
                                fontFamily: AppTypography.fontArchivo,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? AppColors.paper
                                    : AppColors.ink,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
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
                      onChanged: _onPhoneChanged,
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
                    const SizedBox(height: 16),
                    Text(
                      l10n.notesLabel,
                      style: AppTypography.secondaryBold,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        border: Border.all(
                          color: AppColors.ink,
                          width: AppColors.borderWidth,
                        ),
                      ),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 3,
                        style: AppTypography.body,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.all(12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            StickyCtaBar(
              kicker: hospitalSummary.displayName,
              subtitle: serviceSummary.name,
              buttonLabel: l10n.ctaSendRequest,
              onPressed: () => _handleBook(hospitalSummary, serviceSummary),
            ),
          ],
        ),
      ),
    );
  }

  String _preferredTimeLabel(String value, AppLocalizations l10n) {
    switch (value) {
      case 'Morning (9 am–12 pm)':
        return l10n.prefTimeMorning;
      case 'Afternoon (12–4 pm)':
        return l10n.prefTimeAfternoon;
      case 'Evening (4–8 pm)':
        return l10n.prefTimeEvening;
      default:
        return l10n.prefTimeAny;
    }
  }

  Future<void> _handleBook(
    Hospital hospital,
    HospitalServiceRef service,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_validate(l10n)) return;

    final phone = Validators.normalizePhone(_phoneController.text.trim());
    await OtpSheet.show(
      context,
      phone: phone,
      purpose: 'hospital_service_booking',
      onSubmit: (code) => _submit(hospital, service, code),
    );
  }

  Future<AppFailure?> _submit(
    Hospital hospital,
    HospitalServiceRef service,
    String otpCode,
  ) async {
    final rawPhone = Validators.normalizePhone(_phoneController.text.trim());
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final notes = _notesController.text.trim();

    try {
      final response =
          await ref.read(bookingRepositoryProvider).bookHospitalService(
                hospitalId: hospital.id,
                serviceId: service.id,
                bookingDate: dateStr,
                preferredTime: _preferredTime,
                patientName: _nameController.text.trim(),
                patientPhone: rawPhone,
                otpCode: otpCode,
                patientAge: int.tryParse(_ageController.text.trim()),
                patientGender: _gender,
                notes: notes.isEmpty ? null : notes,
              );

      final bookingItem = BookingItem(
        id: response.id,
        bookingRef: response.shortRef,
        type: 'service',
        title: response.serviceName.isNotEmpty
            ? response.serviceName
            : service.name,
        subtitle: response.facility?.displayName ?? hospital.displayName,
        facilityName: response.facility?.displayName ?? hospital.displayName,
        appointmentDate: DateTime.parse(response.bookingDate ?? dateStr),
        timeSlot: response.preferredTime.isNotEmpty
            ? response.preferredTime
            : _preferredTime,
        patientName: _nameController.text.trim(),
        patientPhone: rawPhone,
        paymentMethod: 'counter',
        facilityPhone: hospital.phone,
        notes: notes.isEmpty ? null : notes,
        createdAt: DateTime.now(),
        status: response.status,
      );

      await ref.read(localBookingsProvider.notifier).addBooking(bookingItem);
      ref.read(lastBookingSuccessProvider.notifier).state = bookingItem;
      if (mounted) context.go('/success');
      return null;
    } on AppFailure catch (failure) {
      if (failure is ValidationFailure) {
        final serviceError = failure.firstErrorFor('service_id');
        final hospitalError = failure.firstErrorFor('hospital_id');
        if (serviceError != null || hospitalError != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(serviceError ?? hospitalError!),
                backgroundColor: AppColors.accent,
              ),
            );
            context.go('/hospitals/${hospital.id}');
          }
          return null;
        }
        final dateError = failure.firstErrorFor('booking_date');
        if (dateError != null) {
          if (mounted) setState(() => _dateError = dateError);
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
