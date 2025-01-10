import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import '../dual_knights.dart';
import 'game_button.dart';

class HoverEffectButton extends PositionComponent with HasGameRef<DualKnights>{
  final GameButton gameButton;
  final double edgeOffset = 10; // Distance for animation
  bool isHovered = false;
  double elapsedTime = 0.0;

  late SpriteComponent leftTopEdge, rightTopEdge, rightBottomEdge, leftBottomEdge;

  HoverEffectButton({required this.gameButton}) {
    size = gameButton.size;
    position = gameButton.position;
    add(gameButton);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Load separate sprites for each edge
    final leftTopSprite = Sprite(await gameRef.images.load('UI/Pointers/03.png'));
    final rightTopSprite = Sprite(await gameRef.images.load('UI/Pointers/03.png'));
    final leftBottomSprite = Sprite(await gameRef.images.load('UI/Pointers/03.png'));
    final rightBottomSprite = Sprite(await gameRef.images.load('UI/Pointers/03.png'));

    // Initialize edge components
    leftTopEdge = SpriteComponent()
      ..sprite = leftTopSprite
      ..size = Vector2(64, 64)
      ..position = Vector2(-edgeOffset, -edgeOffset);

    rightTopEdge = SpriteComponent()
      ..sprite = rightTopSprite
      ..size = Vector2(64, 64)
      ..position = Vector2(size.x - 64 + edgeOffset, -edgeOffset);

    rightBottomEdge = SpriteComponent()
      ..sprite = rightBottomSprite
      ..size = Vector2(64, 64)
      ..position = Vector2(size.x - 64 + edgeOffset, size.y - 64 + edgeOffset);

    leftBottomEdge = SpriteComponent()
      ..sprite = leftBottomSprite
      ..size = Vector2(64, 64)
      ..position = Vector2(-edgeOffset, size.y - 64 + edgeOffset);

    // Add edges as children
    addAll([leftTopEdge, rightTopEdge, rightBottomEdge, leftBottomEdge]);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isHovered) {
      elapsedTime += dt;
      double animationOffset = (edgeOffset * (0.5 + 0.5 * sin(elapsedTime * 5))).toDouble();

      // Update positions of edges to oscillate
      leftTopEdge.position.setValues(-animationOffset, -animationOffset);
      rightTopEdge.position.setValues(size.x - 64 + animationOffset, -animationOffset);
      rightBottomEdge.position.setValues(size.x - 64 + animationOffset, size.y - 64 + animationOffset);
      leftBottomEdge.position.setValues(-animationOffset, size.y - 64 + animationOffset);
    } else {
      elapsedTime = 0; // Reset animation when not hovered
    }
  }
}

class HoverRegionWrapper extends StatelessWidget {
  final HoverEffectButton hoverButton;

  HoverRegionWrapper({required this.hoverButton});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        hoverButton.isHovered = true;
      },
      onExit: (_) {
        hoverButton.isHovered = false;
      },
      child: GameWidget(
        game: FlameGame()..add(hoverButton),
      ),
    );
  }
}
