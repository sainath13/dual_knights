

import 'package:flame/components.dart';

import '../../dual_knights.dart';

enum DyingState {
  dying,
  vanishing,
  dead,
}


class DyingKnight extends SpriteAnimationComponent with HasGameRef<DualKnights>{
  static const double frameWidth = 128;
  static const double frameHeight = 128;
  static const double gridSize = 64.0;

  late final Map<DyingState, SpriteAnimation> animations;
  DyingState currentState = DyingState.dying;
  Vector2 currentPosition = Vector2.zero();
  DyingKnight({required Vector2 position}) : super(size: Vector2(frameWidth, frameHeight)) {
    this.position = position;
    currentPosition = position.clone();
  }
  @override
  Future<void> onLoad() async {
    final deathSheet = await gameRef.images.load('Factions/Knights/Troops/Dead/Dead.png');
    animations = {
      DyingState.dying: SpriteAnimation.fromFrameData(
        deathSheet,
        SpriteAnimationData.sequenced(
          amount: 7,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, 16),
        ),
      ),
      DyingState.vanishing: SpriteAnimation.fromFrameData(
        deathSheet,
        SpriteAnimationData.sequenced(
          amount: 7,
          textureSize: Vector2(frameWidth, frameHeight),
          stepTime: 0.1,
          loop: false,
          texturePosition: Vector2(0, frameHeight+16),
        ),
      ),
    };

    animation = animations[DyingState.dying];
  }

  void _updateState() {
    if (currentState == DyingState.dead) return;
    if (animationTicker?.isLastFrame ?? false) {
      switch (currentState) {


        case DyingState.dying:
          currentState = DyingState.vanishing;
          animation = animations[DyingState.vanishing];
          animationTicker?.reset();
          break;

        case DyingState.vanishing:
          currentState = DyingState.dead;
          removeFromParent();
          // ancestor.onGameOver();  //TODO @Sarvesh
          break;

        default:
          break;
      }
      return;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateState();
  }

}