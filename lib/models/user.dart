import 'dog.dart';

class AppUser {
  final String id;
  final String name;
  final Dog? dog;
  final double latitude;
  final double longitude;
  final bool isWalking;
  final double totalDistanceKm;
  final int totalWalkMinutes;

  AppUser({
    required this.id,
    required this.name,
    this.dog,
    required this.latitude,
    required this.longitude,
    this.isWalking = false,
    this.totalDistanceKm = 0,
    this.totalWalkMinutes = 0,
  });

  AppUser copyWith({
    String? id,
    String? name,
    Dog? dog,
    double? latitude,
    double? longitude,
    bool? isWalking,
    double? totalDistanceKm,
    int? totalWalkMinutes,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      dog: dog ?? this.dog,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isWalking: isWalking ?? this.isWalking,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      totalWalkMinutes: totalWalkMinutes ?? this.totalWalkMinutes,
    );
  }
}
