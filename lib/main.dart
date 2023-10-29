import 'dart:math';

import 'package:deep_fishing/fish.dart';
import 'package:deep_fishing/map.dart';
import 'package:deep_fishing/player.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

final rng = Random();

void main() => runApp(GameWidget(game: FlameCompetitionGame()));

class FlameCompetitionGame extends FlameGame
    with
        HasCollisionDetection,
        HasKeyboardHandlerComponents,
        ScrollDetector,
        MouseMovementDetector {
  final Player player = Player();
  late final TextComponent scoreText;
  GameState state = GameState.intro;
  int mapAdded = 1;
  int _score = 0;
  int _highScore = 0;

  void setScore({int? newScore, int? addFishCaughtCount}) {
    if (newScore != null) {
      _score = newScore;
    }
    if (addFishCaughtCount != null) {
      _score += addFishCaughtCount * 10;
    }
    if (state == GameState.gameOver) {
      _highScore = _highScore < _score ? _score : _highScore;
    }
    scoreText.text = 'Score: $_score Highscore: $_highScore';
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    world.add(player);
    world.add(SeaMap(playerRef: player));
    _generateFishes();
    camera.follow(player, maxSpeed: 600);
    camera.viewport.add(
      scoreText = TextComponent(
        position: Vector2.all(20),
        scale: Vector2.all(1.5),
      ),
    );
    setScore(newScore: 0);
  }

  @override
  void onScroll(PointerScrollInfo info) {
    if (state != GameState.playing) {
      return;
    }
    if (info.scrollDelta.global.y.isNegative) {
      player.velocity.y = 1;
    } else {
      player.velocity.y = -1.6;
    }
  }

  void _generateFishes({double? minStartPosY}) {
    for (var i = 0; i < (SeaMap.heightSize / Fish.maxSize * 0.65); i++) {
      world.add(Fish(minStartPosY: minStartPosY));
    }
  }

  void generateMap() {
    world.add(
      SeaMap(
        pos: Vector2(0, SeaMap.heightSize * mapAdded),
        darken: mapAdded / 10 < 1 ? mapAdded / 10 : 0.9,
      ),
    );
    mapAdded += 1;
    _generateFishes(
      minStartPosY: (SeaMap.heightSize * mapAdded) - SeaMap.heightSize,
    );
  }

  void gameOver() {
    if (state != GameState.gameOver) {
      state = GameState.gameOver;
      setScore(newScore: _score);
      camera.follow(player, snap: true);
      player.velocity.y = 0;
      player.add(
        MoveEffect.to(
          Player.startPos,
          EffectController(
            duration: mapAdded.toDouble(),
            curve: Curves.easeIn,
          ),
          onComplete: restartGame,
        ),
      );
    }
  }

  Future<void> restartGame() async {
    await Future.delayed(const Duration(seconds: 3));
    state = GameState.intro;
    mapAdded = 1;
    world.removeWhere((c) => c is Fish);
    player.removeWhere((c) => c is SpriteAnimationComponent);
    _generateFishes();
  }
}

enum GameState {
  intro,
  playing,
  gameOver;
}
