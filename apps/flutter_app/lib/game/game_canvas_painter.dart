import 'package:flutter/material.dart';
import 'package:flutter_app/game/game_controller.dart';

class GameCanvasPainter extends CustomPainter {
  GameCanvasPainter(this.controller) : super(repaint: controller);

  final GameController controller;

  @override
  void paint(Canvas canvas, Size size) {
    controller.renderSystem.render(
      world: controller.world,
      canvas: canvas,
      size: size,
      localPlayerEntity: controller.localPlayerEntity,
    );
  }

  @override
  bool shouldRepaint(GameCanvasPainter oldDelegate) {
    return false;
  }
}
