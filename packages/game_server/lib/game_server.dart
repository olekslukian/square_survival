// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:game_server/src/game_room.dart';

export 'src/client_session.dart';
export 'src/game_room.dart';

class GameServer {
  GameServer({this.port = 8080});
  final int port;
  final GameRoom room = GameRoom();
  HttpServer? _server;

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    room.start();

    print('==================================================');
    print(' 🚀 Dart Game Server listening on http://localhost:$port');
    print(' 🔌 WebSocket Endpoint: ws://localhost:$port/ws');
    print('==================================================');

    _server!.listen((request) async {
      if (request.uri.path == '/health') {
        request.response
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'status': 'online', 'players': room.playerCount}))
          ..close().ignore();
      } else if (request.uri.path == '/ws') {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          final socket = await WebSocketTransformer.upgrade(request);
          final clientId = DateTime.now().millisecondsSinceEpoch
              .toString()
              .substring(7);
          print(
            '[Connect] Player $clientId connected. '
            'Total online: ${room.playerCount + 1}',
          );
          room.addSession(clientId, socket);
        } else {
          request.response.statusCode = HttpStatus.badRequest;
          unawaited(request.response.close());
        }
      } else {
        request.response.statusCode = HttpStatus.notFound;
        unawaited(request.response.close());
      }
    });
  }

  Future<void> stop() async {
    room.stop();
    await _server?.close(force: true);
    _server = null;
  }
}
