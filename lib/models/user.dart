import 'dog.dart';

class AppUser {
  final String id;
  final String name;
  final String? email;
  final String? profileImageUrl;
  final Dog? dog;
  final double latitude;
  final double longitude;
  final bool isWalking;
  final double totalDistanceKm;
  final int totalWalkMinutes;
  final int totalWalkCount;

  AppUser({
    required this.id,
    required this.name,
    this.email,
    this.profileImageUrl,
    this.dog,
    required this.latitude,
    required this.longitude,
    this.isWalking = false,
    this.totalDistanceKm = 0,
    this.totalWalkMinutes = 0,
    this.totalWalkCount = 0,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    Dog? dog,
    double? latitude,
    double? longitude,
    bool? isWalking,
    double? totalDistanceKm,
    int? totalWalkMinutes,
    int? totalWalkCount,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dog: dog ?? this.dog,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isWalking: isWalking ?? this.isWalking,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      totalWalkMinutes: totalWalkMinutes ?? this.totalWalkMinutes,
      totalWalkCount: totalWalkCount ?? this.totalWalkCount,
    );
  }
}
