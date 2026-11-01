import 'package:flutter_app/game/game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameController', () {
    test('Single player init sets status text', () async {
      final controller = GameController(mode: GameSessionMode.singlePlayer);
      await controller.init();

      expect(controller.statusText, equals('Single Player Mode'));

      controller.dispose();
    });

    test('tick calls notifyListeners', () async {
      var listenerCalled = false;
      final controller = GameController(mode: GameSessionMode.singlePlayer);
      await controller.init();
      controller..addListener(() {
        listenerCalled = true;
      })

      ..tick(const Duration(milliseconds: 16));

      expect(listenerCalled, isTrue);

      controller.dispose();
    });

    test('isHealthy is true for single player', () async {
      final controller = GameController(mode: GameSessionMode.singlePlayer);
      await controller.init();

      expect(controller.isHealthy, isTrue);

      controller.dispose();
    });

    test('localPlayerEntity is not null after init', () async {
      final controller = GameController(mode: GameSessionMode.singlePlayer);
      await controller.init();

      expect(controller.localPlayerEntity, isNotNull);

      controller.dispose();
    });

    test('dispose is idempotent', () async {
      final controller = GameController(mode: GameSessionMode.singlePlayer);
      await controller.init();

      controller..dispose()
      ..dispose();

      expect(true, isTrue);
    });

    test('entityCount is updated after init', () async {
      final controller = GameController(mode: GameSessionMode.singlePlayer);
      await controller.init();

      expect(controller.entityCount, equals(1));

      controller.dispose();
    });

    test('localTransform is available after init', () async {
      final controller = GameController(mode: GameSessionMode.singlePlayer);
      await controller.init();

      final transform = controller.localTransform;
      expect(transform, isNotNull);
      expect(transform!.x, equals(200));
      expect(transform.y, equals(200));

      controller.dispose();
    });
  });
}
