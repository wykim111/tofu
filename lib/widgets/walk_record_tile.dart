import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/walk_session.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/walk_calculator.dart';
import 'sync_status_badge.dart';

class WalkRecordTile extends StatelessWidget {
  final WalkSession session;
  final VoidCallback? onTap;

  const WalkRecordTile({super.key, required this.session, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MM월 dd일, HH:mm').format(session.startTime);
    final durationStr = WalkCalculator.formatDuration(session.duration);
    final paceStr = WalkCalculator.formatPace(session.pace);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kBgSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorderColor),
        ),
        child: Row(
          children: [
            // 썸네일
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: kBgElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kBorderColor),
              ),
              child: const Icon(Icons.route, color: kAccentViolet, size: 28),
            ),
            const SizedBox(width: 12),
            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.title ?? '산책',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: kTextPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SyncStatusBadge(status: session.syncStatus),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(dateStr, style: const TextStyle(fontSize: 12, color: kTextSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _InfoChip(Icons.route, '${session.distanceKm.toStringAsFixed(1)}km'),
                      const SizedBox(width: 12),
                      _InfoChip(Icons.timer_outlined, durationStr),
                      const SizedBox(width: 12),
                      _InfoChip(Icons.speed, paceStr),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: kTextMuted),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(fontSize: 12, color: kTextSecondary)),
      ],
    );
  }
}
