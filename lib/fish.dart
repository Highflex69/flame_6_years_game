import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:untitled/main.dart';
import 'package:untitled/map.dart';
import 'package:untitled/player.dart';

class Fish extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<FlameCompetitionGame> {
  static int maxSize = 130;

  Fish({this.minStartPosY})
      : super(
          anchor: Anchor.center,
          priority: 2,
        );

  final double? minStartPosY;

  @override
  Future<void> onLoad() async {
    final fishSize = (rng.nextInt(maxSize) + 100).toDouble();
    size = Vector2.all(fishSize);
    position = Vector2(
      size.x / 2,
      rng.nextInt((SeaMap.heightSize - size.y).toInt()) +
          (minStartPosY ?? size.y),
    );

    animation = await game.loadSpriteAnimation(
      'fish_${rng.nextInt(4) + 1}.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(48),
      ),
    );
    add(RectangleHitbox.relative(Vector2(0.8, 0.3), parentSize: size));
    final movementSpeed = rng.nextInt(5) + 1.0;
    add(
      MoveEffect.to(
        Vector2(SeaMap.widthSize - (size.x / 2), position.y),
        EffectController(
          duration: movementSpeed,
          reverseDuration: movementSpeed,
          infinite: true,
          curve: Curves.easeOut,
        ),
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
      gameRef.gameOver();
      if (gameRef.state == GameState.gameOver) {
        gameRef.setScore(addFishCaughtCount: 1);
        gameRef.player.add(
          SpriteAnimationComponent(animation: animation, size: size),
        );
        removeFromParent();
      }
    }
  }
}
