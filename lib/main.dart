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
                Text('Perdeu otario!', style: _whiteText),
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
  static const radius = 20.0;
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

    position += velocity * dt;
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
  static final _paint = BasicPalette.blue.paint();
  double? dragX;

  Platform() {
    anchor = Anchor.topCenter;
    size = Vector2(240, 20);
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

class Crate extends PositionComponent {}

class BreakoutGame extends BaseGame
    with HasDraggableComponents, MultiTouchTapDetector {
  late Platform platform;
  late Ball ball;

  @override
  Future<void> onLoad() async {
    camera.shakeIntensity = 20;
    add(platform = Platform());
    add(ball = Ball());
    ball.reset();
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
    platform.reset();
    ball.reset();
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
