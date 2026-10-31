import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SkillBridgeLogoMark extends StatelessWidget {
  const SkillBridgeLogoMark({
    this.size = 84,
    this.borderRadius = 24,
    this.backgroundColor = Colors.white,
    this.iconColor = AppColors.primary,
    this.elevated = true,
    super.key,
  });

  final double size;
  final double borderRadius;
  final Color backgroundColor;
  final Color iconColor;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(size * 0.08),
        child: Image.asset(
          'assets/images/skillbridge_logo.jpg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
