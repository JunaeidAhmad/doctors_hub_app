import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class DhSearchField extends StatefulWidget {
  const DhSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.height = 48.0,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final double height;
  final bool autofocus;

  @override
  State<DhSearchField> createState() => _DhSearchFieldState();
}

class _DhSearchFieldState extends State<DhSearchField> {
  late final TextEditingController _controller;
  bool _isOwnedController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
      _isOwnedController = true;
    } else {
      _controller = widget.controller!;
    }
    _controller.addListener(_onTextChange);
  }

  void _onTextChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChange);
    if (_isOwnedController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(color: AppColors.ink, width: AppColors.borderWidth),
      ),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: AppTypography.body,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: AppTypography.body.copyWith(color: AppColors.mutedLight),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.search, color: AppColors.ink, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(Icons.close, color: AppColors.muted, size: 18),
                  padding: EdgeInsets.zero,
                  splashRadius: 18,
                  onPressed: _handleClear,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
      ),
    );
  }
}
