import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/walk_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('통계'),
        backgroundColor: const Color(0xFF7EC8E3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<WalkProvider>(
        builder: (context, walkProvider, child) {
          final user = walkProvider.currentUser;
          
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '나의 산책 기록',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                _buildStatCard(
                  icon: Icons.route,
                  title: '총 산책 거리',
                  value: '${user.totalDistanceKm.toStringAsFixed(1)} km',
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                
                _buildStatCard(
                  icon: Icons.timer,
                  title: '총 산책 시간',
                  value: '${user.totalWalkMinutes} 시간',
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                
                _buildStatCard(
                  icon: Icons.pets,
                  title: '함께한 강아지',
                  value: user.dog?.name ?? '없음',
                  color: Colors.orange,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
