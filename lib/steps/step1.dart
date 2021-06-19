import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/extensions.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart' hide Draggable;

final _overlayText = TextStyle(
  fontFamily: 'press-start-2p',
  fontSize: 20,
  color: Colors.white,
);

final _paintWhite = BasicPalette.white.paint();
final _paintBorder = BasicPalette.white.paint()..style = PaintingStyle.stroke;
final _paintRed = BasicPalette.red.paint()..blendMode = BlendMode.lighten;
final _paintGreen = BasicPalette.green.paint()..blendMode = BlendMode.lighten;
final _paintBlue = BasicPalette.blue.paint()..blendMode = BlendMode.lighten;

void main() {
  runApp(GameWidget(game: BreakoutGame()));
}

class BreakoutGame extends BaseGame with HasDraggableComponents {
  @override
  Future<void> onLoad() async {
    camera.shakeIntensity = 5;
    viewport = FixedResolutionViewport(Vector2(640, 1280));
  }
}
