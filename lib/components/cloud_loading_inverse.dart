import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CloudLoadingInverse extends Component with HasGameRef {
  final int numberOfClouds;
  final double duration;
  final List<_CloudSprite> clouds = [];
  final Random _random = Random();
  final VoidCallback? onRemoveCallback;

  double _elapsedTime = 0;
  double _overlayOpacity = 0;
  bool _isAnimating = false;
  late List<Sprite> _cloudSprites;



  CloudLoadingInverse({
    this.numberOfClouds = 200,
    this.duration = 1.7,
    this.onRemoveCallback,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Load cloud sprites
    _cloudSprites = [
      await Sprite(await game.images.load('clouds/Cloud 1.png')),
      await Sprite(await game.images.load('clouds/Cloud 2.png')),
      await Sprite(await game.images.load('clouds/Cloud 3.png')),
      await Sprite(await game.images.load('clouds/Cloud 4.png')),
      await Sprite(await game.images.load('clouds/Cloud 5.png')),
      await Sprite(await game.images.load('clouds/Cloud 6.png')),
      await Sprite(await game.images.load('clouds/Cloud 7.png')),
      await Sprite(await game.images.load('clouds/Cloud 8.png')),
      await Sprite(await game.images.load('clouds/Cloud 9.png')),
      await Sprite(await game.images.load('clouds/Cloud 10.png')),
      await Sprite(await game.images.load('clouds/Cloud 11.png')),
      await Sprite(await game.images.load('clouds/Cloud 12.png')),
      await Sprite(await game.images.load('clouds/Cloud 13.png')),
      await Sprite(await game.images.load('clouds/Cloud 14.png')),
      await Sprite(await game.images.load('clouds/Cloud 15.png')),
      await Sprite(await game.images.load('clouds/Cloud 16.png')),
      await Sprite(await game.images.load('clouds/Cloud 17.png')),
      await Sprite(await game.images.load('clouds/Cloud 18.png')),
      await Sprite(await game.images.load('clouds/Cloud 19.png')),
      await Sprite(await game.images.load('clouds/Cloud 20.png')),
    ];
    _generateClouds();
    start();
  }

  void _generateClouds() {
    clouds.clear();
    final screenWidth = gameRef.size.x;
    final screenHeight = gameRef.size.y;

    for (int i = 0; i < numberOfClouds; i++) {
      // Determine the position outside the screen
      double startX = _random.nextBool()
          ? (_random.nextDouble() < 0.5 ? -100 : screenWidth + 100) // Left or right
          : _random.nextDouble() * screenWidth; // Anywhere horizontally
      double startY = _random.nextBool()
          ? (_random.nextDouble() < 0.5 ? -100 : screenHeight + 100) // Top or bottom
          : _random.nextDouble() * screenHeight; // Anywhere vertically

      final speedFactor = _random.nextDouble() * 1 + 0.5;
      final direction = Vector2(
        (gameRef.size.x / 2 - startX), // X direction toward the center
        0.0, // Y direction toward the center
      )..normalize();

      final sprite = _cloudSprites[_random.nextInt(_cloudSprites.length)];

      clouds.add(
        _CloudSprite(
          sprite: sprite,
          size: Vector2(sprite.srcSize.x * 1.5, sprite.srcSize.y * 1.5),
          initialPosition: Vector2(startX, startY),
          direction: direction,
          speedFactor: speedFactor,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    if (!_isAnimating) return;

    _elapsedTime += dt;
    final progress = (_elapsedTime / duration).clamp(0.0, 1.0);

    if (progress >= 1.0) {
      // Start fading out the entire component
      _overlayOpacity = (_overlayOpacity + dt).clamp(0.0, 1.0);

      if (_overlayOpacity >= 1) {
        _isAnimating = false;

        removeFromParent();
      }
    }

    final screenWidth = gameRef.size.x;
    final screenHeight = gameRef.size.y;

    for (final cloud in clouds) {
      cloud.position = Vector2(
        cloud.initialPosition.x +
            cloud.direction.x * progress * cloud.speedFactor * screenWidth,
        cloud.initialPosition.y +
            cloud.direction.y * progress * cloud.speedFactor * screenHeight,
      );

      cloud.opacity = (0.0 + progress) * _overlayOpacity;
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_isAnimating && _overlayOpacity <= 0) return;

    // Interpolate background color
    final progress = (_elapsedTime / duration).clamp(0.0, 1.0);
    final backgroundColor = Color.lerp(Color.fromRGBO(71, 171, 169, 0), Color.fromRGBO(71, 171, 169, 1), progress)!;

    // Draw background with dynamic color
    canvas.drawRect(
      Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y),
      Paint()..color = backgroundColor,
    );

    // Draw clouds
    for (final cloud in clouds) {
      cloud.sprite.render(
        canvas,
        position: cloud.position,
        size: cloud.size,
        overridePaint: Paint()..color = Colors.white.withOpacity(cloud.opacity),
      );
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    // Trigger the callback when the component is removed
    onRemoveCallback?.call();
  }

  void start() {
    _elapsedTime = 0;
    _overlayOpacity = 1.0;
    _isAnimating = true;
    _generateClouds();
  }

  bool get isAnimating => _isAnimating;
}

class _CloudSprite {
  final Sprite sprite;
  final Vector2 size;
  final Vector2 direction;
  final double speedFactor;
  final Vector2 initialPosition;
  Vector2 position;
  double opacity;

  _CloudSprite({
    required this.sprite,
    required this.size,
    required this.initialPosition,
    required this.direction,
    required this.speedFactor,
  })  : position = initialPosition.clone(),
        opacity = 1.0;
}
