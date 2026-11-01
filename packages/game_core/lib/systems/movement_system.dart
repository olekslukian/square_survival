import 'package:game_core/components/transform_component.dart';
import 'package:game_core/components/velocity_component.dart';
import 'package:game_core/ecs/world.dart';

class MovementSystem {
  void update(World world, double dt) {
    final entities = world.query([TransformComponent, VelocityComponent]);

    for (final entity in entities) {
      final transform = world.getComponent<TransformComponent>(entity)!;
      final velocity = world.getComponent<VelocityComponent>(entity)!;

      transform
        ..x += velocity.vx * dt
        ..y += velocity.vy * dt;
    }
  }
}
