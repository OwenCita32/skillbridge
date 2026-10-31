import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.medium),
    this.onTap,
    this.borderColor = AppColors.border,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.standard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.standard),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.standard),
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}
