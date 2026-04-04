import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/walk_provider.dart';
import '../providers/settings_provider.dart';
import '../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WalkProvider, SettingsProvider>(
      builder: (context, wp, settings, _) {
        final user = wp.currentUser;

        return Scaffold(
          backgroundColor: kBgPrimary,
          appBar: AppBar(
            backgroundColor: kBgPrimary,
            title: const Text('설정 및 프로필'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 프로필 카드
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kBgSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorderColor),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: kAccentPurple.withOpacity(0.2),
                      child: const Icon(Icons.person, size: 36, color: kAccentViolet),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18, color: kTextPrimary)),
                          const SizedBox(height: 2),
                          Text(user.email ?? 'walker@example.com',
                              style: const TextStyle(fontSize: 13, color: kTextSecondary)),
                          if (user.dog != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.pets, size: 12, color: kAccentViolet),
                                const SizedBox(width: 4),
                                Text(
                                  '${user.dog!.name} · ${user.dog!.breed}',
                                  style: const TextStyle(fontSize: 12, color: kTextMuted),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('수정', style: TextStyle(color: kAccentViolet)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 위치 권한 카드
              _LocationPermissionCard(),

              const SizedBox(height: 16),

              // 추적 및 배터리
              _SectionHeader(title: '추적 및 배터리 정책', icon: Icons.sync),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: kBgSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorderColor),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('포그라운드 서비스 유지',
                          style: TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                      subtitle: const Text('앱이 종료되어도 기록이 끊기지 않도록 알림창에 고정됩니다.',
                          style: TextStyle(color: kTextMuted, fontSize: 11)),
                      value: settings.foregroundServiceEnabled,
                      onChanged: settings.setForegroundService,
                      activeColor: kAccentViolet,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    ),
                    const Divider(height: 1, color: kBorderColor),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('기록 품질 모드',
                              style: TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _QualityButton(
                                label: '정확도 우선',
                                selected: settings.recordingQuality == RecordingQuality.accuracy,
                                onTap: () => settings.setRecordingQuality(RecordingQuality.accuracy),
                              ),
                              const SizedBox(width: 8),
                              _QualityButton(
                                label: '배터리 절약',
                                selected: settings.recordingQuality == RecordingQuality.battery,
                                onTap: () => settings.setRecordingQuality(RecordingQuality.battery),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            settings.recordingQuality == RecordingQuality.accuracy
                                ? '정확도 우선: GPS 수신 빈도를 높여 상세한 경로 기록 (배터리 소모 증가)'
                                : '배터리 절약: GPS 수신 빈도를 낮춰 배터리를 절약합니다',
                            style: const TextStyle(fontSize: 11, color: kTextMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 데이터 저장 및 동기화
              _SectionHeader(title: '데이터 저장 및 동기화', icon: Icons.cloud_upload_outlined),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: kBgSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorderColor),
                ),
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.cloud_done_outlined,
                      title: '자동 동기화',
                      trailing: const Icon(Icons.keyboard_arrow_right, color: kTextMuted, size: 18),
                    ),
                    const Divider(height: 1, color: kBorderColor),
                    _SettingsTile(
                      icon: Icons.backup_outlined,
                      title: '데이터 백업',
                      trailing: const Icon(Icons.keyboard_arrow_right, color: kTextMuted, size: 18),
                    ),
                    const Divider(height: 1, color: kBorderColor),
                    _SettingsTile(
                      icon: Icons.delete_outline,
                      title: '데이터 초기화',
                      titleColor: kError,
                      trailing: const Icon(Icons.keyboard_arrow_right, color: kTextMuted, size: 18),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class _LocationPermissionCard extends StatefulWidget {
  @override
  State<_LocationPermissionCard> createState() => _LocationPermissionCardState();
}

class _LocationPermissionCardState extends State<_LocationPermissionCard> {
  LocationPermission _permission = LocationPermission.denied;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final p = await Geolocator.checkPermission();
    setState(() => _permission = p);
  }

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _permissionInfo();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 18, color: color),
              const SizedBox(width: 8),
              Text('위치 권한 상태', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "백그라운드에서도 정확한 산책 경로를 기록하기 위해 '항상 허용' 권한이 필요합니다.",
            style: TextStyle(fontSize: 12, color: kTextSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 13, color: color)),
              const Spacer(),
              if (_permission != LocationPermission.always)
                TextButton(
                  onPressed: () async {
                    await Geolocator.openAppSettings();
                    await _checkPermission();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: kBgElevated,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('OS 설정 이동', style: TextStyle(fontSize: 12, color: kTextPrimary)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  (String, Color, IconData) _permissionInfo() => switch (_permission) {
        LocationPermission.always => ('항상 허용됨', kSuccess, Icons.check_circle),
        LocationPermission.whileInUse => ('앱 사용 중에만 허용됨', kWarning, Icons.info_outline),
        _ => ('위치 권한 없음', kError, Icons.error_outline),
      };
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: kAccentViolet),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: kTextSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color titleColor;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.titleColor = kTextPrimary,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kTextMuted),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: titleColor, fontSize: 14)),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _QualityButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _QualityButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? kAccentViolet : kBgElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? kAccentViolet : kBorderColor),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : kTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
