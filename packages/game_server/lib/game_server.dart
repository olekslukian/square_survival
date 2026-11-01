import 'dart:convert';
import 'dart:io';
import 'src/game_room.dart';

export 'src/client_session.dart';
export 'src/game_room.dart';

class GameServer {
  final int port;
  final GameRoom room = GameRoom();
  HttpServer? _server;

  GameServer({this.port = 8080});

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    room.start(tickRate: 30);

    print('==================================================');
    print(' 🚀 Dart Game Server listening on http://localhost:$port');
    print(' 🔌 WebSocket Endpoint: ws://localhost:$port/ws');
    print('==================================================');

    _server!.listen((HttpRequest request) async {
      if (request.uri.path == '/health') {
        request.response
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'status': 'online', 'players': room.playerCount}))
          ..close();
      } else if (request.uri.path == '/ws') {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          final socket = await WebSocketTransformer.upgrade(request);
          final clientId = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
          print('[Connect] Player $clientId connected. Total online: ${room.playerCount + 1}');
          room.addSession(clientId, socket);
        } else {
          request.response.statusCode = HttpStatus.badRequest;
          request.response.close();
        }
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.close();
      }
    });
  }

  Future<void> stop() async {
    room.stop();
    await _server?.close(force: true);
    _server = null;
  }
}
