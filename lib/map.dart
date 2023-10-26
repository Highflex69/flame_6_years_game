import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:untitled/main.dart';
import 'package:untitled/player.dart';

class SeaMap extends Component with HasGameRef<FlameCompetitionGame> {
  static const double width = 750;
  static const double height = 3000;
  static const Rect _bounds = Rect.fromLTRB(0, 0, width, height);
  static final Rectangle bounds = Rectangle.fromLTRB(0, 0, width, height);

  static final Paint _paintBorder = Paint()
    ..color = Colors.white12
    ..strokeWidth = 10
    ..style = PaintingStyle.stroke;
  static final Paint _paintBg = Paint()..color = Colors.lightBlue;

  SeaMap() : super(priority: 0);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(_bounds, _paintBg);
    canvas.drawRect(_bounds, _paintBorder);
    canvas.drawLine(
      const Offset((SeaMap.width / 2) - 18, 0),
      Offset(
        gameRef.player.position.x +
            (gameRef.player.size.x * Player.hookScale / 2) +
            3,
        gameRef.player.position.y + 3,
      ),
      Paint()
        ..color = const Color.fromRGBO(157, 162, 177, 0.7)
        ..strokeJoin = StrokeJoin.bevel
        ..strokeWidth = 5,
    );
  }
}
