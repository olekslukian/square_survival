import 'dart:io';
import 'package:game_core/game_core.dart';

class ClientSession {
  ClientSession({required this.id, required this.socket, required this.entity});
  final String id;
  final WebSocket socket;
  final Entity entity;

  void send(GamePacket packet) {
    if (socket.readyState == WebSocket.open) {
      socket.add(packet.serialize());
    }
  }

  void close() {
    socket.close().ignore();
  }
}
