import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:untitled/main.dart';
import 'package:untitled/map.dart';
import 'package:untitled/player.dart';

class Fish extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<FlameCompetitionGame> {
  Fish({this.startPosY, this.isEnemy = false})
      : super(
          anchor: Anchor.center,
          priority: 2,
        );

  // TODO(Teddy): remove debug when done
  @override
  bool get debugMode => true;

  final bool isEnemy;
  final double? startPosY;

  @override
  Future<void> onLoad() async {
    final fishSize = (rng.nextInt(130) + 100).toDouble();
    size = Vector2.all(fishSize);
    position = Vector2(
      size.x / 2,
      rng.nextInt((SeaMap.heightSize - size.y).toInt()) + (startPosY ?? size.y),
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
    add(
      MoveEffect.to(
        Vector2(SeaMap.widthSize - (size.x / 2), position.y),
        EffectController(
          duration: rng.nextInt(5) + 2,
          reverseDuration: 3,
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
      removeFromParent();
    }
  }
}
