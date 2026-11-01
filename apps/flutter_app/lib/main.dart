import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/canvas_render_system.dart';
import 'package:flutter_app/server/server_manager.dart';
import 'package:game_client/game_client.dart';
import 'package:game_core/game_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SquareSurvivalApp());
}

class SquareSurvivalApp extends StatelessWidget {
  const SquareSurvivalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Square Survival',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF141419),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4CAF50),
          secondary: Color(0xFF03A9F4),
        ),
      ),
      home: const GameLauncherScreen(),
    );
  }
}

class GameLauncherScreen extends StatefulWidget {
  const GameLauncherScreen({super.key});

  @override
  State<GameLauncherScreen> createState() => _GameLauncherScreenState();
}

class _GameLauncherScreenState extends State<GameLauncherScreen> {
  final TextEditingController _serverUrlController = TextEditingController(
    text: 'ws://localhost:8080/ws',
  );

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  void _launchSinglePlayer() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const GameScreen(mode: GameSessionMode.singlePlayer),
        ),
      ),
    );
  }

  void _launchHostMultiplayer() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const GameScreen(mode: GameSessionMode.hostedServer),
        ),
      ),
    );
  }

  void _launchJoinMultiplayer() {
    final url = _serverUrlController.text.trim();
    if (url.isEmpty) {
      return;
    }
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GameScreen(
            mode: GameSessionMode.clientMultiplayer,
            serverUrl: url,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canHost = EmbeddedServerController.isSupported;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              color: const Color(0xFF1E1E28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF333344)),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Square Survival',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Pure Dart Engine & Multi-Platform Client',
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                      onPressed: _launchSinglePlayer,
                      icon: const Icon(Icons.person),
                      label: const Text(
                        'Single Player (Offline)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: canHost
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF37474F),
                      ),
                      onPressed: canHost ? _launchHostMultiplayer : null,
                      icon: const Icon(Icons.dns),
                      label: Text(
                        canHost
                            ? 'Host & Play (Local Server)'
                            : 'Host Server (Unsupported on Web)',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!canHost)
                      const Padding(
                        padding: EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          'Web clients cannot bind local sockets. '
                          'Connect to an existing server instead.',
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFF333344)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _serverUrlController,
                      decoration: InputDecoration(
                        labelText: 'Server WebSocket URL',
                        hintText: 'ws://localhost:8080/ws',
                        filled: true,
                        fillColor: const Color(0xFF282836),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.link, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF03A9F4)),
                      ),
                      onPressed: _launchJoinMultiplayer,
                      icon: const Icon(Icons.wifi, color: Color(0xFF03A9F4)),
                      label: const Text(
                        'Connect to Server',
                        style: TextStyle(
                          color: Color(0xFF03A9F4),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum GameSessionMode { singlePlayer, hostedServer, clientMultiplayer }

class GameScreen extends StatefulWidget {
  const GameScreen({required this.mode, super.key, this.serverUrl});

  final GameSessionMode mode;
  final String? serverUrl;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  final World _world = World();
  final MovementSystem _movementSystem = MovementSystem();
  final FixedStepAccumulator _accumulator = FixedStepAccumulator();
  final CanvasRenderSystem _renderSystem = CanvasRenderSystem();

  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  Entity? _localPlayerEntity;
  String? _myPlayerId;

  EmbeddedServerController? _embeddedServer;
  NetworkClient? _networkClient;

  double _inputVx = 0;
  double _inputVy = 0;
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  String _statusText = 'Initializing';

  @override
  void initState() {
    super.initState();
    unawaited(_initSession());

    _ticker = createTicker((elapsed) {
      if (_lastElapsed == Duration.zero) {
        _lastElapsed = elapsed;
        return;
      }
      final frameDt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
      _lastElapsed = elapsed;

      _accumulator.advance(frameDt, _update);

      setState(() {});
    });
    _ticker.start();
  }

  Future<void> _initSession() async {
    switch (widget.mode) {
      case GameSessionMode.singlePlayer:
        _localPlayerEntity = _world.createEntity();
        _world.addComponent(
          _localPlayerEntity!,
          TransformComponent(x: 200, y: 200),
        );
        _world.addComponent(_localPlayerEntity!, VelocityComponent());
        setState(() {
          _statusText = 'Single Player Mode';
        });

      case GameSessionMode.hostedServer:
        _embeddedServer = EmbeddedServerController();
        await _embeddedServer!.start();
        setState(() {
          _statusText = 'Hosting on :8080. Connecting...';
        });
        _connectNetwork('ws://localhost:8080/ws');

      case GameSessionMode.clientMultiplayer:
        setState(() {
          _statusText = 'Connecting to ${widget.serverUrl}...';
        });
        _connectNetwork(widget.serverUrl ?? 'ws://localhost:8080/ws');
    }
  }

  void _connectNetwork(String url) {
    _networkClient = NetworkClient(
      onStatusChanged: (status) {
        if (!mounted) {
          return;
        }
        setState(() {
          _statusText = switch (status) {
            ConnectionStatus.connecting => 'Connecting...',
            ConnectionStatus.connected => 'Connected',
            ConnectionStatus.disconnected => 'Disconnected',
            ConnectionStatus.error => 'Connection Error',
          };
        });
      },
      onPacketReceived: _handleServerPacket,
    );
    unawaited(_networkClient!.connect(url));
  }

  void _handleServerPacket(GamePacket packet) {
    if (packet is WelcomePacket) {
      _myPlayerId = packet.playerId;
      _localPlayerEntity = packet.entityId;
    } else if (packet is WorldStatePacket) {
      final serverEntityIds = <Entity>{};

      for (final snap in packet.entities) {
        serverEntityIds.add(snap.entityId);

        var transform = _world.getComponent<TransformComponent>(snap.entityId);
        var velocity = _world.getComponent<VelocityComponent>(snap.entityId);

        if (transform == null) {
          transform = TransformComponent(x: snap.x, y: snap.y);
          _world.addComponent(snap.entityId, transform);
        } else {
          transform
            ..x = snap.x
            ..y = snap.y;
        }

        if (velocity == null) {
          velocity = VelocityComponent(vx: snap.vx, vy: snap.vy);
          _world.addComponent(snap.entityId, velocity);
        } else {
          velocity
            ..vx = snap.vx
            ..vy = snap.vy;
        }

        if (snap.ownerId != null && snap.ownerId == _myPlayerId) {
          _localPlayerEntity = snap.entityId;
        }
      }

      final existingEntities = _world.query([TransformComponent]);
      for (final entity in existingEntities) {
        if (!serverEntityIds.contains(entity)) {
          _world.destroyEntity(entity);
        }
      }
    }
  }

  void _update(double dt) {
    if (widget.mode == GameSessionMode.singlePlayer) {
      if (_localPlayerEntity != null) {
        final vel = _world.getComponent<VelocityComponent>(_localPlayerEntity!);
        if (vel != null) {
          vel
            ..vx = _inputVx
            ..vy = _inputVy;
        }
      }
      _movementSystem.update(_world, dt);
    } else {
      _networkClient?.send(InputPacket(vx: _inputVx, vy: _inputVy));
      _movementSystem.update(_world, dt);
    }
  }

  void _updateInputDirection() {
    const speed = 180.0;
    double vx = 0;
    double vy = 0;

    if (_pressedKeys.contains(LogicalKeyboardKey.keyW) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      vy -= speed;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      vy += speed;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      vx -= speed;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      vx += speed;
    }

    _inputVx = vx;
    _inputVy = vy;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _networkClient?.disconnect();
    unawaited(_embeddedServer?.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localTransform = _localPlayerEntity != null
        ? _world.getComponent<TransformComponent>(_localPlayerEntity!)
        : null;

    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            _pressedKeys.add(event.logicalKey);
          } else if (event is KeyUpEvent) {
            _pressedKeys.remove(event.logicalKey);
          }
          _updateInputDirection();
          return KeyEventResult.handled;
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _GameCanvasPainter(
                  world: _world,
                  renderSystem: _renderSystem,
                  localPlayerEntity: _localPlayerEntity,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
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
                                  color:
                                      _statusText == 'Connected' ||
                                          widget.mode ==
                                              GameSessionMode.singlePlayer
                                      ? Colors.greenAccent
                                      : Colors.amberAccent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _statusText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Entities: '
                            '${_world.query([TransformComponent]).length}',
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
                    ),
                    IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 24,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Controls: [W, A, S, D] or Arrow Keys to move',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCanvasPainter extends CustomPainter {
  _GameCanvasPainter({
    required this.world,
    required this.renderSystem,
    this.localPlayerEntity,
  });

  final World world;
  final CanvasRenderSystem renderSystem;
  final Entity? localPlayerEntity;

  @override
  void paint(Canvas canvas, Size size) {
    renderSystem.render(
      world: world,
      canvas: canvas,
      size: size,
      localPlayerEntity: localPlayerEntity,
    );
  }

  @override
  bool shouldRepaint(covariant _GameCanvasPainter oldDelegate) => true;
}
