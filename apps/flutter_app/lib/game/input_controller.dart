import 'package:flutter/services.dart';

class InputController {
  static const double speed = 180;

  final Set<LogicalKeyboardKey> _pressed = {};

  bool handle(KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressed.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _pressed.remove(event.logicalKey);
    }
    return true;
  }

  ({double vx, double vy}) get direction {
    double vx = 0;
    double vy = 0;

    if (_pressed.contains(LogicalKeyboardKey.keyW) ||
        _pressed.contains(LogicalKeyboardKey.arrowUp)) {
      vy -= speed;
    }
    if (_pressed.contains(LogicalKeyboardKey.keyS) ||
        _pressed.contains(LogicalKeyboardKey.arrowDown)) {
      vy += speed;
    }
    if (_pressed.contains(LogicalKeyboardKey.keyA) ||
        _pressed.contains(LogicalKeyboardKey.arrowLeft)) {
      vx -= speed;
    }
    if (_pressed.contains(LogicalKeyboardKey.keyD) ||
        _pressed.contains(LogicalKeyboardKey.arrowRight)) {
      vx += speed;
    }

    return (vx: vx, vy: vy);
  }
}
