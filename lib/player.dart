import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:untitled/main.dart';
import 'package:untitled/map.dart';

class Player extends SpriteComponent
    with CollisionCallbacks, HasGameRef<FlameCompetitionGame>, KeyboardHandler {
  final Vector2 velocity = Vector2.zero();
  late final maxPosition =
      Vector2(SeaMap.width - size.x / 2, SeaMap.height - (size.y / 2));
  late final minPosition = Vector2(-(size.x / 2), 0);
  static const double speed = 300;
  static const double droppingSpeed = 100;

  bool hasGameStarted = false;

  static const scaledPlayerSize = 48 * 4;
  static const hookScale = 0.8;

  Player()
      : super(
          priority: 2,
          size: Vector2.all(100),
          position: Vector2((SeaMap.width / 2) - 48, 0),
          scale: Vector2.all(hookScale),
        );

  late SpriteAnimationComponent playerAnimation;

  // TODO(Teddy): remove debug when done
  @override
  bool get debugMode => true;

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
        (SeaMap.width / 2) - scaledPlayerSize,
        position.y - scaledPlayerSize,
      ),
    )..debugMode = false;
    sprite = await game.loadSprite(
      'fishing_hook.png',
      srcSize: Vector2.all(32),
    );
    add(RectangleHitbox.relative(Vector2(0.5, 0.5), parentSize: size));
    gameRef.world.add(playerAnimation);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * (speed * dt));
    position.clamp(minPosition, maxPosition);
    if (hasGameStarted) {
      position.add(Vector2(0, droppingSpeed * dt));
    }
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is RawKeyDownEvent;

    final bool handled;
    if (event.logicalKey == LogicalKeyboardKey.keyA) {
      velocity.x = isKeyDown ? -1 : 0;
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
      velocity.x = isKeyDown ? 1 : 0;
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
      velocity.y = isKeyDown ? 0.5 : 0;
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      if (!hasGameStarted) {
        hasGameStarted = true;
      }
      //velocity.y = isKeyDown ? -1 : 0;
      gameRef.caughtCount = gameRef.caughtCount > 0
          ? gameRef.caughtCount - 1
          : gameRef.caughtCount;
      handled = true;
    } else {
      handled = false;
    }

    return !handled && super.onKeyEvent(event, keysPressed);
  }
}
