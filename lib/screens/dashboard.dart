import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../theme/neon_theme.dart';
import '../widgets/glass_box.dart';
import 'auth_gate.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  Future<void> _logout(BuildContext context) async {
    // In a real app, clear session/tokens
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('NEON NODES', style: TextStyle(letterSpacing: 2)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: NeonTheme.neonMagenta),
            onPressed: () => _logout(context),
            tooltip: 'DISCONNECT',
          )
        ],
      ),
      body: Container(
        decoration: NeonTheme.backgroundGradient,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              // Force rebuild by setState if we were stateful,
              // or just rely on FutureBuilder re-triggering if we pass a new future.
              // For simplicity in this StatelessWidget, we can't easily trigger rebuild without navigation or state.
              // So I'll convert to StatefulWidget or use a Stream/ValueNotifier.
              // Let's assume standard behavior: user wants to see update.
              (context as Element).markNeedsBuild();
            },
            color: NeonTheme.cyberCyan,
            backgroundColor: NeonTheme.bgTop,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseService().getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: NeonTheme.cyberCyan)
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'CONNECTION FAILURE:\n${snapshot.error}',
                        style: const TextStyle(color: NeonTheme.neonMagenta),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final users = snapshot.data ?? [];

                if (users.isEmpty) {
                  return const Center(child: Text('NO ACTIVE NODES DETECTED'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NeonCard(user: user),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class NeonCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const NeonCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return CustomGlassBox(
      borderColor: NeonTheme.cyberCyan.withOpacity(0.3),
      onTap: () {
        // Glowing cyan border effect handled by InkWell splash or we could animate border.
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Scanning node: ${user['full_name']}...'), duration: const Duration(seconds: 1))
        );
      },
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: NeonTheme.cyberCyan),
              boxShadow: const [
                BoxShadow(color: NeonTheme.cyberCyan, blurRadius: 10, spreadRadius: 1)
              ],
              color: Colors.black,
            ),
            child: const Icon(Icons.person_outline, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['full_name']?.toString().toUpperCase() ?? 'UNKNOWN',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                ),
                Text(
                  user['email'] ?? 'No Uplink',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Active since: ${user['created_at']?.toString().split(' ')[0] ?? 'N/A'}',
                   style: const TextStyle(fontSize: 12, color: Colors.white30),
                ),
              ],
            ),
          ),
          const Icon(Icons.wifi, color: NeonTheme.cyberCyan, size: 16),
        ],
      ),
    );
  }
}
