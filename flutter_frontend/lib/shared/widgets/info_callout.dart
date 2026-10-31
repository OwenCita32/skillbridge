import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class InfoCallout extends StatelessWidget {
  const InfoCallout({
    required this.message,
    this.icon = Icons.lightbulb_outline_rounded,
    this.backgroundColor = AppColors.primaryLight,
    super.key,
  });

  final String message;
  final IconData icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryDark, size: 20),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
