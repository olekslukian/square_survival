import 'package:flutter/material.dart';
import 'package:flutter_app/server/server_manager.dart';

class LauncherController extends ChangeNotifier {
  final TextEditingController serverUrl = TextEditingController(
    text: 'ws://localhost:8080/ws',
  );

  bool get canHost => EmbeddedServerController.isSupported;

  String? validatedUrl() {
    final trimmed = serverUrl.text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  void dispose() {
    serverUrl.dispose();
    super.dispose();
  }
}
