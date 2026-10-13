import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/app_failure.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/phone_launcher.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/dh_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/kicker.dart';
import '../../../core/widgets/otp_sheet.dart';
import '../../../core/widgets/phone_field.dart';
import '../../../core/widgets/primary_cta_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../doctors/domain/models/chamber.dart';
import '../../doctors/domain/models/doctor.dart';
import '../../doctors/presentation/doctor_profile_screen.dart';
import '../domain/models/booking_result.dart';

class CallLeadCacheEntry {
  const CallLeadCacheEntry({required this.result, required this.cachedAt});

  final CallLeadResult result;
  final DateTime cachedAt;

  bool isFresh(DateTime now) =>
      now.difference(cachedAt) < const Duration(minutes: 30);
}

/// In-memory only (never `shared_preferences`): the last call-lead result per
/// chamber, reused for 30 minutes so back-and-forward doesn't ask OTP again.
final callLeadCacheProvider =
    StateProvider<Map<String, CallLeadCacheEntry>>((ref) => {});

class DoctorCallScreen extends ConsumerStatefulWidget {
  const DoctorCallScreen({
    super.key,
    required this.doctorId,
    required this.chamberId,
  });

  final String doctorId;
  final String chamberId;

  @override
  ConsumerState<DoctorCallScreen> createState() => _DoctorCallScreenState();
}

class _DoctorCallScreenState extends ConsumerState<DoctorCallScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _ageController;

  String? _nameError;
  String? _phoneError;
  String? _gender;
  String? _numbersError;
  CallLeadResult? _result;

  @override
  void initState() {
    super.initState();
    final store = ref.read(localBookingStoreProvider);
    _nameController =
        TextEditingController(text: store.getLastPatientName() ?? '');
    _phoneController =
        TextEditingController(text: store.getLastPatientPhone() ?? '');
    _ageController = TextEditingController();

    final cached = ref.read(callLeadCacheProvider)[widget.chamberId];
    if (cached != null && cached.isFresh(DateTime.now())) {
      _result = cached.result;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
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

  Future<void> _onGetNumber(Chamber chamber) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_validate(l10n)) return;
    setState(() => _numbersError = null);

    final phone = Validators.normalizePhone(_phoneController.text.trim());
    await OtpSheet.show(
      context,
      phone: phone,
      purpose: 'call_lead',
      onSubmit: (code) => _createLead(chamber, code),
    );
  }

  Future<AppFailure?> _createLead(Chamber chamber, String otpCode) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await ref.read(bookingRepositoryProvider).createCallLead(
            affiliationId: chamber.id,
            patientName: _nameController.text.trim(),
            patientPhone:
                Validators.normalizePhone(_phoneController.text.trim()),
            otpCode: otpCode,
            patientAge: int.tryParse(_ageController.text.trim()),
            patientGender: _gender,
          );

      ref.read(callLeadCacheProvider.notifier).update(
            (cache) => {
              ...cache,
              chamber.id: CallLeadCacheEntry(
                result: result,
                cachedAt: DateTime.now(),
              ),
            },
          );

      if (mounted) {
        setState(() {
          _result = result;
          _numbersError = null;
        });
      }
      return null;
    } on AppFailure catch (failure) {
      if (failure is ValidationFailure) {
        if (failure.code == 'not_call_mode') {
          ref.invalidate(doctorDetailsProvider(widget.doctorId));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.errNotCallMode),
                backgroundColor: AppColors.accent,
              ),
            );
            context.pop();
          }
          return null;
        }
        if (failure.code == 'no_numbers') {
          if (mounted) setState(() => _numbersError = l10n.errNoNumbers);
          return failure;
        }
        final nameError = failure.firstErrorFor('patient_name');
        final phoneError = failure.firstErrorFor('patient_phone');
        if (nameError != null || phoneError != null) {
          if (mounted) {
            setState(() {
              _nameError = nameError ?? _nameError;
              _phoneError = phoneError ?? _phoneError;
            });
          }
          return failure;
        }
      }
      return failure;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isBn = locale.languageCode == 'bn';
    final doctorAsync = ref.watch(doctorDetailsProvider(widget.doctorId));

    return doctorAsync.when(
      data: (doctor) {
        final chamber =
            doctor.chambers.where((c) => c.id == widget.chamberId).firstOrNull;
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

        return DhScaffold(
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isBn),
                Expanded(
                  child: _result != null
                      ? _buildNumbersStep(context, doctor, chamber, isBn)
                      : _buildFormStep(context, doctor, chamber, isBn, l10n),
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
        body: SafeArea(
          child: Center(child: Text(err.toString())),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isBn) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(
          bottom: BorderSide(color: AppColors.ink, width: AppColors.borderWidth),
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
            isBn ? 'ফোনে বুকিং' : 'Book by phone',
            style: AppTypography.h2.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFormStep(
    BuildContext context,
    Doctor doctor,
    Chamber chamber,
    bool isBn,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Kicker(doctor.localizedName(isBn ? 'bn' : 'en')),
                const SizedBox(height: 4),
                Text(
                  chamber.fullDisplayName,
                  style: AppTypography.h1.copyWith(fontSize: 22),
                ),
                if (chamber.facility.address != null &&
                    chamber.facility.address!.isNotEmpty)
                  Text(
                    chamber.facility.address!,
                    style: AppTypography.secondary,
                  ),
                const SizedBox(height: 16),
                _buildSchedule(chamber, isBn, l10n),
                const SizedBox(height: 24),
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
                if (_numbersError != null) ...[
                  const SizedBox(height: 12),
                  Text(_numbersError!, style: AppTypography.tagAccent),
                ],
              ],
            ),
          ),
        ),
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
              top: BorderSide(color: AppColors.ink, width: AppColors.borderWidth),
            ),
          ),
          child: PrimaryCtaButton(
            label: l10n.ctaGetPhoneNumber,
            onPressed: () => _onGetNumber(chamber),
          ),
        ),
      ],
    );
  }

  Widget _buildNumbersStep(
    BuildContext context,
    Doctor doctor,
    Chamber chamber,
    bool isBn,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final result = _result!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Kicker(doctor.localizedName(isBn ? 'bn' : 'en')),
          const SizedBox(height: 4),
          Text(
            chamber.fullDisplayName,
            style: AppTypography.h1.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 16),
          ...result.numbers.map((number) => _buildNumberButton(number, l10n)),
          const SizedBox(height: 16),
          _buildSchedule(chamber, isBn, l10n),
          const SizedBox(height: 12),
          Text(
            l10n.callDuringHours,
            style: AppTypography.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(CallLeadNumber number, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.paper,
          border: Border.all(color: AppColors.ink, width: AppColors.borderWidth),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => launchPhone(number.phone),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (number.label.isNotEmpty)
                        Text(
                          number.label.toUpperCase(),
                          style: AppTypography.kicker.copyWith(fontSize: 10),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        number.phone,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontMono,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18, color: AppColors.ink),
              tooltip: l10n.callToBook,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: number.phone));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(number.phone)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedule(Chamber chamber, bool isBn, AppLocalizations l10n) {
    if (chamber.schedules.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.weeklyHours,
          style: AppTypography.h2.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...chamber.schedules.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 72,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(color: AppColors.fill),
                  child: Text(
                    s.dayOfWeek.length >= 3
                        ? s.dayOfWeek.substring(0, 3).toUpperCase()
                        : s.dayOfWeek.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: AppTypography.fontMono,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${_hm(s.startTime)} - ${_hm(s.endTime)}',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _hm(String time) {
    if (time.length >= 5) return time.substring(0, 5);
    return time;
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
