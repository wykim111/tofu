import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/walk_session.dart';
import '../core/theme/app_theme.dart';

class MonthlySummaryCard extends StatelessWidget {
  final int year;
  final int month;
  final List<WalkSession> sessions;

  const MonthlySummaryCard({
    super.key,
    required this.year,
    required this.month,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final totalDist = sessions.fold(0.0, (s, e) => s + e.distanceKm);
    final totalCount = sessions.length;

    // 주간 데이터 집계 (1~4주)
    final weeklyDist = List.filled(4, 0.0);
    for (final session in sessions) {
      final week = ((session.startTime.day - 1) / 7).floor().clamp(0, 3);
      weeklyDist[week] += session.distanceKm;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$year년 $month월 요약',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: kTextPrimary,
                ),
              ),
              GestureDetector(
                child: const Text(
                  '주간 보기 >',
                  style: TextStyle(fontSize: 12, color: kAccentViolet),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 통계
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('총 거리', style: TextStyle(fontSize: 12, color: kTextSecondary)),
                  Text(
                    '${totalDist.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('총 횟수', style: TextStyle(fontSize: 12, color: kTextSecondary)),
                  Text(
                    '$totalCount 회',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 주간 차트
          SizedBox(
            height: 60,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['1주', '2주', '3주', '4주'];
                        final idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) return const SizedBox();
                        return Text(
                          labels[idx],
                          style: const TextStyle(fontSize: 10, color: kTextMuted),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: weeklyDist
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: kAccentViolet,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: kAccentViolet.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
