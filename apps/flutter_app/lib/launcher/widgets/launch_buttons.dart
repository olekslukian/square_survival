import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/game/game_controller.dart';
import 'package:flutter_app/game/game_screen.dart';
import 'package:flutter_app/launcher/launcher_controller.dart';
import 'package:provider/provider.dart';

void _pushGameScreen(
  BuildContext context,
  GameSessionMode mode, {
  String? serverUrl,
}) {
  unawaited(
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(
          mode: mode,
          serverUrl: serverUrl,
        ),
      ),
    ),
  );
}

class LaunchButtons extends StatelessWidget {
  const LaunchButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LauncherController>(
      builder: (context, controller, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF4CAF50),
              ),
              onPressed: () {
                _pushGameScreen(context, GameSessionMode.singlePlayer);
              },
              icon: const Icon(Icons.person),
              label: const Text(
                'Single Player (Offline)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: controller.canHost
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF37474F),
              ),
              onPressed: controller.canHost
                  ? () {
                      _pushGameScreen(context, GameSessionMode.hostedServer);
                    }
                  : null,
              icon: const Icon(Icons.dns),
              label: Text(
                controller.canHost
                    ? 'Host & Play (Local Server)'
                    : 'Host Server (Unsupported on Web)',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (!controller.canHost)
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  'Web clients cannot bind local sockets. '
                  'Connect to an existing server instead.',
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
