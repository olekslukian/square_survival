import 'dart:typed_data';

abstract class AssetLoader {
  Future<Uint8List> loadBytes(String path);
  Future<String> loadString(String path);
}
