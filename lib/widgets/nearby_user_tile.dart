import 'package:flutter/material.dart';
import '../models/user.dart';

class NearbyUserTile extends StatelessWidget {
  final AppUser user;
  final VoidCallback? onTap;

  const NearbyUserTile({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: ClipOval(
            child: user.dog?.imageUrl != null
                ? Image.network(
                    user.dog!.imageUrl!,
                    fit: BoxFit.cover,
                  )
                : Icon(
                    Icons.pets,
                    size: 24,
                    color: Colors.brown[400],
                  ),
          ),
        ),
        title: Row(
          children: [
            Text(
              user.dog?.name ?? '강아지',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              ' (${user.name})',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: user.isWalking ? Colors.green[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: user.isWalking ? Colors.green : Colors.grey[400]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: user.isWalking ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                user.dog?.name ?? '강아지',
                style: TextStyle(
                  fontSize: 12,
                  color: user.isWalking ? Colors.green[700] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
