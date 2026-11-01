import 'package:flutter/material.dart';
import 'package:flutter_app/launcher/launcher_controller.dart';
import 'package:provider/provider.dart';

class ServerUrlField extends StatelessWidget {
  const ServerUrlField({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LauncherController>(
      builder: (context, controller, _) {
        return TextField(
          controller: controller.serverUrl,
          decoration: InputDecoration(
            labelText: 'Server WebSocket URL',
            hintText: 'ws://localhost:8080/ws',
            filled: true,
            fillColor: const Color(0xFF282836),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.link, size: 20),
          ),
        );
      },
    );
  }
}
