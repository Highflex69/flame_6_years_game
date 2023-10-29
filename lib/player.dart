import 'package:deep_fishing/main.dart';
import 'package:deep_fishing/map.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

class Player extends SpriteComponent
    with CollisionCallbacks, HasGameRef<FlameCompetitionGame>, KeyboardHandler {
  static const double speed = 300;
  static const double droppingSpeed = 100;

  static const scaledPlayerSize = 48 * 4;
  static const hookScale = 0.8;
  static final Vector2 startPos = Vector2((SeaMap.widthSize / 2) - 48, 0);
  final Vector2 velocity = Vector2.zero();
  late final maxPosition =
      Vector2(SeaMap.widthSize - size.x / 2, SeaMap.heightSize - (size.y / 2));
  late SpriteAnimationComponent playerAnimation;

  Player()
      : super(
          priority: 2,
          size: Vector2.all(100),
          position: startPos,
          scale: Vector2.all(hookScale),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    playerAnimation = SpriteAnimationComponent(
      animation: await game.loadSpriteAnimation(
        'player_idle.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.2,
          textureSize: Vector2.all(48),
        ),
      ),
      scale: Vector2.all(4),
      position: Vector2(
        (SeaMap.widthSize / 2) - scaledPlayerSize,
        position.y - scaledPlayerSize,
      ),
    );
    sprite =
        await game.loadSprite('fishing_hook.png', srcSize: Vector2.all(32));
    add(RectangleHitbox.relative(Vector2(0.5, 0.5), parentSize: size));
    gameRef.world.add(playerAnimation);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * (speed * dt));
    position.clamp(
      Vector2(-(size.x / 4), 0),
      Vector2(maxPosition.x, maxPosition.y * gameRef.mapAdded),
    );

    if (gameRef.state == GameState.playing) {
      gameRef.setScore(newScore: position.y.toInt());
      position.add(Vector2(0, droppingSpeed * dt));
      if ((position.y - SeaMap.heightSize * gameRef.mapAdded) >
          -(SeaMap.heightSize * 0.8)) {
        gameRef.generateMap();
      }
    }
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is RawKeyDownEvent;

    final bool handled;
    final speed = (gameRef.state == GameState.gameOver ? 2.0 : 1.0);
    if (event.logicalKey == LogicalKeyboardKey.keyA) {
      velocity.x = isKeyDown ? -speed : 0;
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
      velocity.x = isKeyDown ? speed : 0;
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      if (gameRef.state == GameState.intro) {
        gameRef.state = GameState.playing;
      }
      handled = true;
    } else {
      handled = false;
    }

    return !handled && super.onKeyEvent(event, keysPressed);
  }
}
