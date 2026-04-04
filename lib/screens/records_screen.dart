import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/walk_provider.dart';
import '../models/walk_session.dart';
import '../core/theme/app_theme.dart';
import '../widgets/walk_record_tile.dart';
import '../widgets/monthly_summary_card.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  String _selectedFilter = '전체기간';
  final _filters = ['전체기간', '거리', '태그', '상태'];

  @override
  Widget build(BuildContext context) {
    return Consumer<WalkProvider>(
      builder: (context, wp, _) {
        final sessions = _applyFilter(wp.sessions);
        final grouped = _groupByMonth(sessions);

        return Scaffold(
          backgroundColor: kBgPrimary,
          appBar: AppBar(
            backgroundColor: kBgPrimary,
            title: const Text('활동 기록'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: kTextPrimary),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              // 필터 바
              SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final filter = _filters[i];
                    final selected = filter == _selectedFilter;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? kAccentViolet : kBgSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? kAccentViolet : kBorderColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              filter,
                              style: TextStyle(
                                fontSize: 13,
                                color: selected ? Colors.white : kTextSecondary,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            if (filter != '전체기간') ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 14,
                                color: selected ? Colors.white : kTextMuted,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // 목록
              Expanded(
                child: sessions.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        itemCount: grouped.length,
                        itemBuilder: (context, i) {
                          final entry = grouped[i];
                          if (entry is _MonthHeader) {
                            return MonthlySummaryCard(
                              year: entry.year,
                              month: entry.month,
                              sessions: entry.sessions,
                            );
                          } else if (entry is WalkSession) {
                            return WalkRecordTile(
                              session: entry,
                              onTap: () {},
                            );
                          }
                          return const SizedBox();
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<WalkSession> _applyFilter(List<WalkSession> sessions) {
    switch (_selectedFilter) {
      case '거리':
        return [...sessions]..sort((a, b) => b.distanceKm.compareTo(a.distanceKm));
      case '상태':
        return [...sessions]..sort((a, b) => a.syncStatus.index.compareTo(b.syncStatus.index));
      default:
        return sessions;
    }
  }

  List<dynamic> _groupByMonth(List<WalkSession> sessions) {
    final result = <dynamic>[];
    String? lastKey;

    for (final session in sessions) {
      final key = '${session.startTime.year}-${session.startTime.month}';
      if (key != lastKey) {
        final monthSessions = sessions.where((s) {
          return s.startTime.year == session.startTime.year &&
              s.startTime.month == session.startTime.month;
        }).toList();
        result.add(_MonthHeader(
          year: session.startTime.year,
          month: session.startTime.month,
          sessions: monthSessions,
        ));
        lastKey = key;
      }
      result.add(session);
    }
    return result;
  }
}

class _MonthHeader {
  final int year;
  final int month;
  final List<WalkSession> sessions;

  _MonthHeader({required this.year, required this.month, required this.sessions});
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: kTextMuted),
          SizedBox(height: 16),
          Text('아직 산책 기록이 없어요', style: TextStyle(color: kTextSecondary, fontSize: 16)),
          SizedBox(height: 8),
          Text('지도 탭에서 산책을 시작해보세요!', style: TextStyle(color: kTextMuted, fontSize: 13)),
        ],
      ),
    );
  }
}
