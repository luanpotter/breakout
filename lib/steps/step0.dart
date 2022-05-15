import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Draggable;

void main() {
  runApp(
    GameWidget<BreakoutGame>(
      game: BreakoutGame(),
    ),
  );
}

class BreakoutGame extends FlameGame with HasDraggables {
  @override
  Future<void> onLoad() async {
    super.onLoad();
  }
}
