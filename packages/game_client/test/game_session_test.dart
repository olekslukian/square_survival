import 'package:game_client/game_client.dart';
import 'package:game_core/game_core.dart';
import 'package:test/test.dart';

void main() {
  group('GameSession', () {
    test('startSinglePlayer creates local entity with correct components',
        () async {
      final session = GameSession(isSinglePlayer: true);
      await session.startSinglePlayer();

      expect(session.localPlayerEntity, isNotNull);
      expect(session.entityCount, equals(1));

      final transform = session.world
          .getComponent<TransformComponent>(session.localPlayerEntity!)!;
      expect(transform.x, equals(200));
      expect(transform.y, equals(200));

      final velocity = session.world
          .getComponent<VelocityComponent>(session.localPlayerEntity!)!;
      expect(velocity, isNotNull);

      session.dispose();
    });

    test('setInput updates input state', () async {
      final session = GameSession(isSinglePlayer: true);
      await session.startSinglePlayer();

      session
        ..setInput(100, 50)
        ..tick(1.0 / 60.0);

      final velocity = session.world
          .getComponent<VelocityComponent>(session.localPlayerEntity!)!;
      expect(velocity.vx, equals(100));
      expect(velocity.vy, equals(50));

      session.dispose();
    });

    test('tick with fixed dt is deterministic', () async {
      final session1 = GameSession(isSinglePlayer: true);
      await session1.startSinglePlayer();
      session1.setInput(100, 50);

      final session2 = GameSession(isSinglePlayer: true);
      await session2.startSinglePlayer();
      session2.setInput(100, 50);

      for (var i = 0; i < 10; i++) {
        session1.tick(1.0 / 60.0);
        session2.tick(1.0 / 60.0);
      }

      final t1 = session1.world
          .getComponent<TransformComponent>(session1.localPlayerEntity!)!;
      final t2 = session2.world
          .getComponent<TransformComponent>(session2.localPlayerEntity!)!;

      expect(t1.x, equals(t2.x));
      expect(t1.y, equals(t2.y));

      session1.dispose();
      session2.dispose();
    });

    test('dispose prevents status callbacks', () async {
      String? lastStatus;
      GameSession(
        isSinglePlayer: false,
        onStatusChanged: (status) {
          lastStatus = status;
        },
      ).dispose();

      expect(lastStatus, isNull);
    });

    test('localTransform returns null when local entity is null', () async {
      final session = GameSession(isSinglePlayer: true);
      expect(session.localTransform, isNull);
      session.dispose();
    });

    test('localTransform returns transform after spawn', () async {
      final session = GameSession(isSinglePlayer: true);
      await session.startSinglePlayer();

      expect(session.localTransform, isNotNull);
      expect(session.localTransform!.x, equals(200));
      expect(session.localTransform!.y, equals(200));

      session.dispose();
    });

    test('entityCount returns correct count', () async {
      final session = GameSession(isSinglePlayer: true);
      expect(session.entityCount, equals(0));

      await session.startSinglePlayer();
      expect(session.entityCount, equals(1));

      session.dispose();
    });

    test('dispose is idempotent', () async {
      final session = GameSession(isSinglePlayer: true);
      await session.startSinglePlayer();

      session
        ..dispose()
        ..dispose();

      expect(true, true);
    });
  });
}
