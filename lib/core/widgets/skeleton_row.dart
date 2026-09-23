import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SkeletonRow extends StatefulWidget {
  const SkeletonRow({
    super.key,
    this.height = 72.0,
    this.width = double.infinity,
    this.hasBorder = true,
  });

  final double height;
  final double width;
  final bool hasBorder;

  @override
  State<SkeletonRow> createState() => _SkeletonRowState();
}

class _SkeletonRowState extends State<SkeletonRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: AppColors.fill.withValues(alpha: _animation.value),
            border: widget.hasBorder
                ? Border.all(color: AppColors.lineSoft, width: AppColors.borderWidth)
                : null,
          ),
        );
      },
    );
  }
}
