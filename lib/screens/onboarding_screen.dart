import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../core/theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _batteryOptimization = true;
  bool _preciseLocation = true;
  bool _hasWhileInUse = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _complete();
    }
  }

  Future<void> _complete() async {
    await context.read<SettingsProvider>().completeOnboarding();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Icon(Icons.arrow_back, color: kTextPrimary),
                    )
                  else
                    const SizedBox(width: 24),
                  const Spacer(),
                  // 페이지 인디케이터
                  Row(
                    children: List.generate(2, (i) {
                      return Container(
                        width: i == _currentPage ? 20 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: i == _currentPage ? kAccentViolet : kBgElevated,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // 페이지
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _WelcomePage(onNext: _nextPage),
                  _PermissionPage(
                    hasWhileInUse: _hasWhileInUse,
                    batteryOptimization: _batteryOptimization,
                    preciseLocation: _preciseLocation,
                    onBatteryChanged: (v) => setState(() => _batteryOptimization = v),
                    onPreciseChanged: (v) => setState(() => _preciseLocation = v),
                    onRequestPermission: () async {
                      final p = await Geolocator.requestPermission();
                      setState(() => _hasWhileInUse = p == LocationPermission.whileInUse ||
                          p == LocationPermission.always);
                    },
                    onComplete: _complete,
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

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;

  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: kAccentPurple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_walk, size: 52, color: kAccentViolet),
          ),
          const SizedBox(height: 32),
          const Text(
            'Walk Tracker에\n오신 것을 환영해요!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kTextPrimary, height: 1.4),
          ),
          const SizedBox(height: 16),
          const Text(
            '강아지와 함께하는 모든 산책을\n정확하게 기록해드려요.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: kTextSecondary, height: 1.6),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text('시작하기'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionPage extends StatelessWidget {
  final bool hasWhileInUse;
  final bool batteryOptimization;
  final bool preciseLocation;
  final ValueChanged<bool> onBatteryChanged;
  final ValueChanged<bool> onPreciseChanged;
  final VoidCallback onRequestPermission;
  final VoidCallback onComplete;

  const _PermissionPage({
    required this.hasWhileInUse,
    required this.batteryOptimization,
    required this.preciseLocation,
    required this.onBatteryChanged,
    required this.onPreciseChanged,
    required this.onRequestPermission,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: kAccentPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.location_on_rounded, size: 38, color: kAccentViolet),
          ),
          const SizedBox(height: 20),
          const Text(
            '정확한 산책 기록을 위해',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kTextPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            '끊김 없는 경로 추적과 요약을 위해\n위치 접근 권한이 필요합니다.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: kTextSecondary, height: 1.5),
          ),
          const SizedBox(height: 24),

          // 권한 단계
          _PermissionStep(
            step: 1,
            title: '앱 사용 중 허용',
            subtitle: '기본적인 경로 추적을 시작합니다.',
            badge: '필수',
            badgeColor: kAccentViolet,
            isCompleted: hasWhileInUse,
            onTap: onRequestPermission,
          ),
          const SizedBox(height: 10),
          _PermissionStep(
            step: 2,
            title: '항상 허용',
            subtitle: '화면이 꺼져도 기록이 유지됩니다.',
            badge: '권장',
            badgeColor: kTextMuted,
            isCompleted: false,
            onTap: () => Geolocator.openAppSettings(),
          ),

          const SizedBox(height: 24),

          // 권장 설정
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kBgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('원활한 기록을 위한 권장 설정',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kTextSecondary)),
                const SizedBox(height: 12),
                _ToggleRow(
                  icon: Icons.battery_saver_outlined,
                  iconColor: kError,
                  title: '배터리 최적화 제외',
                  subtitle: '앱이 강제 종료되지 않도록 방지',
                  value: batteryOptimization,
                  onChanged: onBatteryChanged,
                ),
                const SizedBox(height: 10),
                _ToggleRow(
                  icon: Icons.gps_fixed,
                  iconColor: kSuccess,
                  title: '정확한 위치 사용',
                  subtitle: '오차 없는 상세한 경로 기록',
                  value: preciseLocation,
                  onChanged: onPreciseChanged,
                ),
              ],
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onComplete,
              child: const Text('권한 허용하고 시작하기 →'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onComplete,
            child: const Text('나중에 (기능이 제한될 수 있습니다)',
                style: TextStyle(fontSize: 12, color: kTextMuted)),
          ),
        ],
      ),
    );
  }
}

class _PermissionStep extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final bool isCompleted;
  final VoidCallback onTap;

  const _PermissionStep({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isCompleted ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kBgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isCompleted ? kAccentViolet.withOpacity(0.4) : kBorderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? kAccentViolet : kBgElevated,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text('$step', style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: kTextPrimary, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: kTextMuted)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(badge, style: TextStyle(fontSize: 11, color: badgeColor, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, color: kTextPrimary)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: kTextMuted)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
