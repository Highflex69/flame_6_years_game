import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled/map.dart';

void main() {
  runApp(GameWidget(game: FlameCompetitionGame()));
}

class FlameCompetitionGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  FlameCompetitionGame()
      : super(
            camera: CameraComponent.withFixedResolution(
          width: 1500,
          height: 1280,
        ));

  late final Player _player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _player = Player();
    world.add(SeaMap());
    world.add(Fish(Vector2(5, 0), Vector2(0, 500), Vector2.all(100.0)));
    world.add(_player);
    camera.follow(_player, maxSpeed: 250);
  }
}

class Player extends SpriteComponent
    with CollisionCallbacks, HasGameRef, KeyboardHandler {
  final Vector2 velocity = Vector2.zero();
  late ShapeHitbox hitbox;
  late final maxPosition =
      Vector2(SeaMap.width - size.x / 2, SeaMap.height + (size.y / 2));
  late final minPosition = Vector2(0, 0);
  static const double speed = 300;

  bool hasGameStarted = false;

  Player()
      : super(
          priority: 2,
          size: Vector2.all(100),
          position: Vector2(720 / 2, 0),
        );

  @override
  bool debugMode = true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite(
      'fishing_hook.png',
      srcSize: Vector2.all(32),
    );

    hitbox = CircleHitbox();
    add(hitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final deltaPosition = velocity * (speed * dt);
    position.add(deltaPosition);
    position.clamp(minPosition, maxPosition);
    if (hasGameStarted) {
      position.add(Vector2(0, 1));
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
      if (!hasGameStarted) {
        hasGameStarted = true;
      }
      velocity.y = isKeyDown ? -1 : 0;
      handled = true;
    } else {
      handled = false;
    }

    if (handled) {
      return false;
    } else {
      return super.onKeyEvent(event, keysPressed);
    }
  }
}

class Fish extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef {
  final Vector2 velocity;

  Fish(this.velocity, Vector2 position, Vector2 size)
      : super(
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    animation = await game.loadSpriteAnimation(
      'fish_1.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(48),
      ),
    );

    add(CircleHitbox());

    add(
      MoveEffect.to(
          Vector2(SeaMap.width - size.x, 600),
          EffectController(
            duration: 3,
            reverseDuration: 3,
            infinite: true,
            curve: Curves.easeOut,
          )
      ),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      removeFromParent();
      //add points;
      return;
    }
  }
}
