import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  const MapControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: kBgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: kTextPrimary, size: 20),
      ),
    );
  }
}
