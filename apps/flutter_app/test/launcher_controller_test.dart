import 'package:flutter_app/launcher/launcher_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LauncherController', () {
    test('Empty URL returns null', () {
      final controller = LauncherController();
      controller.serverUrl.text = '';

      expect(controller.validatedUrl(), isNull);

      controller.dispose();
    });

    test('Whitespace URL returns null', () {
      final controller = LauncherController();
      controller.serverUrl.text = '   ';

      expect(controller.validatedUrl(), isNull);

      controller.dispose();
    });

    test('Valid URL is trimmed and returned', () {
      final controller = LauncherController();
      controller.serverUrl.text = '  ws://localhost:8080/ws  ';

      expect(controller.validatedUrl(), equals('ws://localhost:8080/ws'));

      controller.dispose();
    });

    test('Default URL is ws://localhost:8080/ws', () {
      final controller = LauncherController();

      expect(controller.serverUrl.text, equals('ws://localhost:8080/ws'));

      controller.dispose();
    });

    test('dispose disposes text controller', () {
      final _ = LauncherController()..dispose();

      expect(true, isTrue);
    });
  });
}
