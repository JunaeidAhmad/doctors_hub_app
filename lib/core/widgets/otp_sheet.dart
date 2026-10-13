import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/app_failure.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'primary_cta_button.dart';

typedef OtpSubmit = Future<AppFailure?> Function(String code);

/// Real OTP sheet, as the web booking modals do it: send a code on open,
/// the patient types it, and the code goes on the booking/lead POST as
/// `otp_code`; the verify endpoint is never called first.
class OtpSheet extends ConsumerStatefulWidget {
  const OtpSheet({
    super.key,
    required this.phone,
    required this.purpose,
    required this.onSubmit,
  });

  final String phone;
  final String purpose;
  final OtpSubmit onSubmit;

  static Future<AppFailure?> show(
    BuildContext context, {
    required String phone,
    required String purpose,
    required OtpSubmit onSubmit,
  }) {
    return showModalBottomSheet<AppFailure?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) => OtpSheet(
        phone: phone,
        purpose: purpose,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  ConsumerState<OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends ConsumerState<OtpSheet> {
  final TextEditingController _codeController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 60;
  bool _isSending = false;
  bool _isSubmitting = false;
  bool _rateLimited = false;
  String? _sendError;
  String? _codeError;

  @override
  void initState() {
    super.initState();
    _sendCode();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _sendCode() async {
    setState(() {
      _isSending = true;
      _sendError = null;
      _rateLimited = false;
    });
    try {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.sendOtp(phone: widget.phone, purpose: widget.purpose);
      if (!mounted) return;
      setState(() => _isSending = false);
      _startResendCountdown();
    } on RateLimitFailure {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _rateLimited = true;
      });
      _startResendCountdown();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _sendError = e.toString();
      });
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final code = _codeController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    if (code.length != 6) {
      setState(() => _codeError = l10n.otpInvalid);
      return;
    }

    setState(() {
      _codeError = null;
      _isSubmitting = true;
    });

    final failure = await widget.onSubmit(code);
    if (!mounted) return;

    if (failure == null) {
      Navigator.pop(context);
      return;
    }

    if (failure is ValidationFailure && failure.firstErrorFor('otp_code') != null) {
      setState(() {
        _isSubmitting = false;
        _codeError = failure.firstErrorFor('otp_code');
      });
      return;
    }

    if (failure is RateLimitFailure) {
      setState(() {
        _isSubmitting = false;
        _rateLimited = true;
        _secondsLeft = 60;
      });
      _startResendCountdown();
      return;
    }

    Navigator.pop(context, failure);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canResend = !_isSending && _secondsLeft == 0;

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
          Text(l10n.otpTitle, style: AppTypography.h2),
          const SizedBox(height: 8),
          Text(
            l10n.otpSubtitle(widget.phone),
            style: AppTypography.secondary,
          ),
          const SizedBox(height: 20),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.paper,
              border: Border.all(
                color: _codeError != null ? AppColors.accent : AppColors.ink,
                width: AppColors.borderWidth,
              ),
            ),
            child: TextField(
              controller: _codeController,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofillHints: const [AutofillHints.oneTimeCode],
              enabled: !_isSubmitting,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
          if (_codeError != null) ...[
            const SizedBox(height: 6),
            Text(_codeError!, style: AppTypography.tagAccent),
          ],
          if (_rateLimited) ...[
            const SizedBox(height: 6),
            Text(l10n.otpTooManyAttempts, style: AppTypography.tagAccent),
          ] else if (_sendError != null) ...[
            const SizedBox(height: 6),
            Text(_sendError!, style: AppTypography.tagAccent),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _secondsLeft > 0
                    ? l10n.resendIn(_secondsLeft)
                    : l10n.resendOtp,
                style: AppTypography.secondary,
              ),
              InkWell(
                onTap: canResend ? _sendCode : null,
                child: Text(
                  l10n.resendOtp,
                  style: TextStyle(
                    fontFamily: AppTypography.fontArchivo,
                    color: canResend ? AppColors.accentLink : AppColors.mutedLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryCtaButton(
            label: l10n.verifyAndConfirm,
            isLoading: _isSubmitting,
            isEnabled: !_isSending,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
