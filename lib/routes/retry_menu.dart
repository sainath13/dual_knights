import 'package:flutter/material.dart';

class RetryMenu extends StatelessWidget {
  const RetryMenu({
    super.key,
    this.onRetryPressed,
    this.onExitPressed,
  });

  static const id = 'RetryMenu';

  final VoidCallback? onRetryPressed;
  final VoidCallback? onExitPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[200], // Medieval parchment-like background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated "Game Over" text with glowing effect
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 1.0, end: 1.2),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale as double,
                  child: Text(
                    'Game Over',
                    style: TextStyle(
                      fontSize: 36,
                      fontFamily: "DualKnights",
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                );
              },
              onEnd: () {
                // Loops the glow animation
                Future.delayed(const Duration(milliseconds: 300), () {
                  (context as Element).markNeedsBuild();
                });
              },
            ),
            const SizedBox(height: 20),
            // Retry button
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
                onPressed: onRetryPressed,
                child: const Text(
                  'Retry',
                  style: TextStyle(fontSize: 18, fontFamily: "DualKnights"),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Exit button
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
                onPressed: onExitPressed,
                child: const Text(
                  'Exit',
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
