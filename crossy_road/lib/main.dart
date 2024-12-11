// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false, 
    home: GameWidgetWrapper(),
  ));
}

class GameWidgetWrapper extends StatefulWidget {
  @override
  _GameWidgetWrapperState createState() => _GameWidgetWrapperState();
}

class _GameWidgetWrapperState extends State<GameWidgetWrapper> {
  late CrossyRoadGame game;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    game = CrossyRoadGame();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              game.player.moveUp();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              game.player.moveDown();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              game.player.moveLeft();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              game.player.moveRight();
            }
          }
        },
        child: Stack(
          children: [
            GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.velocity.pixelsPerSecond.dy < 0) {
                  game.player.moveUp();
                } else {
                  game.player.moveDown();
                }
              },
              onHorizontalDragEnd: (details) {
                if (details.velocity.pixelsPerSecond.dx > 0) {
                  game.player.moveRight();
                } else {
                  game.player.moveLeft();
                }
              },
              child: GameWidget<CrossyRoadGame>(
                game: game,
                backgroundBuilder: (context) => Container(color: Colors.green[700]!),
              ),
            ),
            Positioned(
              bottom: 50,
              left: 50,
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      game.player.moveUp();
                    },
                    mini: true,
                    child: Icon(Icons.arrow_upward),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          game.player.moveLeft();
                        },
                        mini: true,
                        child: Icon(Icons.arrow_back),
                      ),
                      SizedBox(width: 10),
                      FloatingActionButton(
                        onPressed: () {
                          game.player.moveRight();
                        },
                        mini: true,
                        child: Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  FloatingActionButton(
                    onPressed: () {
                      game.player.moveDown();
                    },
                    mini: true,
                    child: Icon(Icons.arrow_downward),
                  ),
                ],
              ),
            ),
            // Display Score
            Positioned(
              top: 20,
              left: 20,
              child: ValueListenableBuilder<int>(
                valueListenable: game.scoreNotifier,
                builder: (context, score, child) {
                  return Text(
                    'Score: $score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            // Display Lives
            Positioned(
              top: 60,
              left: 20,
              child: ValueListenableBuilder<int>(
                valueListenable: game.livesNotifier,
                builder: (context, lives, child) {
                  return Text(
                    'Lives: $lives',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
