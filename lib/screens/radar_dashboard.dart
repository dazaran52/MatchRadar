import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/neon_theme.dart';
import '../widgets/cyber_glitch_text.dart';
import '../widgets/neo_glass.dart';
import '../widgets/shine_background.dart';
import 'auth_gate.dart';

class RadarDashboard extends StatefulWidget {
  const RadarDashboard({super.key});

  @override
  State<RadarDashboard> createState() => _RadarDashboardState();
}

class _RadarDashboardState extends State<RadarDashboard> with TickerProviderStateMixin {
  late AnimationController _radarController;
  final List<Offset> _nodes = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _generateNodes();
  }

  void _generateNodes() {
    // Generate random nodes in polar coordinates then convert to offset (-1 to 1 range)
    for (int i = 0; i < 8; i++) {
      final angle = _rnd.nextDouble() * 2 * pi;
      final radius = 0.2 + _rnd.nextDouble() * 0.6; // Don't be too close to center or edge
      _nodes.add(Offset(cos(angle) * radius, sin(angle) * radius));
    }
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _showProfile(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ProfileRevealModal(index: index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NeoGlass(
            padding: EdgeInsets.zero,
            borderRadius: 12,
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.userAstronaut, size: 20),
              onPressed: () {},
            ),
          ),
        ),
        title: const CyberGlitchText(
          'GLITCH',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white),
          glitchProbability: 0.01, // Rare glitches
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: NeoGlass(
              padding: EdgeInsets.zero,
              borderRadius: 12,
              child: IconButton(
                icon: const Icon(FontAwesomeIcons.sliders, size: 20),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: ShineBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Radar Scanner
            CustomPaint(
              painter: RadarPainter(_radarController),
              child: Container(),
            ),

            // Nodes
            LayoutBuilder(
              builder: (context, constraints) {
                final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
                final maxRadius = min(constraints.maxWidth, constraints.maxHeight) / 2;

                return Stack(
                  children: _nodes.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final offset = entry.value;
                    final pos = Offset(
                      center.dx + offset.dx * maxRadius,
                      center.dy + offset.dy * maxRadius,
                    );

                    return Positioned(
                      left: pos.dx - 25,
                      top: pos.dy - 25,
                      child: GestureDetector(
                        onTap: () => _showProfile(idx),
                        child: _RadarNode(index: idx),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            // Bottom Nav
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: NeoGlass(
                borderRadius: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(icon: const Icon(FontAwesomeIcons.radar, color: NeonTheme.cyberCyan), onPressed: (){}),
                    IconButton(icon: const Icon(FontAwesomeIcons.solidComments, color: Colors.white54), onPressed: (){}),
                    IconButton(icon: const Icon(FontAwesomeIcons.shieldHalved, color: Colors.white54), onPressed: (){}),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final Animation<double> animation;

  RadarPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.9;
    final paint = Paint()
      ..color = NeonTheme.cyberCyan.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Rings
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.66, paint..color = NeonTheme.cyberCyan.withOpacity(0.1));
    canvas.drawCircle(center, radius * 0.33, paint..color = NeonTheme.cyberCyan.withOpacity(0.1));

    // Sweep Gradient (Scanner)
    final sweepShader = SweepGradient(
      center: Alignment.center,
      startAngle: 0.0,
      endAngle: pi * 2,
      colors: [
        Colors.transparent,
        NeonTheme.cyberCyan.withOpacity(0.1),
        NeonTheme.cyberCyan.withOpacity(0.5),
      ],
      stops: const [0.5, 0.9, 1.0],
      transform: GradientRotation(animation.value * 2 * pi),
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    final sweepPaint = Paint()
      ..shader = sweepShader
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) => true;
}

class _RadarNode extends StatelessWidget {
  final int index;
  const _RadarNode({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
        border: Border.all(color: NeonTheme.cyberCyan),
        boxShadow: [
          BoxShadow(color: NeonTheme.cyberCyan.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)
        ]
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: CachedNetworkImage(
            imageUrl: 'https://robohash.org/$index?set=set1',
            fit: BoxFit.cover,
            // Blurred initially
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
          ),
        ),
      ),
    )
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .scale(begin: Offset(1,1), end: Offset(1.1, 1.1), duration: 1000.ms);
  }
}

class _ProfileRevealModal extends StatefulWidget {
  final int index;
  const _ProfileRevealModal({required this.index});

  @override
  State<_ProfileRevealModal> createState() => _ProfileRevealModalState();
}

class _ProfileRevealModalState extends State<_ProfileRevealModal> {
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    // Simulate decryption
    Future.delayed(const Duration(seconds: 1), () {
      if(mounted) setState(() => _revealed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: NeonTheme.bgTop,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          ShineBackground(child: Container()),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(5)),
                  ),
                ),
                const SizedBox(height: 20),

                // Avatar
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: NeonTheme.neonMagenta, width: 2),
                      boxShadow: [BoxShadow(color: NeonTheme.neonMagenta.withOpacity(0.5), blurRadius: 20)]
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(75),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: _revealed
                          ? CachedNetworkImage(
                              imageUrl: 'https://robohash.org/${widget.index}?set=set1',
                              fit: BoxFit.cover,
                            )
                          : ImageFiltered(
                              imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: CachedNetworkImage(
                                imageUrl: 'https://robohash.org/${widget.index}?set=set1',
                                fit: BoxFit.cover,
                              ),
                            ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: CyberGlitchText(
                    _revealed ? 'NODE_${widget.index * 942}' : 'DECRYPTING...',
                    style: NeonTheme.themeData.textTheme.displayMedium,
                    glitchProbability: 0.1,
                  ),
                ),

                const SizedBox(height: 10),
                Center(child: Text('Match: ${_revealed ? "98%" : "CALCULATING..."}', style: TextStyle(color: NeonTheme.neonGreen))),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                     _ActionButton(
                       icon: FontAwesomeIcons.xmark,
                       color: NeonTheme.neonRed,
                       label: 'REJECT',
                       onTap: () => Navigator.pop(context),
                     ),
                     _ActionButton(
                       icon: FontAwesomeIcons.satelliteDish,
                       color: NeonTheme.cyberCyan,
                       label: 'ESTABLISH UPLINK',
                       isPrimary: true,
                       onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('UPLINK REQUEST SENT', style: TextStyle(color: NeonTheme.neonGreen)))
                          );
                          Navigator.pop(context);
                       },
                     ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.color, required this.label, this.isPrimary = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isPrimary ? 24 : 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: color),
              boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15)]
            ),
            child: Icon(icon, color: color, size: isPrimary ? 30 : 20),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontSize: 12, letterSpacing: 1)),
        ],
      ),
    );
  }
}
