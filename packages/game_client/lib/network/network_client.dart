import 'dart:async';
import 'package:game_core/game_core.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum ConnectionStatus { disconnected, connecting, connected, error }

class NetworkClient {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  ConnectionStatus _status = ConnectionStatus.disconnected;

  final void Function(ConnectionStatus status)? onStatusChanged;
  final void Function(GamePacket packet)? onPacketReceived;

  NetworkClient({
    this.onStatusChanged,
    this.onPacketReceived,
  });

  ConnectionStatus get status => _status;

  Future<void> connect(String url) async {
    _setStatus(ConnectionStatus.connecting);

    try {
      final uri = Uri.parse(url);
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;
      _setStatus(ConnectionStatus.connected);

      _subscription = _channel!.stream.listen(
        (data) {
          if (data is String) {
            final packet = GamePacket.deserialize(data);
            if (packet != null) {
              onPacketReceived?.call(packet);
            }
          }
        },
        onError: (_) {
          _setStatus(ConnectionStatus.error);
          disconnect();
        },
        onDone: () {
          _setStatus(ConnectionStatus.disconnected);
          disconnect();
        },
      );
    } catch (_) {
      _setStatus(ConnectionStatus.error);
      disconnect();
    }
  }

  void send(GamePacket packet) {
    if (_status == ConnectionStatus.connected && _channel != null) {
      _channel!.sink.add(packet.serialize());
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    if (_status != ConnectionStatus.disconnected) {
      _setStatus(ConnectionStatus.disconnected);
    }
  }

  void _setStatus(ConnectionStatus newStatus) {
    _status = newStatus;
    onStatusChanged?.call(_status);
  }
}
