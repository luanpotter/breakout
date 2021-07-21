import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: BreakoutGame()));
}

final _paintWhite = BasicPalette.white.paint();
final _paintBorder = BasicPalette.white.paint()..style = PaintingStyle.stroke;
final _paintRed = BasicPalette.red.paint()..blendMode = BlendMode.lighten;
final _paintGreen = BasicPalette.green.paint()..blendMode = BlendMode.lighten;
final _paintBlue = BasicPalette.blue.paint()..blendMode = BlendMode.lighten;

class Bg extends Component with HasGameRef<BreakoutGame> {
  void render(Canvas c) {
    c.drawRect(gameRef.size.toRect().deflate(1.0), _paintBorder);
  }

  @override
  bool get isHud => true;

  @override
  int get priority => -1;
}

class BreakoutGame extends BaseGame with HasDraggableComponents {
  @override
  Future<void> onLoad() async {
    camera.shakeIntensity = 5;
    viewport = FixedResolutionViewport(Vector2(640, 1280));

    add(Bg());
  }
}
