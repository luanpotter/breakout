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

class Bg extends Component with HasGameRef<BreakoutGame> {
  void render(Canvas c) {
    c.drawRect(gameRef.size.toRect().deflate(1.0), _paintBorder);
  }

  @override
  bool get isHud => true;

  @override
  int get priority => -1;
}

class Platform extends PositionComponent
    with HasGameRef<BreakoutGame>, Draggable {
  @override
  Future<void>? onLoad() {
    anchor = Anchor.topCenter;
    x = gameRef.size.x / 2;
    y = gameRef.size.y - 100;
    size = Vector2(100, 20);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _paintWhite);
  }

  late Vector2 previousPosition = position;
  Vector2 averageVelocity = Vector2.zero();

  @override
  void update(double dt) {
    super.update(dt);
    if (dt != 0) {
      this.averageVelocity = (position - this.previousPosition) / dt;
      this.previousPosition = position.clone();
    }
  }

  double? dragX;

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    this.x += info.delta.game.x;
    // TODO if ball not launched, launch ball
    return true;
  }
}

class BreakoutGame extends BaseGame with HasDraggableComponents {
  late Platform platform;

  @override
  Future<void> onLoad() async {
    camera.shakeIntensity = 5;
    viewport = FixedResolutionViewport(Vector2(640, 1280));

    add(Bg());
    add(platform = Platform());
  }
}
