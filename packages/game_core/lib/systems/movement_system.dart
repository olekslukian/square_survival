import '../components/transform_component.dart';
import '../components/velocity_component.dart';
import '../ecs/world.dart';

class MovementSystem {
  void update(World world, double dt) {
    final entities = world.query([TransformComponent, VelocityComponent]);

    for (final entity in entities) {
      final transform = world.getComponent<TransformComponent>(entity)!;
      final velocity = world.getComponent<VelocityComponent>(entity)!;

      transform.x += velocity.vx * dt;
      transform.y += velocity.vy * dt;
    }
  }
}
