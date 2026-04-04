import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

enum RecordingQuality { accuracy, battery }

class SettingsProvider extends ChangeNotifier {
  bool _foregroundServiceEnabled = true;
  RecordingQuality _recordingQuality = RecordingQuality.accuracy;
  bool _onboardingCompleted = false;

  bool get foregroundServiceEnabled => _foregroundServiceEnabled;
  RecordingQuality get recordingQuality => _recordingQuality;
  bool get onboardingCompleted => _onboardingCompleted;

  LocationSettings get locationSettings {
    if (_recordingQuality == RecordingQuality.accuracy) {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      );
    } else {
      return const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 10,
      );
    }
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _foregroundServiceEnabled = prefs.getBool('foreground_service') ?? true;
    _recordingQuality = RecordingQuality.values[prefs.getInt('recording_quality') ?? 0];
    _onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    notifyListeners();
  }

  Future<void> setForegroundService(bool value) async {
    _foregroundServiceEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('foreground_service', value);
    notifyListeners();
  }

  Future<void> setRecordingQuality(RecordingQuality quality) async {
    _recordingQuality = quality;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('recording_quality', quality.index);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingCompleted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    notifyListeners();
  }
}
