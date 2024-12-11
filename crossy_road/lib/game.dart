// lib/game.dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'player.dart';
import 'obstacle.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

// Define lane types
enum LaneType { road, river }

// BackgroundComponent to render lane backgrounds
class BackgroundComponent extends PositionComponent with HasGameRef<CrossyRoadGame> {
  final List<LaneType> laneTypes;
  final double laneHeight;
  final int numberOfLanes;

  BackgroundComponent({
    required this.laneTypes,
    required this.laneHeight,
    required this.numberOfLanes,
  });

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (int i = 0; i < numberOfLanes; i++) {
      final laneType = laneTypes[i];
      Paint paint;
      switch (laneType) {
        case LaneType.road:
          paint = Paint()..color = Colors.grey;
          break;
        case LaneType.river:
          paint = Paint()..color = Colors.blue;
          break;
      }
      // Draw each lane as a horizontal rectangle
      canvas.drawRect(
        Rect.fromLTWH(0, i * laneHeight, gameRef.size.x, laneHeight),
        paint,
      );
    }
  }
}

class CrossyRoadGame extends FlameGame with HasCollisionDetection {
  late Player player;
  final double laneHeight = 100.0;
  final int numberOfLanes = 5;
  final List<Obstacle> obstacles = [];
  final Random random = Random();

  List<LaneType> laneTypes = [];
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0); // Score Tracking
  final ValueNotifier<int> livesNotifier = ValueNotifier<int>(3); // Lives Tracking

  Obstacle? currentLog; // Tracks the log the player is on

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize audio
    await FlameAudio.audioCache.loadAll(['move.mp3', 'death.mp3']);

    // Initialize lane types
    laneTypes = List.generate(
      numberOfLanes,
      (index) => index % 2 == 0 ? LaneType.road : LaneType.river,
    );

    // Add Background
    add(BackgroundComponent(
      laneTypes: laneTypes,
      laneHeight: laneHeight,
      numberOfLanes: numberOfLanes,
    ));

    // Initialize player
    player = Player()
      ..position = Vector2(size.x / 2, size.y - laneHeight / 2)
      ..anchor = Anchor.center;
    add(player);

    // Initialize lanes with obstacles based on lane type
    for (int i = 0; i < numberOfLanes; i++) {
      double y = (i + 0.5) * laneHeight; // Center of the lane
      LaneType laneType = laneTypes[i];

      if (laneType == LaneType.road) {
        // Road lane with cars
        for (int j = 0; j < 3; j++) {
          Obstacle car = Obstacle(
            type: ObstacleType.car,
            size: Vector2(50, 30), // Width x Height
            position: Vector2(100.0 * j + random.nextDouble() * 50, y),
            speed: random.nextBool() ? 100.0 : -100.0,
          );
          obstacles.add(car);
          add(car);
        }
      } else if (laneType == LaneType.river) {
        // River lane with logs
        for (int j = 0; j < 2; j++) {
          Obstacle log = Obstacle(
            type: ObstacleType.log,
            size: Vector2(100, 30), // Width x Height
            position: Vector2(150.0 * j + random.nextDouble() * 50, y),
            speed: random.nextBool() ? 60.0 : -60.0,
          );
          obstacles.add(log);
          add(log);
        }
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Determine the current lane of the player
    int playerLane = (player.position.y / laneHeight).floor();
    if (playerLane < 0) playerLane = 0;
    if (playerLane >= numberOfLanes) playerLane = numberOfLanes - 1;

    LaneType currentLaneType = laneTypes[playerLane];

    if (currentLaneType == LaneType.road) {
      // Check for collision with cars
      for (var obstacle in obstacles.where((o) => o.type == ObstacleType.car)) {
        if (player.toRect().overlaps(obstacle.toRect())) {
          // Collision with car: reset player and play death sound
          resetPlayer();
          FlameAudio.play('death.mp3');
          break;
        }
      }
    } else if (currentLaneType == LaneType.river) {
      bool onLog = false;
      Obstacle? logObstacle;

      // Check if player is on any log
      for (var obstacle in obstacles.where((o) => o.type == ObstacleType.log)) {
        if (player.toRect().overlaps(obstacle.toRect())) {
          onLog = true;
          logObstacle = obstacle;
          break;
        }
      }

      if (onLog && logObstacle != null) {
        // Carry the player with the log
        player.position.x += logObstacle.speed * dt;
        // Clamp player's position within screen boundaries
        player.position.x = player.position.x.clamp(player.radius, size.x - player.radius);
      } else {
        // Player is in water without a log: reset player and play death sound
        resetPlayer();
        FlameAudio.play('death.mp3');
      }
    }

    // Check if player reached the top
    if (player.position.y < laneHeight / 2) {
      // Player wins: reset position and increment score
      resetPlayer();
      scoreNotifier.value += 1; // Increment score
      FlameAudio.play('move.mp3'); 
    }
  }

  void resetPlayer() {
    player.position = Vector2(size.x / 2, size.y - laneHeight / 2);
    livesNotifier.value -= 1;
    if (livesNotifier.value <= 0) {
      livesNotifier.value = 3;
      scoreNotifier.value = 0;
    }
  }
}
