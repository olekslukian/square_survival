import 'package:game_server/game_server.dart';

class EmbeddedServerController {
  static bool get isSupported => true;

  GameServer? _server;

  bool get isRunning => _server != null;

  Future<void> start({int port = 8080}) async {
    if (_server != null) return;
    _server = GameServer(port: port);
    await _server!.start();
  }

  Future<void> stop() async {
    await _server?.stop();
    _server = null;
  }
}
