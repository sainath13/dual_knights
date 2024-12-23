import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  CollisionBlock({
    required Vector2 position,
    required Vector2 size,
  }) : super(
    position: position,
    size: size,
  ) {
    // Add hitbox for collision detection
    add(RectangleHitbox());
  }
}