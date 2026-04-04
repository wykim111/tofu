import 'package:flutter/material.dart';
import '../models/walk_session.dart';
import '../core/theme/app_theme.dart';

class SyncStatusBadge extends StatelessWidget {
  final SyncStatus status;

  const SyncStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      SyncStatus.synced => ('동기화됨', kSuccess, Icons.cloud_done_rounded),
      SyncStatus.pending => ('대기중', kPending, Icons.cloud_upload_rounded),
      SyncStatus.retrying => ('재시도', kError, Icons.sync_problem_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
