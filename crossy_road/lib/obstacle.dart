// lib/obstacle.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum ObstacleType { car, log }

class Obstacle extends PositionComponent with HasGameRef {
  final ObstacleType type;
  double speed;
  final double originalSpeed;

  Obstacle({
    required this.type,
    required Vector2 position,
    required Vector2 size,
    required this.speed,
  })  : originalSpeed = speed,
        super(position: position, size: size, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = type == ObstacleType.car ? Colors.red : Colors.brown;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += speed * dt;

    // Wrap around the screen
    if (speed > 0 && position.x > gameRef.size.x + size.x / 2) {
      position.x = -size.x / 2;
    } else if (speed < 0 && position.x < -size.x / 2) {
      position.x = gameRef.size.x + size.x / 2;
    }

    // Example Animation: Slight vertical oscillation for logs
    // if (type == ObstacleType.log) {
    //   position.y += sin(gameRef.gameLoopTime.elapsedSeconds * 5) * 0.5;
    // }
  }
}
