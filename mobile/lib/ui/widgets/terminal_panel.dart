import 'package:flutter/material.dart';
import '../../utils/glitch_theme.dart';
import '../../services/api_service.dart';

class TerminalPanel extends StatelessWidget {
  final List<User> users;

  const TerminalPanel({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.1,
      minChildSize: 0.1,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            border: Border(top: BorderSide(color: GlitchTheme.neonRed, width: 2)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  color: GlitchTheme.neonRed.withOpacity(0.5)
                ),
              ),
              const SizedBox(height: 20),
              Text("DETECTED SIGNALS [${users.length}]", style: GlitchTheme.headerStyle),
              const Divider(color: GlitchTheme.neonRed),
              ...users.map((u) => _buildLogItem(u)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogItem(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: GlitchTheme.neonGreen.withOpacity(0.3)),
        color: GlitchTheme.neonGreen.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi, color: GlitchTheme.neonGreen, size: 16),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("TARGET: ${user.name.toUpperCase()}", style: GlitchTheme.terminalStyle),
              Text("COORDS: ${user.latitude.toStringAsFixed(4)}, ${user.longitude.toStringAsFixed(4)}",
                   style: GlitchTheme.dataStyle.copyWith(color: Colors.white54)),
            ],
          ),
          const Spacer(),
          Text("RSSI: -${(60 + (user.id % 30))}", style: GlitchTheme.dataStyle), // Fake RSSI for server users
        ],
      ),
    );
  }
}
