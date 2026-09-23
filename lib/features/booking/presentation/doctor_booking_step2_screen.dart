import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/dh_scaffold.dart';
import '../../../core/widgets/kicker.dart';
import '../../../core/widgets/phone_field.dart';
import '../../../core/widgets/primary_cta_button.dart';
import '../../bookings/domain/models/booking_item.dart';
import '../../doctors/domain/models/affiliation.dart';
import '../../doctors/presentation/doctor_profile_screen.dart';
import '../domain/models/booking_request.dart';
import 'booking_success_screen.dart';

const bool kRequireOtp = bool.fromEnvironment('REQUIRE_OTP', defaultValue: false);
const bool kPayInAppEnabled = bool.fromEnvironment('PAY_IN_APP', defaultValue: false);

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

  String? _nameError;
  String? _phoneError;
  bool _isSubmitting = false;
  String _paymentChoice = 'counter'; // 'counter' or 'online'

  @override
  void initState() {
    super.initState();
    final store = ref.read(localBookingStoreProvider);
    _nameController = TextEditingController(text: store.getLastPatientName() ?? '');
    _phoneController = TextEditingController(text: store.getLastPatientPhone() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String phone) async {
    if (phone.length == 11 && Validators.isValidBdPhone(phone)) {
      final res = await ref.read(bookingRepositoryProvider).lookupPatient(phone);
      if (res.found && res.name != null && _nameController.text.isEmpty) {
        setState(() {
          _nameController.text = res.name!;
        });
      }
    }
  }

  bool _validateForm() {
    bool valid = true;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      setState(() => _nameError = 'Patient name is required');
      valid = false;
    } else {
      setState(() => _nameError = null);
    }

    if (!Validators.isValidBdPhone(phone)) {
      setState(() => _phoneError = 'Valid 11-digit mobile number required');
      valid = false;
    } else {
      setState(() => _phoneError = null);
    }

    return valid;
  }

  Future<void> _handleConfirmBooking({
    required String doctorName,
    required String specialty,
    required DoctorAffiliation affiliation,
    required String dateStr,
    required String slotStr,
    required String displaySlot,
  }) async {
    if (!_validateForm()) return;

    if (kRequireOtp) {
      _showOtpModal(
        doctorName: doctorName,
        specialty: specialty,
        affiliation: affiliation,
        dateStr: dateStr,
        slotStr: slotStr,
        displaySlot: displaySlot,
      );
      return;
    }

    await _executeBooking(
      doctorName: doctorName,
      specialty: specialty,
      affiliation: affiliation,
      dateStr: dateStr,
      slotStr: slotStr,
      displaySlot: displaySlot,
      otpCode: null,
    );
  }

  Future<void> _executeBooking({
    required String doctorName,
    required String specialty,
    required DoctorAffiliation affiliation,
    required String dateStr,
    required String slotStr,
    required String displaySlot,
    String? otpCode,
  }) async {
    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(bookingRepositoryProvider);
      final rawPhone = Validators.normalizePhone(_phoneController.text.trim());

      final request = DoctorBookingRequest(
        affiliationId: affiliation.id,
        date: dateStr,
        slot: slotStr,
        patientName: _nameController.text.trim(),
        patientPhone: rawPhone,
        otpCode: otpCode,
      );

      final response = await repo.bookDoctor(request);

      final bookingItem = BookingItem(
        id: response.id.isNotEmpty ? response.id : 'DH-${DateTime.now().millisecondsSinceEpoch}',
        bookingRef: response.bookingRef,
        serialDisplay: response.serialDisplay,
        serialNumber: response.serialNumber,
        type: 'doctor',
        title: doctorName,
        subtitle: specialty,
        facilityName: affiliation.fullDisplayName,
        appointmentDate: DateTime.parse(dateStr),
        timeSlot: displaySlot,
        patientName: _nameController.text.trim(),
        patientPhone: rawPhone,
        fee: affiliation.fee,
        paymentMethod: _paymentChoice,
        facilityPhone: affiliation.phone,
        createdAt: DateTime.now(),
      );

      // Save to local bookings
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

  void _showOtpModal({
    required String doctorName,
    required String specialty,
    required DoctorAffiliation affiliation,
    required String dateStr,
    required String slotStr,
    required String displaySlot,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) {
        return _OtpVerificationModal(
          phone: _phoneController.text.trim(),
          onVerified: (otpCode) {
            Navigator.pop(context);
            _executeBooking(
              doctorName: doctorName,
              specialty: specialty,
              affiliation: affiliation,
              dateStr: dateStr,
              slotStr: slotStr,
              displaySlot: displaySlot,
              otpCode: otpCode,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final chamberId = state.uri.queryParameters['chamber'];
    final dateStr = state.uri.queryParameters['date'] ?? '2024-01-01';
    final slotStr = state.uri.queryParameters['slot'] ?? '18:00';
    final displaySlot = state.uri.queryParameters['displaySlot'] ?? slotStr;

    final doctorAsync = ref.watch(doctorDetailsProvider(widget.doctorId));
    final locale = ref.watch(localeProvider);
    final isBn = locale.languageCode == 'bn';

    return doctorAsync.when(
      data: (doctor) {
        final affiliation = doctor.affiliations.firstWhere(
          (a) => a.id == chamberId,
          orElse: () => doctor.affiliations.isNotEmpty
              ? doctor.affiliations.first
              : const DoctorAffiliation(
                  id: 'default',
                  facilityName: 'Chamber',
                  fee: 1000,
                ),
        );

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
                                value: '$dateStr — $displaySlot',
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: AppColors.lineSoft, height: 1),
                              const SizedBox(height: 12),
                              _buildSummaryRow(
                                label: isBn ? 'স্থান' : 'WHERE',
                                value: affiliation.fullDisplayName,
                                subtitle: affiliation.addressLine,
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: AppColors.lineSoft, height: 1),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isBn ? 'ভিজিট ফি' : 'CONSULTATION FEE',
                                    style: AppTypography.kicker.copyWith(
                                      color: AppColors.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(
                                      affiliation.fee,
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
                              hintText: isBn ? 'নাম লিখুন' : 'Enter full name',
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
                          onChanged: _onPhoneChanged,
                        ),

                        const SizedBox(height: 24),

                        // Payment Section
                        Text(
                          isBn ? 'পেমেন্ট মাধ্যম' : 'Payment Choice',
                          style: AppTypography.h2.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 10),

                        // Option 1: Pay at counter
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
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _paymentChoice == 'counter'
                                        ? AppColors.accent
                                        : AppColors.paper,
                                    border: Border.all(
                                      color: _paymentChoice == 'counter'
                                          ? AppColors.accent
                                          : AppColors.ink,
                                      width: 2,
                                    ),
                                  ),
                                  child: _paymentChoice == 'counter'
                                      ? const Center(
                                          child: Icon(
                                            Icons.check,
                                            size: 14,
                                            color: AppColors.paper,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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

                        // Option 2: Pay now (disabled / behind flag)
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
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: _paymentChoice == 'online'
                                          ? AppColors.accent
                                          : AppColors.paper,
                                      border: Border.all(
                                        color: _paymentChoice == 'online'
                                            ? AppColors.accent
                                            : AppColors.ink,
                                        width: 2,
                                      ),
                                    ),
                                    child: _paymentChoice == 'online'
                                        ? const Center(
                                            child: Icon(
                                              Icons.check,
                                              size: 14,
                                              color: AppColors.paper,
                                            ),
                                          )
                                        : null,
                                  ),
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
                    label: isBn ? 'বুকিং নিশ্চিত করুন' : 'Confirm booking',
                    isLoading: _isSubmitting,
                    onPressed: () => _handleConfirmBooking(
                      doctorName: doctor.localizedName(isBn ? 'bn' : 'en'),
                      specialty: doctor.primarySpecialtyName,
                      affiliation: affiliation,
                      dateStr: dateStr,
                      slotStr: slotStr,
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
        if (subtitle != null) ...[
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

class _OtpVerificationModal extends StatefulWidget {
  const _OtpVerificationModal({
    required this.phone,
    required this.onVerified,
  });

  final String phone;
  final ValueChanged<String> onVerified;

  @override
  State<_OtpVerificationModal> createState() => _OtpVerificationModalState();
}

class _OtpVerificationModalState extends State<_OtpVerificationModal> {
  final TextEditingController _otpController = TextEditingController();
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Verify Phone Number', style: AppTypography.h2),
          const SizedBox(height: 8),
          Text(
            'We sent a 6-digit verification code to ${widget.phone}',
            style: AppTypography.secondary,
          ),
          const SizedBox(height: 20),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.paper,
              border: Border.all(color: AppColors.ink, width: AppColors.borderWidth),
            ),
            child: TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(
                fontFamily: AppTypography.fontMono,
                fontSize: 18,
                letterSpacing: 8,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                hintText: '• • • • • •',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _secondsLeft > 0 ? 'Resend in ${_secondsLeft}s' : 'Didn\'t get code?',
                style: AppTypography.secondary,
              ),
              if (_secondsLeft == 0)
                InkWell(
                  onTap: _startTimer,
                  child: const Text(
                    'Resend code',
                    style: TextStyle(
                      fontFamily: AppTypography.fontArchivo,
                      color: AppColors.accentLink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryCtaButton(
            label: 'Verify & Confirm',
            onPressed: () {
              final code = _otpController.text.trim();
              if (code.length == 6) {
                widget.onVerified(code);
              }
            },
          ),
        ],
      ),
    );
  }
}
