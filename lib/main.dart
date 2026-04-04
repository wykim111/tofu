import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/walk_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/map_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/records_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/onboarding_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
        ChangeNotifierProvider(create: (_) => WalkProvider()),
      ],
      child: MaterialApp(
        title: 'Walk Tracker',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const AppEntry(),
      ),
    );
  }
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        if (!settings.onboardingCompleted) {
          return OnboardingScreen(onComplete: () {});
        }
        return const MainNavigation();
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MapScreen(),
    SummaryScreen(),
    RecordsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPrimary,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kBorderColor)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: '지도'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: '요약'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: '기록'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '프로필'),
          ],
        ),
      ),
    );
  }
}
