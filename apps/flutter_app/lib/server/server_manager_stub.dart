class EmbeddedServerController {
  static bool get isSupported => false;

  bool get isRunning => false;

  Future<void> start({int port = 8080}) async {
    throw UnsupportedError('Embedded server is not supported on Web.');
  }

  Future<void> stop() async {}
}
