import 'package:flutter/material.dart';

class LevelComplete extends StatelessWidget {
  const LevelComplete({
    required this.nStars,
    super.key,
    this.onNextPressed,
    this.onRetryPressed,
    this.onExitPressed,
  });

  static const id = 'LevelComplete';

  final int nStars;
  final VoidCallback? onNextPressed;
  final VoidCallback? onRetryPressed;
  final VoidCallback? onExitPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[200], // Parchment-style background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated "Level Completed" text
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 1.0, end: 1.1),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale as double,
                  child: Text(
                    'LEVEL COMPLETED',
                    style: TextStyle(
                      fontSize: 36,
                      fontFamily: "DualKnights",
                      color: Colors.green[800],
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
            ),
            const SizedBox(height: 20),
            // Stars row with animations
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isActive = index < nStars;
                return AnimatedOpacity(
                  opacity: isActive ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 500),
                  child: Icon(
                    isActive ? Icons.star : Icons.star_border,
                    color: isActive ? Colors.amber : Colors.black,
                    size: 50,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            // Buttons
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
                onPressed: nStars != 0 ? onNextPressed : null,
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 18, fontFamily: "DualKnights"),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
