import 'dart:convert';

sealed class GamePacket {
  String get type;

  Map<String, dynamic> toJson();

  String serialize() => jsonEncode(toJson());

  static GamePacket? deserialize(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final type = map['type'] as String?;
      return switch (type) {
        'welcome' => WelcomePacket.fromMap(map),
        'input' => InputPacket.fromMap(map),
        'world_state' => WorldStatePacket.fromMap(map),
        _ => null,
      };
    } catch (_) {
      return null;
    }
  }
}

class WelcomePacket extends GamePacket {
  @override
  String get type => 'welcome';

  final String playerId;
  final int entityId;

  WelcomePacket({required this.playerId, required this.entityId});

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'playerId': playerId,
        'entityId': entityId,
      };

  factory WelcomePacket.fromMap(Map<String, dynamic> map) => WelcomePacket(
        playerId: map['playerId'] as String,
        entityId: (map['entityId'] as num).toInt(),
      );
}

class InputPacket extends GamePacket {
  @override
  String get type => 'input';

  final double vx;
  final double vy;

  InputPacket({required this.vx, required this.vy});

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'vx': vx,
        'vy': vy,
      };

  factory InputPacket.fromMap(Map<String, dynamic> map) => InputPacket(
        vx: (map['vx'] as num).toDouble(),
        vy: (map['vy'] as num).toDouble(),
      );
}

class EntitySnapshot {
  final int entityId;
  final String? ownerId;
  final double x;
  final double y;
  final double vx;
  final double vy;

  EntitySnapshot({
    required this.entityId,
    this.ownerId,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
  });

  Map<String, dynamic> toJson() => {
        'entityId': entityId,
        if (ownerId != null) 'ownerId': ownerId,
        'x': x,
        'y': y,
        'vx': vx,
        'vy': vy,
      };

  factory EntitySnapshot.fromMap(Map<String, dynamic> map) => EntitySnapshot(
        entityId: (map['entityId'] as num).toInt(),
        ownerId: map['ownerId'] as String?,
        x: (map['x'] as num).toDouble(),
        y: (map['y'] as num).toDouble(),
        vx: (map['vx'] as num).toDouble(),
        vy: (map['vy'] as num).toDouble(),
      );
}

class WorldStatePacket extends GamePacket {
  @override
  String get type => 'world_state';

  final int timestamp;
  final List<EntitySnapshot> entities;

  WorldStatePacket({required this.timestamp, required this.entities});

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'timestamp': timestamp,
        'entities': entities.map((e) => e.toJson()).toList(),
      };

  factory WorldStatePacket.fromMap(Map<String, dynamic> map) =>
      WorldStatePacket(
        timestamp: (map['timestamp'] as num).toInt(),
        entities: (map['entities'] as List<dynamic>)
            .map((e) => EntitySnapshot.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
}
