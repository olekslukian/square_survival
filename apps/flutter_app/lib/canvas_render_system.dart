import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:game_core/game_core.dart';

class CanvasRenderSystem {
  void render({
    required World world,
    required Canvas canvas,
    required Size size,
    Entity? localPlayerEntity,
    ui.Image? spriteAtlas,
  }) {
    final bgPaint = Paint()..color = const Color(0xFF1E1E24);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final gridPaint = Paint()
      ..color = const Color(0xFF2A2A36)
      ..strokeWidth = 1.0;

    const gridSize = 32.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final entities = world.query([TransformComponent]);

    for (final entity in entities) {
      final transform = world.getComponent<TransformComponent>(entity)!;
      final isLocal = entity == localPlayerEntity;

      final paint = Paint()
        ..color = isLocal ? const Color(0xFF4CAF50) : const Color(0xFF03A9F4)
        ..style = PaintingStyle.fill;

      final rect = Rect.fromLTWH(transform.x, transform.y, 24.0, 24.0);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), paint);

      final outlinePaint = Paint()
        ..color = Colors.white70
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), outlinePaint);
    }
  }
}
