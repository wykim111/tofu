import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/walk_provider.dart';
import '../models/walk_session.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/walk_calculator.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool _isPrivate = false;
  final _titleController = TextEditingController();
  final _tagController = TextEditingController();
  List<String> _tags = [];

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalkProvider>(
      builder: (context, wp, _) {
        // 가장 최근 세션 표시
        final session = wp.sessions.isNotEmpty ? wp.sessions.first : null;

        if (session == null) {
          return const Scaffold(
            backgroundColor: kBgPrimary,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.route, size: 64, color: kTextMuted),
                  SizedBox(height: 16),
                  Text('아직 산책 기록이 없어요', style: TextStyle(color: kTextSecondary, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('지도 탭에서 산책을 시작해보세요!', style: TextStyle(color: kTextMuted, fontSize: 13)),
                ],
              ),
            ),
          );
        }

        return _buildSummaryContent(context, wp, session);
      },
    );
  }

  Widget _buildSummaryContent(BuildContext context, WalkProvider wp, WalkSession session) {
    final dateStr = DateFormat('yyyy년 MM월 dd일').format(session.startTime);
    final timeRange =
        '${DateFormat('HH:mm').format(session.startTime)} - ${session.endTime != null ? DateFormat('HH:mm').format(session.endTime!) : '--:--'}';
    final durationStr = WalkCalculator.formatDuration(session.duration);
    final paceStr = WalkCalculator.formatPace(session.pace);

    // 고도 차트 데이터
    final altSpots = session.path.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.altitude);
    }).toList();
    final hasAltData = altSpots.length > 1;

    return Scaffold(
      backgroundColor: kBgPrimary,
      appBar: AppBar(
        backgroundColor: kBgPrimary,
        title: const Text('산책 요약'),
        leading: BackButton(
          onPressed: () {},
          color: kTextPrimary,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          // 핵심 통계 카드
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2D1B69), Color(0xFF1E1B4B)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kAccentPurple.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text('총 거리', style: TextStyle(fontSize: 13, color: kTextSecondary)),
                const SizedBox(height: 4),
                Text(
                  '${session.distanceKm.toStringAsFixed(2)} km',
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text('$dateStr  $timeRange',
                    style: const TextStyle(fontSize: 12, color: kTextSecondary)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatItem(label: '총 시간', value: durationStr),
                    _Divider(),
                    _StatItem(label: '평균 페이스', value: paceStr),
                    _Divider(),
                    _StatItem(label: '소모 칼로리', value: '${session.calories}'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 경로 및 분석
          _SectionCard(
            title: '경로 및 분석',
            icon: Icons.bar_chart_rounded,
            child: Column(
              children: [
                // 경로 미리보기 (플레이스홀더)
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: kBgElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorderColor),
                  ),
                  child: const Center(
                    child: Icon(Icons.map_outlined, size: 40, color: kTextMuted),
                  ),
                ),
                if (hasAltData) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: LineChart(LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) =>
                            const FlLine(color: kBorderColor, strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) => Text(
                              '${v.toInt()}m',
                              style: const TextStyle(fontSize: 9, color: kTextMuted),
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: altSpots,
                          isCurved: true,
                          color: kAccentViolet,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: kAccentViolet.withOpacity(0.2),
                          ),
                        ),
                      ],
                    )),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoRow(Icons.pause_circle_outline, '정지 시간',
                        WalkCalculator.formatDuration(session.pausedDuration)),
                    const SizedBox(width: 24),
                    _InfoRow(Icons.trending_up, '고도 변화',
                        hasAltData ? '↑ ${_calcAltChange(session).toStringAsFixed(0)}m' : '-'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 기록 상세
          _SectionCard(
            title: '기록 상세',
            icon: Icons.edit_note_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: kTextPrimary),
                  decoration: InputDecoration(
                    hintText: '산책 제목을 입력하세요',
                    hintStyle: const TextStyle(color: kTextMuted),
                    filled: true,
                    fillColor: kBgElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kBorderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kAccentViolet),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                // 태그
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._tags.map((tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 12, color: kTextPrimary)),
                          backgroundColor: kAccentPurple.withOpacity(0.2),
                          deleteIconColor: kTextSecondary,
                          onDeleted: () => setState(() => _tags.remove(tag)),
                          side: const BorderSide(color: kAccentPurple, width: 0.5),
                          padding: EdgeInsets.zero,
                        )),
                    ActionChip(
                      label: const Text('+ 태그 추가', style: TextStyle(fontSize: 12, color: kAccentViolet)),
                      backgroundColor: kAccentPurple.withOpacity(0.1),
                      side: const BorderSide(color: kAccentPurple, width: 0.5),
                      onPressed: _showTagDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 날씨
                if (session.weather != null)
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny_outlined, size: 16, color: kWarning),
                      const SizedBox(width: 6),
                      Text(
                        '${session.weather!.condition} (${session.weather!.temperature.toInt()}°)',
                        style: const TextStyle(fontSize: 13, color: kTextSecondary),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        child: const Row(
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 16, color: kAccentViolet),
                            SizedBox(width: 6),
                            Text('사진 추가', style: TextStyle(fontSize: 13, color: kAccentViolet)),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                // 나만 보기
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lock_outline, size: 16, color: kTextSecondary),
                        SizedBox(width: 8),
                        Text('나만 보기', style: TextStyle(color: kTextSecondary, fontSize: 14)),
                      ],
                    ),
                    Switch(
                      value: _isPrivate,
                      onChanged: (v) => setState(() => _isPrivate = v),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 저장 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  wp.saveSessionMeta(
                    session.id,
                    title: _titleController.text.isEmpty ? null : _titleController.text,
                    tags: _tags,
                    isPrivate: _isPrivate,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('저장되었습니다'), backgroundColor: kSuccess),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: kAccentViolet,
                ),
                child: const Text('저장하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 공유/삭제
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('공유'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kTextSecondary,
                      side: const BorderSide(color: kBorderColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context, wp, session.id),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('삭제'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kError,
                      side: const BorderSide(color: kError, width: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calcAltChange(WalkSession session) {
    if (session.path.length < 2) return 0;
    return session.path.last.altitude - session.path.first.altitude;
  }

  void _showTagDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kBgSurface,
        title: const Text('태그 추가', style: TextStyle(color: kTextPrimary)),
        content: TextField(
          controller: _tagController,
          style: const TextStyle(color: kTextPrimary),
          decoration: const InputDecoration(
            hintText: '태그 이름',
            hintStyle: TextStyle(color: kTextMuted),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: kTextSecondary)),
          ),
          TextButton(
            onPressed: () {
              if (_tagController.text.isNotEmpty) {
                setState(() => _tags.add(_tagController.text));
                _tagController.clear();
              }
              Navigator.pop(ctx);
            },
            child: const Text('추가', style: TextStyle(color: kAccentViolet)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WalkProvider wp, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kBgSurface,
        title: const Text('기록 삭제', style: TextStyle(color: kTextPrimary)),
        content: const Text('이 산책 기록을 삭제할까요?', style: TextStyle(color: kTextSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: kTextSecondary)),
          ),
          TextButton(
            onPressed: () {
              wp.deleteSession(id);
              Navigator.pop(ctx);
            },
            child: const Text('삭제', style: TextStyle(color: kError)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: kTextSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kTextPrimary)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: Colors.white.withOpacity(0.15));
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: kTextMuted),
        const SizedBox(width: 6),
        Text('$label  ', style: const TextStyle(fontSize: 12, color: kTextMuted)),
        Text(value, style: const TextStyle(fontSize: 12, color: kTextSecondary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: kAccentViolet),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: kTextPrimary)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
