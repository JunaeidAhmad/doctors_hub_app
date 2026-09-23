import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    required this.name,
    this.width = 64.0,
    this.height = 64.0,
    this.imageUrl,
    this.borderWidth = AppColors.borderWidth,
  });

  final String name;
  final double width;
  final double height;
  final String? imageUrl;
  final double borderWidth;

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'DH';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, math.min(2, parts[0].length)).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.fill,
        border: Border.all(color: AppColors.ink, width: borderWidth),
      ),
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _StripedBackgroundPainter(),
            ),
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitials(initials),
              )
            else
              _buildInitials(initials),
          ],
        ),
      ),
    );
  }

  Widget _buildInitials(String initials) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.paper.withValues(alpha: 0.9),
          border: Border.all(color: AppColors.ink, width: 1.5),
        ),
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: AppTypography.fontArchivo,
            fontSize: height * 0.28,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

class _StripedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.lineSoft.withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const double step = 8.0;
    final total = size.width + size.height;

    for (double i = -total; i < total; i += step) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
