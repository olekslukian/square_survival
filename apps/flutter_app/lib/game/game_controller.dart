import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/canvas_render_system.dart';
import 'package:flutter_app/game/input_controller.dart';
import 'package:flutter_app/server/server_manager.dart';
import 'package:game_client/game_client.dart';
import 'package:game_core/game_core.dart';

enum GameSessionMode { singlePlayer, hostedServer, clientMultiplayer }

class GameController extends ChangeNotifier {
  GameController({
    required this.mode,
    this.serverUrl,
  });

  final GameSessionMode mode;
  final String? serverUrl;

  late final GameSession _session;
  late final InputController _input;
  late CanvasRenderSystem _renderSystem;
  EmbeddedServerController? _embeddedServer;

  String _statusText = 'Initializing';
  bool _disposed = false;

  String get statusText => _statusText;

  bool get isHealthy {
    return _statusText == 'Connected' ||
        mode == GameSessionMode.singlePlayer;
  }

  World get world => _session.world;
  Entity? get localPlayerEntity => _session.localPlayerEntity;
  CanvasRenderSystem get renderSystem => _renderSystem;
  int get entityCount => _session.entityCount;
  TransformComponent? get localTransform => _session.localTransform;

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _session.dispose();
    unawaited(_embeddedServer?.stop());
    super.dispose();
  }

  Future<void> init() async {
    _session = GameSession(
      isSinglePlayer: mode == GameSessionMode.singlePlayer,
      onStatusChanged: (status) {
        if (_disposed) {
          return;
        }
        _statusText = status;
        notifyListeners();
      },
    );
    _input = InputController();
    _renderSystem = CanvasRenderSystem();

    switch (mode) {
      case GameSessionMode.singlePlayer:
        await _session.startSinglePlayer();
        _statusText = 'Single Player Mode';
        notifyListeners();

      case GameSessionMode.hostedServer:
        _embeddedServer = EmbeddedServerController();
        await _embeddedServer!.start();
        _statusText = 'Hosting on :8080. Connecting...';
        notifyListeners();
        await _session.connect('ws://localhost:8080/ws');

      case GameSessionMode.clientMultiplayer:
        _statusText = 'Connecting to $serverUrl...';
        notifyListeners();
        await _session.connect(serverUrl ?? 'ws://localhost:8080/ws');
    }
  }

  void tick(Duration elapsed) {
    if (_disposed) {
      return;
    }
    final frameDt = elapsed.inMicroseconds / 1000000.0;
    _session.tick(frameDt);
    notifyListeners();
  }

  void handleKeyEvent(KeyEvent e) {
    _input.handle(e);
    final dir = _input.direction;
    _session.setInput(dir.vx, dir.vy);
  }
}
