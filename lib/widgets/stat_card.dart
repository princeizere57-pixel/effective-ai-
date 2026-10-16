import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import 'common.dart';

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.stat});

  final Stat stat;

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tint(stat.color),
                  borderRadius: BorderRadius.circular(AppRadius.base),
                ),
                child: Icon(stat.icon, color: stat.color, size: 20),
              ),
              const Spacer(),
              if (stat.delta != null)
                Text(stat.delta!, style: AppTheme.mono(12, color: AppColors.brand)),
            ],
          ),
          const SizedBox(height: 16),
          Text(stat.value, style: AppTheme.display(30)),
          const SizedBox(height: 4),
          Text(
            stat.label,
            style: TextStyle(color: context.palette.mutedForeground, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
