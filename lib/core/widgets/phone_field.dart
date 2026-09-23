import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/validators.dart';

class PhoneField extends StatefulWidget {
  const PhoneField({
    super.key,
    required this.controller,
    this.onChanged,
    this.errorText,
    this.height = 48.0,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final double height;

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  String? _inlineError;

  void _validate(String value) {
    if (value.length >= 11) {
      if (!Validators.isValidBdPhone(value)) {
        setState(() {
          _inlineError = 'Invalid Bangladesh mobile number (e.g. 017XXXXXXXX)';
        });
      } else {
        setState(() {
          _inlineError = null;
        });
      }
    } else {
      if (_inlineError != null) {
        setState(() {
          _inlineError = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeError = widget.errorText ?? _inlineError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.paper,
            border: Border.all(
              color: activeError != null ? AppColors.accent : AppColors.ink,
              width: AppColors.borderWidth,
            ),
          ),
          child: Row(
            children: [
              // +88 prefix box
              Container(
                width: 58,
                height: double.infinity,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.fill,
                  border: Border(
                    right: BorderSide(color: AppColors.ink, width: AppColors.borderWidth),
                  ),
                ),
                child: const Text(
                  '+88',
                  style: TextStyle(
                    fontFamily: AppTypography.fontMono,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  onChanged: (val) {
                    _validate(val);
                    widget.onChanged?.call(val);
                  },
                  style: const TextStyle(
                    fontFamily: AppTypography.fontMono,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                    letterSpacing: 1.0,
                  ),
                  decoration: const InputDecoration(
                    hintText: '01XXXXXXXXX',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (activeError != null) ...[
          const SizedBox(height: 4),
          Text(
            activeError,
            style: AppTypography.tagAccent,
          ),
        ],
      ],
    );
  }
}
