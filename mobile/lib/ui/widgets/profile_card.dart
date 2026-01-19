import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../services/api_service.dart';

class ProfileCard extends StatelessWidget {
  final User user;
  final VoidCallback onClose;

  const ProfileCard({
    super.key,
    required this.user,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Photo Area
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  user.photoUrl,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    height: 300, color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.person, size: 50, color: Colors.grey)),
                  ),
                ),
              ),
              Positioned(
                top: 10, right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: onClose,
                  style: IconButton.styleFrom(backgroundColor: Colors.white54),
                ),
              ),
            ],
          ),

          // Info Area
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user.name, style: AppTheme.cardTitle),
                    const SizedBox(width: 8),
                    const Icon(Icons.verified, color: Colors.blueAccent, size: 16),
                  ],
                ),
                const SizedBox(height: 5),
                Text("📍 ${15 + (user.id * 2)}m away", style: AppTheme.cardSubtitle), // Mock distance
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {}, // Action
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Say Hello 👋"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
