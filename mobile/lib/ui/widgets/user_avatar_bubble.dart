import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';

class UserAvatarBubble extends StatelessWidget {
  final String url;
  final bool isOnline;
  final VoidCallback onTap;

  const UserAvatarBubble({
    super.key,
    required this.url,
    required this.isOnline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isOnline ? AppTheme.mainGradient : null,
              color: isOnline ? null : Colors.grey.withOpacity(0.3),
              boxShadow: [
                if (isOnline)
                  BoxShadow(
                    color: AppTheme.primaryPink.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
              ],
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.black26,
              backgroundImage: NetworkImage(url),
            ),
          ),
        ],
      ).animate()
       .scale(duration: 600.ms, curve: Curves.elasticOut)
       .fadeIn(duration: 400.ms),
    );
  }
}
