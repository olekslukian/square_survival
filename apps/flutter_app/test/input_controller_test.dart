import 'package:flutter/services.dart';
import 'package:flutter_app/game/input_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InputController', () {
    test('W key moves up', () {
      final controller = InputController()
      ..handle(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.keyW,
          physicalKey: PhysicalKeyboardKey.keyW,
          timeStamp: Duration.zero,
        ),
      );

      final dir = controller.direction;
      expect(dir.vx, equals(0));
      expect(dir.vy, equals(-InputController.speed));
    });

    test('S key moves down', () {
      final controller = InputController()
      ..handle(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.keyS,
          physicalKey: PhysicalKeyboardKey.keyS,
          timeStamp: Duration.zero,
        ),
      );

      final dir = controller.direction;
      expect(dir.vx, equals(0));
      expect(dir.vy, equals(InputController.speed));
    });

    test('A key moves left', () {
      final controller = InputController()
      ..handle(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.keyA,
          physicalKey: PhysicalKeyboardKey.keyA,
          timeStamp: Duration.zero,
        ),
      );

      final dir = controller.direction;
      expect(dir.vx, equals(-InputController.speed));
      expect(dir.vy, equals(0));
    });

    test('D key moves right', () {
      final controller = InputController()
      ..handle(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.keyD,
          physicalKey: PhysicalKeyboardKey.keyD,
          timeStamp: Duration.zero,
        ),
      );

      final dir = controller.direction;
      expect(dir.vx, equals(InputController.speed));
      expect(dir.vy, equals(0));
    });

    test('Arrow up moves up', () {
      final controller = InputController()
      ..handle(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.arrowUp,
          physicalKey: PhysicalKeyboardKey.arrowUp,
          timeStamp: Duration.zero,
        ),
      );

      final dir = controller.direction;
      expect(dir.vx, equals(0));
      expect(dir.vy, equals(-InputController.speed));
    });

    test('Arrow down moves down', () {
      final controller = InputController()
      ..handle(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.arrowDown,
          physicalKey: PhysicalKeyboardKey.arrowDown,
          timeStamp: Duration.zero,
        ),
      );

      final dir = controller.direction;
      expect(dir.vx, equals(0));
      expect(dir.vy, equals(InputController.speed));
    });

    test('Arrow left moves left', () {
      final controller = InputController()
      ..handle(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.arrowLeft,
          physicalKey: PhysicalKeyboardKey.arrowLeft,
          timeStamp: Duration.zero,
        ),
      );

      final dir = controller.direction;
      expect(dir.vx, equals(-InputController.speed));
      expect(dir.vy, equals(0));
    });

    test('Arrow right moves right', () {
      final controller = InputController()
      ..handle(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.arrowRight,
          physicalKey: PhysicalKeyboardKey.arrowRight,
          timeStamp: Duration.zero,
        ),
      );

      final dir = controller.direction;
      expect(dir.vx, equals(InputController.speed));
      expect(dir.vy, equals(0));
    });

    test('W + D diagonal movement', () {
      final controller = InputController()
      ..handle(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.keyW,
          physicalKey: PhysicalKeyboardKey.keyW,
          timeStamp: Duration.zero,
        ),
      )
      ..handle(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.keyD,
          physicalKey: PhysicalKeyboardKey.keyD,
          timeStamp: Duration.zero,
        ),
      );

      final dir = controller.direction;
      expect(dir.vx, equals(InputController.speed));
      expect(dir.vy, equals(-InputController.speed));
    });

    test('Key release resets direction', () {
      final controller = InputController()
      ..handle(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.keyW,
          physicalKey: PhysicalKeyboardKey.keyW,
          timeStamp: Duration.zero,
        ),
      );

      var dir = controller.direction;
      expect(dir.vy, equals(-InputController.speed));

      controller.handle(
        const KeyUpEvent(
          logicalKey: LogicalKeyboardKey.keyW,
          physicalKey: PhysicalKeyboardKey.keyW,
          timeStamp: Duration.zero,
        ),
      );

      dir = controller.direction;
      expect(dir.vx, equals(0));
      expect(dir.vy, equals(0));
    });

    test('Multiple key presses and releases', () {
      final controller = InputController()
      ..handle(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.keyW,
          physicalKey: PhysicalKeyboardKey.keyW,
          timeStamp: Duration.zero,
        ),
      )
      ..handle(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.keyA,
          physicalKey: PhysicalKeyboardKey.keyA,
          timeStamp: Duration.zero,
        ),
      );

      var dir = controller.direction;
      expect(dir.vx, equals(-InputController.speed));
      expect(dir.vy, equals(-InputController.speed));

      controller.handle(
        const KeyUpEvent(
          logicalKey: LogicalKeyboardKey.keyW,
          physicalKey: PhysicalKeyboardKey.keyW,
          timeStamp: Duration.zero,
        ),
      );

      dir = controller.direction;
      expect(dir.vx, equals(-InputController.speed));
      expect(dir.vy, equals(0));

      controller.handle(
        const KeyUpEvent(
          logicalKey: LogicalKeyboardKey.keyA,
          physicalKey: PhysicalKeyboardKey.keyA,
          timeStamp: Duration.zero,
        ),
      );

      dir = controller.direction;
      expect(dir.vx, equals(0));
      expect(dir.vy, equals(0));
    });
  });
}
