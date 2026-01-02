import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/walk_provider.dart';
import '../widgets/circular_map.dart';
import '../widgets/dog_profile_card.dart';
import '../widgets/nearby_user_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalkProvider>().getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7EC8E3),
              Color(0xFFAED9E0),
              Color(0xFFF5F5F5),
            ],
            stops: [0.0, 0.4, 0.6],
          ),
        ),
        child: SafeArea(
          child: Consumer<WalkProvider>(
            builder: (context, walkProvider, child) {
              return Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // 원형 지도
                  Center(
                    child: CircularMap(
                      currentUser: walkProvider.currentUser,
                      nearbyUsers: walkProvider.nearbyUsers,
                      walkSession: walkProvider.currentSession,
                      size: 280,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 내 강아지 큰 프로필 이미지
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: walkProvider.currentUser.dog?.imageUrl != null
                          ? Image.network(
                              walkProvider.currentUser.dog!.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.pets,
                              size: 40,
                              color: Colors.brown[400],
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 프로필 카드
                  DogProfileCard(user: walkProvider.currentUser),
                  
                  const SizedBox(height: 16),
                  
                  // 주변 유저 목록
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: walkProvider.nearbyUsers.length,
                      itemBuilder: (context, index) {
                        return NearbyUserTile(
                          user: walkProvider.nearbyUsers[index],
                          onTap: () {
                            // 유저 프로필 보기
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      
      // 산책 시작/종료 버튼
      floatingActionButton: Consumer<WalkProvider>(
        builder: (context, walkProvider, child) {
          return FloatingActionButton.extended(
            onPressed: () {
              if (walkProvider.isWalking) {
                walkProvider.stopWalk();
              } else {
                walkProvider.startWalk();
              }
            },
            backgroundColor: walkProvider.isWalking ? Colors.red : Colors.green,
            icon: Icon(
              walkProvider.isWalking ? Icons.stop : Icons.directions_walk,
              color: Colors.white,
            ),
            label: Text(
              walkProvider.isWalking ? '산책 종료' : '산책 시작',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
