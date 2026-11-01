import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/game/game_controller.dart';
import 'package:flutter_app/game/game_screen.dart';
import 'package:flutter_app/launcher/launcher_controller.dart';
import 'package:flutter_app/launcher/widgets/launch_buttons.dart';
import 'package:flutter_app/launcher/widgets/launcher_header.dart';
import 'package:flutter_app/launcher/widgets/server_url_field.dart';
import 'package:provider/provider.dart';

class GameLauncherScreen extends StatelessWidget {
  const GameLauncherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LauncherController(),
      child: Consumer<LauncherController>(
        builder: (context, controller, _) {
          return Scaffold(
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Card(
                    color: const Color(0xFF1E1E28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFF333344)),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const LauncherHeader(),
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              'Pure Dart Engine & Multi-Platform Client',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const LaunchButtons(),
                          const SizedBox(height: 24),
                          const Divider(color: Color(0xFF333344)),
                          const SizedBox(height: 16),
                          const ServerUrlField(),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                color: Color(0xFF03A9F4),
                              ),
                            ),
                            onPressed: () {
                              final url = controller.validatedUrl();
                              if (url != null) {
                                unawaited(
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => GameScreen(
                                        mode:
                                            GameSessionMode.clientMultiplayer,
                                        serverUrl: url,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.wifi,
                              color: Color(0xFF03A9F4),
                            ),
                            label: const Text(
                              'Connect to Server',
                              style: TextStyle(
                                color: Color(0xFF03A9F4),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
