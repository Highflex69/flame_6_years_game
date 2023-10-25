import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';

class SeaMap extends Component {
  static const double width = 750;
  static const double height = 1500;
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
  }
}
