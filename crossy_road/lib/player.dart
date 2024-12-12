// lib/player.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart'; 

class Player extends PositionComponent with HasGameRef {
  double moveDistance = 97.5;
  final double radius = 25.0; // Radius of the player circle

  Player({Vector2? position}) : super(position: position, size: Vector2.all(50));

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius, paint);
  }

  void moveUp() {
    position.y -= moveDistance;
    position.y = position.y.clamp(radius, gameRef.size.y - radius);
    FlameAudio.play('move.mp3');
  }

  void moveDown() {
    position.y += moveDistance;
    position.y = position.y.clamp(radius, gameRef.size.y - radius);
    FlameAudio.play('move.mp3'); 
  }

  void moveLeft() {
    position.x -= moveDistance;
    position.x = position.x.clamp(radius, gameRef.size.x - radius);
    FlameAudio.play('move.mp3'); 
  }

  void moveRight() {
    position.x += moveDistance;
    position.x = position.x.clamp(radius, gameRef.size.x - radius);
    FlameAudio.play('move.mp3'); 
  }
}
