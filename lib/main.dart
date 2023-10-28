import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
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
  FlameCompetitionGame() : super();

  final Player player = Player();
  GameState state = GameState.gameOver;

  late final TextComponent scoreText;
  int fishCaughtCount = 0;
  int mapAdded = 1;
  int _score = 0;
  int _highScore = 0;

  int get score => _score;

  set score(int newScore) {
    _score = newScore + (fishCaughtCount * 10);
    scoreText.text = 'Score: $_score Highscore: $_highScore';
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    world.add(player);
    world.add(SeaMap(playerRef: player));
    _generateFishes();
    camera.follow(player, maxSpeed: 400);
    camera.viewport.add(scoreText = TextComponent(position: Vector2(20, 20)));
    score = 0;
  }

  void _generateFishes({double? startPos}) {
    for (var i = 0; i < 20; i++) {
      world.add(
        Fish(startPosY: startPos),
      );
    }
  }

  @override
  void onScroll(PointerScrollInfo info) {
    if (state == GameState.gameOver) {
      return;
    }
    if (info.scrollDelta.global.y.isNegative) {
      player.velocity.y = 1;
    } else {
      player.velocity.y = -1.5;
    }
  }

  void generateMap() {
    world.add(
      SeaMap(
        pos: Vector2(0, SeaMap.heightSize * mapAdded),
      ),
    );
    mapAdded += 1;
    _generateFishes(
      startPos: (SeaMap.heightSize * mapAdded) - SeaMap.heightSize,
    );
  }

  void gameOver() {
    if (state != GameState.gameOver) {
      state = GameState.gameOver;
      score = _highScore = _highScore < _score ? _score : _highScore;
      camera.follow(player, snap: true);
      player.velocity.y = 0;
      player.add(
        MoveEffect.to(
          Player.startPos,
          EffectController(
            duration: 1,
            curve: Curves.easeIn,
          ),
        ),
      );
    }
  }
}

enum GameState {
  intro,
  playing,
  gameOver;
}
