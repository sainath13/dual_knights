import 'package:flame/components.dart';

class CameraMovementComponent extends Component {
  final CameraComponent camera;
  final Vector2 startPosition;
  final Vector2 targetPosition;
  final double duration;

  double elapsedTime = 0.0;

  CameraMovementComponent({
    required this.camera,
    required this.startPosition,
    required this.targetPosition,
    required this.duration,
  });

  @override
  void update(double dt) {
    super.update(dt);

    elapsedTime += dt;

    // Calculate the progress of the interpolation (0.0 to 1.0)
    final progress = (elapsedTime / duration).clamp(0.0, 1.0);
    camera.viewfinder.position = startPosition + (targetPosition - startPosition) * progress;

    // Remove the component when movement is complete
    if (progress >= 1.0) {
      removeFromParent();
    }
  }
}