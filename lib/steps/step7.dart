import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/extensions.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart' hide Draggable;

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
    if (gameRef.ball.isReset) {
      gameRef.ball.launch();
    }
    return true;
  }
}

class Ball extends PositionComponent with HasGameRef<BreakoutGame> {
  static const radius = 10.0;
  static const speed = 500.0;

  late bool isReset;
  late Vector2 velocity;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    position = gameRef.platform.position - Vector2(0, Ball.radius);
    velocity = Vector2.zero();
    isReset = true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset.zero, radius, _paintWhite);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final ds = velocity * dt;
    position += ds;

    if (position.x < 0) {
      position.x = 0;
      velocity.multiply(Vector2(-1, 1));
      gameRef.camera.shake(amount: 0.15);
    } else if (position.x > gameRef.size.x) {
      position.x = gameRef.size.x;
      velocity.multiply(Vector2(-1, 1));
      gameRef.camera.shake(amount: 0.15);
    } else if (position.y < 0) {
      position.y = 0;
      velocity.multiply(Vector2(1, -1));
      gameRef.camera.shake(amount: 0.15);
    } else if (position.y > gameRef.size.y) {
      gameRef.onLose();
    } else {
      final previousRect = (position - ds) & size;
      final effectiveCollisionBounds = toRect().expandToInclude(previousRect);
      final intersects =
          gameRef.platform.toRect().intersect(effectiveCollisionBounds);
      if (!intersects.isEmpty) {
        position.y = gameRef.platform.position.y - Ball.radius;
        velocity.multiply(Vector2(1, -1));
        velocity += gameRef.platform.averageVelocity / 10;
      } else {
        final boxes = gameRef.components.whereType<Crate>();
        var firstBox = true;
        for (final box in boxes) {
          final collision = box.toRect().intersect(effectiveCollisionBounds);
          if (!collision.isEmpty) {
            if (firstBox) {
              velocity.multiply(Vector2(1, -1));
              firstBox = false;
            }
            box.remove();
          }
        }
      }
    }
  }

  void launch() {
    velocity = Vector2(0.75, -1) * Ball.speed;
    isReset = false;
  }
}

class Crate extends PositionComponent {
  static final _paintRow1 = Paint()..color = Color(0xFFE22349);
  static final _paintRow2 = Paint()..color = Color(0xFFFF2600);
  static final _paintRow3 = Paint()..color = Color(0xFFFF5300);
  static final _paintrow4 = Paint()..color = Color(0xFFFFC100);
  static final _paints = [_paintRow1, _paintRow2, _paintRow3, _paintrow4];
  static final Vector2 crateSize = Vector2(100, 26);

  final int row;

  Crate(Vector2 position, this.row) {
    this.position = position;
    size = crateSize;
  }

  @override
  void render(Canvas c) {
    super.render(c);
    c.drawRect(size.toRect(), _paints[row ~/ 2]);
  }
}

class BreakoutGame extends BaseGame with HasDraggableComponents {
  late Platform platform;
  late Ball ball;

  @override
  Future<void> onLoad() async {
    camera.shakeIntensity = 5;
    viewport = FixedResolutionViewport(Vector2(640, 1280));
    setup();
  }

  void setup() {
    add(Bg());
    add(platform = Platform());
    add(ball = Ball());

    createCrates();
  }

  void createCrates() {
    final grid = Vector2(5, 8);
    final margin = Vector2(5, 5);

    final unitWidth = Crate.crateSize + margin;
    final totalDimensions = grid.clone()..multiply(unitWidth);
    final start = ((size - totalDimensions) / 2)..y = 100.0;

    for (var i = 0; i < grid.x; i++) {
      for (var j = 0; j < grid.y; j++) {
        final p =
            start + (Vector2Extension.fromInts(i, j)..multiply(unitWidth));
        add(Crate(p, j));
      }
    }
  }

  void onLose() {
    //
  }
}
