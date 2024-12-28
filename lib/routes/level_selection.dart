import 'package:dual_knights/dual_knights.dart';
import 'package:flutter/material.dart';

class LevelSelection extends StatelessWidget {
  const LevelSelection({
    super.key,
    this.onLevelSelected,
    this.onBackPressed,
  });

  static const id = 'LevelSelection';

  final ValueChanged<int>? onLevelSelected;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    // Sample data for levels
    final List<Level> levels = List.generate(12, (index) {
      return Level(
        id: index + 1,
        isLocked: index > 6, // Unlock the first 5 levels
        stars: index <= 4 ? (index % 4) : 0, // Randomize stars for unlocked levels
      );
    });

    return Scaffold(
      backgroundColor: Colors.brown[200], // Parchment-like background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Your Quest',
              style: TextStyle(
                fontSize: 30,
                fontFamily: "DualKnights",
                color: Colors.brown, // Add a medieval-style color
              ),
            ),
            const SizedBox(height: 15),
            Flexible(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: DualKnights.isMobile ? 2 : 3,
                  mainAxisExtent: 120,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final level = levels[index];
                  return AnimatedLevelTile(
                    level: level,
                    onTap: level.isLocked
                        ? null
                        : () => onLevelSelected?.call(level.id),
                  );
                },
                itemCount: levels.length,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
            const SizedBox(height: 15),
            IconButton(
              onPressed: onBackPressed,
              icon: const Icon(Icons.arrow_back_rounded, size: 30),
              color: Colors.brown,
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedLevelTile extends StatefulWidget {
  final Level level;
  final VoidCallback? onTap;

  const AnimatedLevelTile({Key? key, required this.level, this.onTap})
      : super(key: key);

  @override
  _AnimatedLevelTileState createState() => _AnimatedLevelTileState();
}

class _AnimatedLevelTileState extends State<AnimatedLevelTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.level.isLocked
                ? Colors.grey[700]
                : (_isHovered ? Colors.brown[400] : Colors.brown[300]),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(4, 4),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              Center(
                child: widget.level.isLocked
                    ? Icon(
                        Icons.lock,
                        size: 40,
                        color: Colors.white,
                      )
                    : Text(
                        'Level ${widget.level.id}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: "DualKnights",
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              if (!widget.level.isLocked)
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (starIndex) {
                      return Icon(
                        Icons.star,
                        size: 20,
                        color: starIndex < widget.level.stars
                            ? Colors.yellow
                            : Colors.grey[400],
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Define a Level model
class Level {
  final int id;
  final bool isLocked;
  final int stars;

  Level({required this.id, required this.isLocked, required this.stars});
}
