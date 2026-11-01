import 'dart:async';
import 'dart:io';
import 'package:game_core/game_core.dart';
import 'package:game_server/src/client_session.dart';

class GameRoom {
  final World world = World();
  final MovementSystem movementSystem = MovementSystem();
  final Map<String, ClientSession> sessions = {};
  Timer? _tickTimer;

  int get playerCount => sessions.length;

  void start({int tickRate = 30}) {
    final intervalMs = (1000 / tickRate).round();
    final dt = 1.0 / tickRate;

    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      update(dt);
    });
  }

  void stop() {
    _tickTimer?.cancel();
    _tickTimer = null;
    for (final session in sessions.values) {
      session.close();
    }
    sessions.clear();
  }

  void addSession(String id, WebSocket socket) {
    final entity = world.createEntity();
    world
      ..addComponent(entity, TransformComponent(x: 100, y: 100))
      ..addComponent(entity, VelocityComponent());

    final session = ClientSession(id: id, socket: socket, entity: entity);
    sessions[id] = session;

    session.send(WelcomePacket(playerId: id, entityId: entity));

    socket.listen(
      (data) {
        if (data is String) {
          final packet = GamePacket.deserialize(data);
          if (packet != null) {
            handlePacket(id, packet);
          }
        }
      },
      onDone: () => removeSession(id),
      onError: (_) => removeSession(id),
    );
  }

  void removeSession(String id) {
    final session = sessions.remove(id);
    if (session != null) {
      world.destroyEntity(session.entity);
    }
  }

  void handlePacket(String clientId, GamePacket packet) {
    final session = sessions[clientId];
    if (session == null) {
      return;
    }

    if (packet is InputPacket) {
      final vel = world.getComponent<VelocityComponent>(session.entity);
      if (vel != null) {
        vel
          ..vx = packet.vx
          ..vy = packet.vy;
      }
    }
  }

  void update(double dt) {
    movementSystem.update(world, dt);

    final entities = world.query([TransformComponent, VelocityComponent]);
    final snapshots = <EntitySnapshot>[];

    for (final entity in entities) {
      final transform = world.getComponent<TransformComponent>(entity)!;
      final velocity = world.getComponent<VelocityComponent>(entity)!;

      String? ownerId;
      for (final entry in sessions.entries) {
        if (entry.value.entity == entity) {
          ownerId = entry.key;
          break;
        }
      }

      snapshots.add(
        EntitySnapshot(
          entityId: entity,
          ownerId: ownerId,
          x: transform.x,
          y: transform.y,
          vx: velocity.vx,
          vy: velocity.vy,
        ),
      );
    }

    final worldState = WorldStatePacket(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      entities: snapshots,
    );

    broadcast(worldState);
  }

  void broadcast(GamePacket packet) {
    for (final session in sessions.values) {
      session.send(packet);
    }
  }
}
