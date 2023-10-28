import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:untitled/main.dart';
import 'package:untitled/map.dart';

class Player extends SpriteComponent
    with CollisionCallbacks, HasGameRef<FlameCompetitionGame>, KeyboardHandler {
  final Vector2 velocity = Vector2.zero();
  late final maxPosition =
      Vector2(SeaMap.widthSize - size.x / 2, SeaMap.heightSize - (size.y / 2));
  late final minPosition = Vector2(-(size.x / 4), 0);
  static const double speed = 300;
  static const double droppingSpeed = 100;

  static const scaledPlayerSize = 48 * 4;
  static const hookScale = 0.8;
  static final Vector2 startPos = Vector2((SeaMap.widthSize / 2) - 48, 0);

  Player()
      : super(
          priority: 2,
          size: Vector2.all(100),
          position: startPos,
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
        (SeaMap.widthSize / 2) - scaledPlayerSize,
        position.y - scaledPlayerSize,
      ),
    )..debugMode = true;
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
    position.clamp(
      minPosition,
      Vector2(maxPosition.x, maxPosition.y * gameRef.mapAdded),
    );

    if (gameRef.state == GameState.playing) {
      gameRef.score = position.y.toInt();
      position.add(Vector2(0, droppingSpeed * dt));
      if ((position.y - SeaMap.heightSize * gameRef.mapAdded) >
          -(gameRef.camera.visibleWorldRect.height * 0.4)) {
        gameRef.generateMap();
      }
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
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      if (gameRef.state != GameState.playing) {
        gameRef.state = GameState.playing;
      }
      velocity.y = isKeyDown ? -1 : 0;
      handled = true;
    } else {
      handled = false;
    }

    return !handled && super.onKeyEvent(event, keysPressed);
  }
}
