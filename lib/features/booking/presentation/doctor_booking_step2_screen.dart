import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/app_failure.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/dh_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/kicker.dart';
import '../../../core/widgets/otp_sheet.dart';
import '../../../core/widgets/phone_field.dart';
import '../../../core/widgets/primary_cta_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../bookings/domain/models/booking_item.dart';
import '../../doctors/domain/models/chamber.dart';
import '../../doctors/domain/models/doctor.dart';
import '../../doctors/presentation/doctor_profile_screen.dart';
import '../domain/booking_mode.dart';
import '../domain/models/booking_request.dart';
import 'booking_success_screen.dart';

const bool kPayInAppEnabled =
    bool.fromEnvironment('PAY_IN_APP', defaultValue: false);

class DoctorBookingStep2Screen extends ConsumerStatefulWidget {
  const DoctorBookingStep2Screen({
    super.key,
    required this.doctorId,
  });

  final String doctorId;

  @override
  ConsumerState<DoctorBookingStep2Screen> createState() =>
      _DoctorBookingStep2ScreenState();
}

class _DoctorBookingStep2ScreenState
    extends ConsumerState<DoctorBookingStep2Screen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _ageController;

  String? _nameError;
  String? _phoneError;
  String? _gender;
  String _paymentChoice = 'counter'; // 'counter' or 'online'

  @override
  void initState() {
    super.initState();
    final store = ref.read(localBookingStoreProvider);
    _nameController =
        TextEditingController(text: store.getLastPatientName() ?? '');
    _phoneController =
        TextEditingController(text: store.getLastPatientPhone() ?? '');
    _ageController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  bool _validateForm(AppLocalizations l10n) {
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
    final state = GoRouterState.of(context);
    final q = state.uri.queryParameters;
    final chamberId = q['chamber'];
    final date = q['date'];
    final sessionKey = q['session_key'];
    final displaySlot = q['displaySlot'] ?? '';
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isBn = locale.languageCode == 'bn';

    if (chamberId == null || date == null || sessionKey == null) {
      return DhScaffold(
        body: SafeArea(
          child: EmptyState(
            title: l10n.bookingNotFound,
            message: l10n.bookingNotLoadedDesc,
            actionLabel: l10n.backToDoctors,
            onAction: () => context.go('/doctors'),
          ),
        ),
      );
    }

    final doctorAsync = ref.watch(doctorDetailsProvider(widget.doctorId));

    return doctorAsync.when(
      data: (doctor) {
        final chamber = doctor.chambers
            .where((c) => c.id == chamberId)
            .firstOrNull;
        if (chamber == null) {
          return DhScaffold(
            body: SafeArea(
              child: EmptyState(
                title: l10n.bookingNotFound,
                actionLabel: l10n.retry,
                onAction: () =>
                    ref.invalidate(doctorDetailsProvider(widget.doctorId)),
              ),
            ),
          );
        }

        final view = bookingModeView(chamber);
        final buttonLabel = bookingModeLabel(view.buttonKey, l10n) ??
            (isBn ? 'বুকিং নিশ্চিত করুন' : 'Confirm booking');
        final phone = _phoneController.text.trim();

        return DhScaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Top Header bar
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
                        isBn ? 'ধাপ ২ / ২: রোগীর তথ্য' : 'Step 2 of 2: Almost there',
                        style: AppTypography.h2.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),

                // Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Kicker(isBn ? 'ধাপ ২ / ২' : 'STEP 2 OF 2'),
                        const SizedBox(height: 4),
                        Text(
                          isBn ? 'তথ্য ও বুকিং নিশ্চিতকরণ' : 'Almost there',
                          style: AppTypography.h1.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 20),

                        // Booking Summary Card
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.paper,
                            border: Border.all(
                              color: AppColors.ink,
                              width: AppColors.borderWidth,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSummaryRow(
                                label: isBn ? 'ডাক্তার' : 'DOCTOR',
                                value: doctor.localizedName(isBn ? 'bn' : 'en'),
                                subtitle: doctor.primarySpecialtyName,
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: AppColors.lineSoft, height: 1),
                              const SizedBox(height: 12),
                              _buildSummaryRow(
                                label: isBn ? 'সময়' : 'WHEN',
                                value: displaySlot.isEmpty
                                    ? date
                                    : '$date · $displaySlot',
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: AppColors.lineSoft, height: 1),
                              const SizedBox(height: 12),
                              _buildSummaryRow(
                                label: isBn ? 'স্থান' : 'WHERE',
                                value: chamber.fullDisplayName,
                                subtitle: chamber.facility.address,
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: AppColors.lineSoft, height: 1),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isBn ? 'ভিজিট ফি' : 'CONSULTATION FEE',
                                    style: AppTypography.kicker.copyWith(
                                      color: AppColors.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                  if (chamber.fee != null)
                                    Text(
                                      CurrencyFormatter.format(
                                        chamber.fee,
                                        locale: isBn ? 'bn' : 'en',
                                      ),
                                      style: AppTypography.h2.copyWith(
                                        fontSize: 18,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Patient Name Field
                        Text(
                          isBn ? 'রোগীর পুরো নাম' : 'Patient Name',
                          style: AppTypography.secondaryBold,
                        ),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _nameController,
                          hintText: isBn ? 'নাম লিখুন' : 'Enter full name',
                          hasError: _nameError != null,
                        ),
                        if (_nameError != null) ...[
                          const SizedBox(height: 4),
                          Text(_nameError!, style: AppTypography.tagAccent),
                        ],

                        const SizedBox(height: 16),

                        // Patient Phone Field
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

                        // Optional age and gender
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

                        if (view.mode == BookingMode.request) ...[
                          const SizedBox(height: 12),
                          Text(
                            l10n.sendRequestNote(phone.isEmpty ? '01XXXXXXXXX' : phone),
                            style: AppTypography.secondary,
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Payment Section
                        Text(
                          isBn ? 'পেমেন্ট মাধ্যম' : 'Payment Choice',
                          style: AppTypography.h2.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () => setState(() => _paymentChoice = 'counter'),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _paymentChoice == 'counter'
                                  ? AppColors.accentWash
                                  : AppColors.paper,
                              border: Border.all(
                                color: _paymentChoice == 'counter'
                                    ? AppColors.accent
                                    : AppColors.ink,
                                width: AppColors.borderWidth,
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildRadio(_paymentChoice == 'counter'),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isBn
                                            ? 'চেম্বারে গিয়ে ফি প্রদান'
                                            : 'Pay at counter',
                                        style: AppTypography.bodyMedium,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isBn
                                            ? 'চেম্বারে গিয়ে সরাসরি কাউন্টারে ফি দিন'
                                            : 'Pay the consultation fee at the chamber',
                                        style: AppTypography.secondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (kPayInAppEnabled) ...[
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => setState(() => _paymentChoice = 'online'),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _paymentChoice == 'online'
                                    ? AppColors.accentWash
                                    : AppColors.paper,
                                border: Border.all(
                                  color: _paymentChoice == 'online'
                                      ? AppColors.accent
                                      : AppColors.ink,
                                  width: AppColors.borderWidth,
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildRadio(_paymentChoice == 'online'),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      isBn
                                          ? 'বিকাশ / নগদ / কার্ড দিয়ে পরিশোধ'
                                          : 'Pay now with bKash / Nagad / Card',
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Bar
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: 12 + MediaQuery.of(context).padding.bottom,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.paper,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.ink,
                        width: AppColors.borderWidth,
                      ),
                    ),
                  ),
                  child: PrimaryCtaButton(
                    label: buttonLabel,
                    onPressed: () => _handleConfirmBooking(
                      doctor: doctor,
                      chamber: chamber,
                      date: date,
                      sessionKey: sessionKey,
                      displaySlot: displaySlot,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const DhScaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      ),
      error: (err, _) => DhScaffold(
        body: Center(
          child: Text(err.toString()),
        ),
      ),
    );
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

  Widget _buildRadio(bool selected) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: selected ? AppColors.accent : AppColors.paper,
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.ink,
          width: 2,
        ),
      ),
      child: selected
          ? const Center(
              child: Icon(Icons.check, size: 14, color: AppColors.paper),
            )
          : null,
    );
  }

  Future<void> _handleConfirmBooking({
    required Doctor doctor,
    required Chamber chamber,
    required String date,
    required String sessionKey,
    required String displaySlot,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_validateForm(l10n)) return;

    final phone = Validators.normalizePhone(_phoneController.text.trim());
    await OtpSheet.show(
      context,
      phone: phone,
      purpose: 'doctor_booking',
      onSubmit: (code) => _submitBooking(
        doctor: doctor,
        chamber: chamber,
        date: date,
        sessionKey: sessionKey,
        displaySlot: displaySlot,
        otpCode: code,
      ),
    );
  }

  Future<AppFailure?> _submitBooking({
    required Doctor doctor,
    required Chamber chamber,
    required String date,
    required String sessionKey,
    required String displaySlot,
    required String otpCode,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final rawPhone = Validators.normalizePhone(_phoneController.text.trim());
    final age = int.tryParse(_ageController.text.trim());

    try {
      final repo = ref.read(bookingRepositoryProvider);
      final response = await repo.bookDoctor(
        DoctorBookingRequest(
          affiliationId: chamber.id,
          date: date,
          sessionKey: sessionKey,
          patientName: _nameController.text.trim(),
          patientPhone: rawPhone,
          patientAge: age,
          patientGender: _gender,
          otpCode: otpCode,
        ),
      );

      final bookingItem = BookingItem(
        id: response.id,
        bookingRef: response.shortRef,
        serialDisplay: response.serialDisplay,
        serialNumber: response.serialNumber,
        type: 'doctor',
        title: doctor.localizedName('en'),
        subtitle: doctor.primarySpecialtyName,
        facilityName: chamber.fullDisplayName,
        appointmentDate: DateTime.parse(date),
        timeSlot: displaySlot,
        patientName: _nameController.text.trim(),
        patientPhone: rawPhone,
        fee: response.fee ?? chamber.fee,
        paymentMethod: _paymentChoice,
        facilityPhone: chamber.facility.phone,
        createdAt: DateTime.now(),
        status: response.status,
        bookingMode: chamber.bookingMode,
        affiliationId: chamber.id,
        doctorSlug: doctor.slug,
        sessionStart: response.sessionStart ?? sessionKey,
        sessionEnd: response.sessionEnd,
        estimatedTime: response.estimatedTime,
        confirmDeadline: response.confirmDeadline,
        isUrgent: response.isUrgent,
        patientToken: response.patientToken,
      );

      await ref.read(localBookingsProvider.notifier).addBooking(bookingItem);
      ref.read(lastBookingSuccessProvider.notifier).state = bookingItem;
      if (mounted) context.go('/success');
      return null;
    } on AppFailure catch (failure) {
      if (failure is ValidationFailure) {
        if (failure.code == 'request_too_late') {
          _returnToStep1(l10n.errRequestTooLate);
          return null;
        }
        if (failure.code == 'otp_required') {
          _returnToStep1(l10n.errOtpRequired);
          return null;
        }
        if (failure.code == 'booking_mode_call_only') {
          if (mounted) {
            context.pushReplacement(
              '/doctors/${doctor.id}/call?chamber=${chamber.id}',
            );
          }
          return null;
        }
        final sessionError = failure.firstErrorFor('session_key') ??
            failure.firstErrorFor('date');
        if (sessionError != null) {
          _returnToStep1(sessionError);
          return null;
        }
      }
      return failure;
    }
  }

  void _returnToStep1(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accent,
      ),
    );
    context.pop();
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.kicker.copyWith(
            color: AppColors.muted,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(fontSize: 15),
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.secondary,
          ),
        ],
      ],
    );
  }
}
