import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:untitled/main.dart';
import 'package:untitled/player.dart';

class SeaMap extends PositionComponent with HasGameRef<FlameCompetitionGame> {
  static const double widthSize = 1000;
  static const double heightSize = 4000;
  static const Rect _bounds = Rect.fromLTRB(0, 0, widthSize, heightSize);
  final double darken;
  final Player? playerRef;

  SeaMap({Vector2? pos, this.playerRef, this.darken = 0})
      : super(
          priority: playerRef != null ? 1 : 0,
          position: pos ?? Vector2.zero(),
        );

  @override
  void render(Canvas canvas) {
    final backgroundPaint = Paint()..color = Colors.lightBlue.darken(darken);
    canvas.drawRect(_bounds, backgroundPaint);
    if (playerRef != null) {
      canvas.drawLine(
        const Offset((SeaMap.widthSize / 2) - 18, 0),
        Offset(
          playerRef!.position.x +
              (playerRef!.size.x * Player.hookScale / 2) +
              3,
          playerRef!.position.y + 3,
        ),
        Paint()
          ..color = const Color.fromRGBO(157, 162, 177, 0.7)
          ..strokeJoin = StrokeJoin.bevel
          ..strokeWidth = 5,
      );
    }
  }
}
