import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';

void main() {
  runApp(const NeonApp());
}

class NeonApp extends StatelessWidget {
  const NeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Network',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF120E24),
        textTheme: GoogleFonts.orbitronTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFC2), // Neon Cyan
          secondary: Color(0xFFFF003C), // Neon Red
          surface: Color(0xFF1A1A2E),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00FFC2), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF00FFC2).withOpacity(0.5), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF003C), width: 2), // Red on focus
          ),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

// --- DATABASE HELPER ---

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Connection? _connection;

  Future<void> init() async {
    if (_connection != null && _connection!.isOpen) return;

    try {
      final endpoint = Endpoint(
        host: 'ep-holy-violet-agv7k5cl-pooler.c-2.eu-central-1.aws.neon.tech',
        database: 'neondb',
        username: 'neondb_owner',
        password: 'npg_xm9Q4kjOBXGR',
      );

      final settings = ConnectionSettings(
        sslMode: SslMode.require,
      );

      _connection = await Connection.open(endpoint, settings: settings);

      // Create table if not exists
      await _connection!.execute(
        '''
        CREATE TABLE IF NOT EXISTS users (
          id SERIAL PRIMARY KEY,
          email TEXT UNIQUE NOT NULL,
          password_hash TEXT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        '''
      );
      debugPrint("Database initialized.");
    } catch (e) {
      debugPrint("Database Init Error: $e");
      rethrow;
    }
  }

  Future<void> register(String email, String password) async {
    await init();
    // In production, use a proper hashing library like bcrypt or argon2.
    // This is a simple hash for demonstration purposes.
    final hash = password.hashCode.toString();

    try {
      await _connection!.execute(
        Sql.named('INSERT INTO users (email, password_hash) VALUES (@email, @hash)'),
        parameters: {'email': email, 'hash': hash},
      );
    } on ServerException catch (e) {
      if (e.code == '23505') { // Unique violation
         throw Exception('Email already exists');
      }
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    await init();
    final hash = password.hashCode.toString();

    final result = await _connection!.execute(
      Sql.named('SELECT id FROM users WHERE email = @email AND password_hash = @hash'),
      parameters: {'email': email, 'hash': hash},
    );

    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    await init();
    final result = await _connection!.execute('SELECT id, email, created_at FROM users ORDER BY created_at DESC');

    return result.map((row) {
      // row is a ResultRow, accessed by index or name.
      return {
        'id': row[0],
        'email': row[1],
        'created_at': row[2],
      };
    }).toList();
  }
}

// --- VISUALS: GLITCH TEXT ---

class GlitchText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double fontSize;

  const GlitchText(this.text, {super.key, this.style, this.fontSize = 24});

  @override
  Widget build(BuildContext context) {
    final baseStyle = (style ?? GoogleFonts.orbitron()).copyWith(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white);

    return Stack(
      children: [
        // Cyan Layer
        Text(text, style: baseStyle.copyWith(color: const Color(0xFF00FFC2).withOpacity(0.8)))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .move(begin: const Offset(-2, 0), end: const Offset(2, 1), duration: 1200.ms, curve: Curves.easeInOut)
            .shake(hz: 8, offset: const Offset(1, 1), duration: 2000.ms), // Jitter

        // Red Layer
        Text(text, style: baseStyle.copyWith(color: const Color(0xFFFF003C).withOpacity(0.8)))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .move(begin: const Offset(2, 0), end: const Offset(-2, -1), duration: 1100.ms, curve: Curves.easeInOut)
             .shake(hz: 5, offset: const Offset(-1, 2), duration: 2200.ms),

        // White Layer
        Text(text, style: baseStyle)
            .animate(onPlay: (c) => c.repeat())
            .shake(hz: 0.5, offset: const Offset(0.5, 0.5), duration: 5000.ms), // Subtle shake
      ],
    );
  }
}

// --- BACKGROUND ---

class CyberBackground extends StatelessWidget {
  final Widget child;
  const CyberBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF120E24), Color(0xFF2A1B5E)],
        ),
      ),
      child: child,
    );
  }
}

// --- AUTH SCREEN ---

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isLogin) {
        final success = await DatabaseHelper().login(email, pass);
        if (success) {
           if (!mounted) return;
           Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
           if (!mounted) return;
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid credentials', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
        }
      } else {
        await DatabaseHelper().register(email, pass);
        if (!mounted) return;
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration Successful! Please Login.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
         setState(() => isLogin = true);
      }
    } catch (e) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CyberBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const GlitchText("NEON ACCESS", fontSize: 42),
                const SizedBox(height: 40),

                // Glassmorphism Container
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                           AnimatedSwitcher(
                             duration: const Duration(milliseconds: 500),
                             child: Text(
                               isLogin ? "SYSTEM LOGIN" : "NEW IDENTITY",
                               key: ValueKey(isLogin),
                               style: GoogleFonts.rajdhani(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: const Color(0xFF00FFC2)),
                             ),
                           ),
                           const SizedBox(height: 24),
                           TextField(
                             controller: _emailCtrl,
                             style: const TextStyle(color: Colors.white),
                             decoration: const InputDecoration(labelText: 'Email Protocol'),
                           ),
                           const SizedBox(height: 16),
                           TextField(
                             controller: _passCtrl,
                             obscureText: true,
                             style: const TextStyle(color: Colors.white),
                             decoration: const InputDecoration(labelText: 'Security Key'),
                           ),
                           const SizedBox(height: 32),

                           _isLoading
                           ? const CircularProgressIndicator(color: Color(0xFF00FFC2))
                           : SizedBox(
                             width: double.infinity,
                             child: ElevatedButton(
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: const Color(0xFF00FFC2),
                                 foregroundColor: Colors.black,
                                 padding: const EdgeInsets.symmetric(vertical: 16),
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                               ),
                               onPressed: _submit,
                               child: Text(isLogin ? "JACK IN" : "INITIALIZE", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
                             ),
                           ),

                           const SizedBox(height: 16),
                           TextButton(
                             onPressed: () => setState(() => isLogin = !isLogin),
                             child: Text(
                               isLogin ? "Create new identity >" : "< Return to login",
                               style: const TextStyle(color: Color(0xFFFF003C)),
                             ),
                           )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- HOME SCREEN ---

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const GlitchText("NEON NETWORK", fontSize: 24),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Color(0xFFFF003C)),
            onPressed: () {
               Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
            },
          )
        ],
      ),
      body: CyberBackground(
        child: Padding(
          padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseHelper().getAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF00FFC2)));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Data Corruption Detected: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
              }

              final users = snapshot.data ?? [];

              if (users.isEmpty) {
                 return const Center(child: Text('No entities found.', style: TextStyle(color: Colors.white54)));
              }

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      border: Border.all(color: const Color(0xFF00FFC2).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                         BoxShadow(
                           color: const Color(0xFF00FFC2).withOpacity(0.1),
                           blurRadius: 8,
                           spreadRadius: 1,
                         )
                      ]
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF2A1B5E),
                        child: Text(
                          (user['email'] as String).substring(0, 1).toUpperCase(),
                          style: GoogleFonts.orbitron(color: const Color(0xFF00FFC2)),
                        ),
                      ),
                      title: Text(
                        user['email'],
                        style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                      ),
                      subtitle: Text(
                        "ID: ${user['id']} // DETECTED: ${user['created_at'].toString().split(' ')[0]}",
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      trailing: const Icon(Icons.wifi_tethering, color: Color(0xFFFF003C)),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: (100 * index).ms).slideX();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
