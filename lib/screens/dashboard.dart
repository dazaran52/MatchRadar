import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/database_service.dart';
import '../theme/neon_theme.dart';
import '../widgets/glitch_text.dart';
import 'auth_gate.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final CardSwiperController _swiperCtrl = CardSwiperController();
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = DatabaseService().getAllUsers();
  }

  void _logout() {
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
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.userAstronaut, color: Colors.white),
          onPressed: () {},
        ),
        title: const GlitchText('GLITCH', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.solidComments, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: NeonTheme.backgroundGradient,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: NeonTheme.cyberCyan));
            }

            final users = snapshot.data ?? [];
            if (users.isEmpty) {
               return Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     const Icon(FontAwesomeIcons.satelliteDish, size: 64, color: Colors.white24),
                     const SizedBox(height: 24),
                     Text('NO SIGNALS DETECTED', style: NeonTheme.themeData.textTheme.displayMedium),
                     const SizedBox(height: 16),
                     ElevatedButton(
                       onPressed: () => setState(() { _usersFuture = DatabaseService().getAllUsers(); }),
                       style: ElevatedButton.styleFrom(backgroundColor: NeonTheme.neonMagenta),
                       child: const Text('RESCAN'),
                     )
                   ],
                 ),
               );
            }

            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: CardSwiper(
                      controller: _swiperCtrl,
                      cardsCount: users.length,
                      onSwipe: (prevIndex, currentIndex, direction) {
                         return true;
                      },
                      cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                        return _buildCard(users[index]);
                      },
                    ),
                  ),
                  _buildControls(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> user) {
    final id = user['id'];
    final imageUrl = 'https://robohash.org/$id?set=set1&bgset=bg2';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Card Shape
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator(color: NeonTheme.cyberCyan))
              ),
              errorWidget: (context, url, error) => Container(color: Colors.black, child: const Icon(Icons.error)),
            ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.0, 0.5, 0.7, 1.0],
              ),
            ),
          ),

          // Info
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlitchText(
                  user['full_name']?.toString().toUpperCase() ?? 'UNKNOWN',
                  style: NeonTheme.themeData.textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: NeonTheme.cyberCyan, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${(id as int) * 5} KM AWAY',
                      style: NeonTheme.themeData.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    _Tag('GLITCHER'),
                    _Tag('CYBER'),
                    _Tag('NETRUNNER'),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CircleButton(
            icon: FontAwesomeIcons.xmark,
            color: NeonTheme.neonRed,
            onTap: () => _swiperCtrl.swipe(CardSwiperDirection.left),
          ),
          _CircleButton(
            icon: FontAwesomeIcons.star,
            color: NeonTheme.cyberCyan,
            isSmall: true,
            onTap: () => _swiperCtrl.swipe(CardSwiperDirection.top),
          ),
          _CircleButton(
            icon: FontAwesomeIcons.heart,
            color: NeonTheme.neonMagenta, // Magenta heart
            onTap: () => _swiperCtrl.swipe(CardSwiperDirection.right),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isSmall;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = isSmall ? 50.0 : 64.0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1E1E1E), // Dark button bg
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, spreadRadius: 1)
          ],
        ),
        child: Icon(icon, color: color, size: isSmall ? 20 : 28),
      ),
    );
  }
}
