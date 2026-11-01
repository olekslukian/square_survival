import 'package:flutter/services.dart';
import 'package:game_client/game_client.dart';

class FlutterAssetLoader implements AssetLoader {
  @override
  Future<Uint8List> loadBytes(String path) async {
    final byteData = await rootBundle.load(path);
    return byteData.buffer.asUint8List();
  }

  @override
  Future<String> loadString(String path) async {
    return await rootBundle.loadString(path);
  }
}
