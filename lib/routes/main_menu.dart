import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({
    super.key,
    this.onPlayPressed,
    this.onSettingsPressed,
  });

  static const id = 'MainMenu';

  final VoidCallback? onPlayPressed;
  final VoidCallback? onSettingsPressed;

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // Repeats back and forth

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[200], // Medieval parchment-like background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Medieval animated emblem at the top
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.yellow.shade700, Colors.orange.shade700],
                        center: Alignment.center,
                        radius: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.6),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '⚔️',
                        style: TextStyle(
                          fontSize: 50,
                          fontFamily: "DualKnights",
                          color: Colors.brown[800],
                        )),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Game title
            const Text(
              'Dual Knights',
              style: TextStyle(
                fontSize: 36,
                fontFamily: "DualKnights",
                color: Colors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Play button
            SizedBox(
              width: 150,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[400],
                  foregroundColor: Colors.white,
                  shadowColor: Colors.black,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: widget.onPlayPressed,
                child: const Text(
                  'Play',
                  style: TextStyle(fontSize: 18, fontFamily: "DualKnights"),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Settings button
            SizedBox(
              width: 150,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[400],
                  foregroundColor: Colors.white,
                  shadowColor: Colors.black,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: widget.onSettingsPressed,
                child: const Text(
                  'Settings',
                  style: TextStyle(fontSize: 18, fontFamily: "DualKnights"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
