import 'dart:io';
import 'package:game_server/game_server.dart';

void main(List<String> args) async {
  final envPort = Platform.environment['PORT'] != null
      ? int.tryParse(Platform.environment['PORT']!)
      : null;
  final argPort = args.isNotEmpty ? int.tryParse(args[0]) : null;
  final port = argPort ?? envPort ?? 8080;
  final server = GameServer(port: port);
  await server.start();
}
