import 'package:flutter/material.dart';
import 'package:flutter_app/game/game_controller.dart';
import 'package:provider/provider.dart';

class HudStatusPanel extends StatelessWidget {
  const HudStatusPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, controller, _) {
        final localTransform = controller.localTransform;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.isHealthy
                          ? Colors.greenAccent
                          : Colors.amberAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.statusText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Entities: ${controller.entityCount}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              if (localTransform != null)
                Text(
                  'Pos: (${localTransform.x.toStringAsFixed(1)}, '
                  '${localTransform.y.toStringAsFixed(1)})',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
