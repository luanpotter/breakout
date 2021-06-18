import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/extensions.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart' hide Draggable;

const _whiteText = TextStyle(
  fontSize: 48,
  color: Colors.white,
);

void main() {
  runApp(
    GameWidget<BreakoutGame>(
      game: BreakoutGame(),
      overlayBuilderMap: {
        'gameOver': (_, game) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Perdeu, campeao!', style: _whiteText),
                TextButton(
                  onPressed: game.restart,
                  child: Text('Restart', style: _whiteText),
                ),
              ],
            ),
          );
        },
      },
    ),
  );
}

class Ball extends PositionComponent with HasGameRef<BreakoutGame> {
  static const radius = 10.0;
  static const speed = 500.0;
  static final _paint = BasicPalette.white.paint();

  bool isReset = false;
  Vector2 velocity = Vector2.zero();

  Ball() {
    this.anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset.zero, radius, _paint);
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
        for (final box in boxes) {
          final collision = box.toRect().intersect(effectiveCollisionBounds);
          if (!collision.isEmpty) {
            box.remove();
          }
        }
      }
    }
  }

  void reset() {
    position = gameRef.platform.position - Vector2(0, Ball.radius);
    velocity = Vector2.zero();
    isReset = true;
  }

  void launch() {
    velocity = Vector2(1, -1) * Ball.speed;
    isReset = false;
  }
}

class Platform extends PositionComponent
    with HasGameRef<BreakoutGame>, Draggable {
  static final _paint = BasicPalette.white.paint();
  double? dragX;

  late Vector2 previousPosition = position;
  Vector2 averageVelocity = Vector2.zero();

  Platform() {
    anchor = Anchor.topCenter;
    size = Vector2(100, 10);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _paint);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    reset();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dt != 0) {
      this.averageVelocity = (position - this.previousPosition) / dt;
      this.previousPosition = position.clone();
    }
  }

  void reset() {
    x = gameRef.size.x / 2;
    y = gameRef.size.y - 160;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    if (gameRef.isPaused()) {
      return false;
    }
    this.x += info.delta.game.x;
    if (gameRef.ball.isReset) {
      gameRef.ball.launch();
    }
    return true;
  }
}

class Crate extends PositionComponent {
  static final _paint = BasicPalette.white.paint();
  static final Vector2 crateSize = Vector2(100, 26);

  Crate(Vector2 position) {
    this.position = position;
    size = crateSize;
  }

  @override
  void render(Canvas c) {
    super.render(c);
    c.drawRect(size.toRect(), _paint);
  }
}

class BreakoutGame extends BaseGame
    with HasDraggableComponents, MultiTouchTapDetector {
  late Platform platform;
  late Ball ball;

  @override
  Future<void> onLoad() async {
    camera.shakeIntensity = 20;
    setup();
  }

  void setup() {
    add(platform = Platform());
    add(ball = Ball());
    createCrates();
    ball.reset();
  }

  void createCrates() {
    final grid = Vector2(5, 4);
    final margin = Vector2(10, 10);

    final unitWidth = Crate.crateSize + margin;
    final totalDimensions = grid.clone()..multiply(unitWidth);
    final start = (size - totalDimensions) / 2;

    for (var i = 0; i < grid.x; i++) {
      for (var j = 0; j < grid.y; j++) {
        final p =
            start + (Vector2Extension.fromInts(i, j)..multiply(unitWidth));
        add(Crate(p));
      }
    }
  }

  @override
  void onTapDown(int pointerId, TapDownInfo event) {
    if (isPaused()) {
      return;
    }
    if (ball.isReset) {
      ball.launch();
    }
  }

  void update(double dt) {
    super.update(dt);
  }

  void onLose() async {
    clear();
    setup();
    camera.shake(amount: 2);
    overlays.add('gameOver');
  }

  void restart() {
    overlays.remove('gameOver');
  }

  bool isPaused() {
    return overlays.isActive('gameOver');
  }
}
