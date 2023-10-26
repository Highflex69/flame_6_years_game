import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:untitled/fish.dart';
import 'package:untitled/map.dart';
import 'package:untitled/player.dart';

final rng = Random();

void main() {
  runApp(GameWidget(game: FlameCompetitionGame()));
}

class FlameCompetitionGame extends FlameGame
    with
        HasCollisionDetection,
        HasKeyboardHandlerComponents,
        ScrollDetector,
        MouseMovementDetector {
  FlameCompetitionGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: 1500,
            height: 1280,
          ),
        );

  final Player player = Player();
  int caughtCount = 1;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    world.add(SeaMap());
    _generateFishes();
    world.add(player);
    camera.follow(player, maxSpeed: 250);
  }

  void _generateFishes() {
    for (var i = 0; i < 10; i++) {
      world.add(Fish());
    }
  }

/*
  @override
  void onMouseMove(PointerHoverInfo info) {
    super.onMouseMove(info);
    if (info.raw.localDelta.dx.isNegative) {
      player.velocity.x = -1 * 0.8;
    } else {
      player.velocity.x = 1 * 0.8;
    }
  }*/

  @override
  void onScroll(PointerScrollInfo info) {
    final speedReduction = caughtCount * 0.2;
    if (info.scrollDelta.global.y.isNegative) {
      player.velocity.y = 1;
    } else {
      player.velocity.y = speedReduction <= 1 ? -1.5 + speedReduction : -0.2;
    }
  }
}
