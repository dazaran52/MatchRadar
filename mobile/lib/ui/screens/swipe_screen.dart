import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/match_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../widgets/match_card.dart';
import '../widgets/pulse_background.dart';
import 'radar_screen.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final CardSwiperController _controller = CardSwiperController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      Position pos = await Geolocator.getCurrentPosition();
      final myId = Provider.of<AuthProvider>(context, listen: false).userId ?? 0;

      // ignore: use_build_context_synchronously
      if (mounted) {
         Provider.of<MatchProvider>(context, listen: false).fetchUsers(pos.latitude, pos.longitude, myId);
      }
    } catch (e) {
      print("Loc Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchProv = Provider.of<MatchProvider>(context);
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final users = matchProv.nearbyUsers;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.radar, color: Colors.white, size: 30),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RadarScreen())),
            tooltip: "Switch to Radar",
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          // Background
          const PulseBackground(),

          // Empty State
          if (users.isEmpty)
             const Center(child: Text("No one nearby...", style: TextStyle(color: Colors.white70))),

          // Swiper
          if (users.isNotEmpty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: CardSwiper(
                  controller: _controller,
                  cardsCount: users.length,
                  onSwipe: (prevIndex, currentIndex, direction) {
                     if (direction == CardSwiperDirection.right) {
                       // Like using real ID
                       matchProv.swipeRight(authProv.userId ?? 0, users[prevIndex].id);
                     }
                     return true;
                  },
                  cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                    return MatchCard(user: users[index]);
                  },
                ),
              ),
            ),

          // Match Overlay
          if (matchProv.isMatch)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("IT'S A MATCH!",
                      style: AppTheme.titleStyle.copyWith(
                        color: AppTheme.primaryPink,
                        fontSize: 40,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    const SizedBox(height: 20),
                    const Icon(Icons.favorite, color: Colors.white, size: 80),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
