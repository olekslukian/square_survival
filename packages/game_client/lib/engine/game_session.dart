import 'package:game_client/engine/game_loop.dart';
import 'package:game_client/network/network_client.dart';
import 'package:game_core/game_core.dart';

class GameSession {
  GameSession({
    required bool isSinglePlayer,
    void Function(String status)? onStatusChanged,
  })  : _isSinglePlayer = isSinglePlayer,
        _onStatusChanged = onStatusChanged;

  final bool _isSinglePlayer;
  final void Function(String status)? _onStatusChanged;
  bool _disposed = false;

  World? _world;
  MovementSystem? _movementSystem;
  FixedStepAccumulator? _accumulator;
  NetworkClient? _networkClient;
  Entity? _localPlayerEntity;
  String? _myPlayerId;

  double _inputVx = 0;
  double _inputVy = 0;

  World get world => _world!;
  Entity? get localPlayerEntity => _localPlayerEntity;
  int get entityCount => _world?.query([TransformComponent]).length ?? 0;

  Future<void> startSinglePlayer() async {
    if (_disposed) {
      return;
    }
    _world ??= World();
    _movementSystem ??= MovementSystem();
    _accumulator ??= FixedStepAccumulator();

    _localPlayerEntity = _world!.createEntity();
    _world!
        .addComponent(_localPlayerEntity!, TransformComponent(x: 200, y: 200));
    _world!.addComponent(_localPlayerEntity!, VelocityComponent());
  }

  Future<void> connect(String url) async {
    if (_disposed) {
      return;
    }
    _world ??= World();
    _movementSystem ??= MovementSystem();
    _accumulator ??= FixedStepAccumulator();

    _networkClient = NetworkClient(
      onStatusChanged: (status) {
        if (_disposed) {
          return;
        }
        _onStatusChanged?.call(switch (status) {
          ConnectionStatus.connecting => 'Connecting...',
          ConnectionStatus.connected => 'Connected',
          ConnectionStatus.disconnected => 'Disconnected',
          ConnectionStatus.error => 'Connection Error',
        });
      },
      onPacketReceived: _handleServerPacket,
    );
    await _networkClient!.connect(url);
  }

  void tick(double frameDt) {
    if (_disposed || _accumulator == null) {
      return;
    }
    _accumulator!.advance(frameDt, _update);
  }

  void setInput(double vx, double vy) {
    _inputVx = vx;
    _inputVy = vy;
  }

  TransformComponent? get localTransform {
    if (_localPlayerEntity == null || _world == null) {
      return null;
    }
    return _world!.getComponent<TransformComponent>(_localPlayerEntity!);
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _networkClient?.disconnect();
  }

  void _update(double dt) {
    if (_world == null || _movementSystem == null) {
      return;
    }

    if (_isSinglePlayer) {
      if (_localPlayerEntity != null) {
        final vel =
            _world!.getComponent<VelocityComponent>(_localPlayerEntity!);
        if (vel != null) {
          vel
            ..vx = _inputVx
            ..vy = _inputVy;
        }
      }
      _movementSystem!.update(_world!, dt);
    } else {
      _networkClient?.send(InputPacket(vx: _inputVx, vy: _inputVy));
      _movementSystem!.update(_world!, dt);
    }
  }

  void _handleServerPacket(GamePacket packet) {
    if (_disposed || _world == null) {
      return;
    }

    if (packet is WelcomePacket) {
      _myPlayerId = packet.playerId;
      _localPlayerEntity = packet.entityId;
    } else if (packet is WorldStatePacket) {
      final serverEntityIds = <Entity>{};

      for (final snap in packet.entities) {
        serverEntityIds.add(snap.entityId);

        var transform =
            _world!.getComponent<TransformComponent>(snap.entityId);
        var velocity = _world!.getComponent<VelocityComponent>(snap.entityId);

        if (transform == null) {
          transform = TransformComponent(x: snap.x, y: snap.y);
          _world!.addComponent(snap.entityId, transform);
        } else {
          transform
            ..x = snap.x
            ..y = snap.y;
        }

        if (velocity == null) {
          velocity = VelocityComponent(vx: snap.vx, vy: snap.vy);
          _world!.addComponent(snap.entityId, velocity);
        } else {
          velocity
            ..vx = snap.vx
            ..vy = snap.vy;
        }

        if (snap.ownerId != null && snap.ownerId == _myPlayerId) {
          _localPlayerEntity = snap.entityId;
        }
      }

      final existingEntities = _world!.query([TransformComponent]);
      for (final entity in existingEntities) {
        if (!serverEntityIds.contains(entity)) {
          _world!.destroyEntity(entity);
        }
      }
    }
  }
}
