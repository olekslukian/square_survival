import 'dart:io';
import 'package:game_core/game_core.dart';

class ClientSession {
  final String id;
  final WebSocket socket;
  final Entity entity;

  ClientSession({
    required this.id,
    required this.socket,
    required this.entity,
  });

  void send(GamePacket packet) {
    if (socket.readyState == WebSocket.open) {
      socket.add(packet.serialize());
    }
  }

  void close() {
    socket.close();
  }
}
