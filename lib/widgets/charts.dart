import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';

/// Daily study hours as bars (replaces the recharts BarChart).
class WeeklyHoursChart extends StatelessWidget {
  const WeeklyHoursChart({super.key, required this.data});

  final List<(String, double)> data;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final maxY = data.map((e) => e.$2).reduce(math.max).ceilToDouble() + 1;

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (_) => FlLine(color: p.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (value, meta) =>
                  Text('${value.toInt()}h', style: AppTheme.mono(10, color: p.subtle)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(data[i].$1, style: TextStyle(color: p.subtle, fontSize: 12)),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.brand,
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              '${rod.toY}h',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < data.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].$2,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.brand, AppColors.brand],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Weekly average quiz score as a line.
class QuizTrendChart extends StatelessWidget {
  const QuizTrendChart({super.key, required this.scores});

  final List<double> scores;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return LineChart(
      LineChartData(
        minY: 60,
        maxY: 100,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (_) => FlLine(color: p.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 10,
              getTitlesWidget: (value, meta) =>
                  Text('${value.toInt()}', style: AppTheme.mono(10, color: p.subtle)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'W${value.toInt() + 1}',
                  style: TextStyle(color: p.subtle, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [for (var i = 0; i < scores.length; i++) FlSpot(i.toDouble(), scores[i])],
            isCurved: true,
            color: AppColors.brand,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [tint(AppColors.brand, 0.25), tint(AppColors.brand, 0)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
