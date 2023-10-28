import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:untitled/main.dart';
import 'package:untitled/player.dart';

class SeaMap extends PositionComponent with HasGameRef<FlameCompetitionGame> {
  static const double widthSize = 750;
  static const double heightSize = 5000;
  static const Rect _bounds = Rect.fromLTRB(0, 0, widthSize, heightSize);

  static final Paint _paintBg = Paint()..color = Colors.lightBlue;

  final Player? playerRef;

  SeaMap({Vector2? pos, this.playerRef})
      : super(
          priority: playerRef != null ? 1 : 0,
          position: pos ?? Vector2(0, 0),
        );

  @override
  void render(Canvas canvas) {
    canvas.drawRect(_bounds, _paintBg);
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
