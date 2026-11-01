import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app/game/game_canvas_painter.dart';
import 'package:flutter_app/game/game_controller.dart';
import 'package:flutter_app/game/widgets/close_button.dart'
    as close_button_widget;
import 'package:flutter_app/game/widgets/controls_hint.dart';
import 'package:flutter_app/game/widgets/hud_status_panel.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.mode,
    super.key,
    this.serverUrl,
  });

  final GameSessionMode mode;
  final String? serverUrl;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  late final GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameController(
      mode: widget.mode,
      serverUrl: widget.serverUrl,
    );
    unawaited(_controller.init());

    _ticker = createTicker((elapsed) {
      if (_lastElapsed == Duration.zero) {
        _lastElapsed = elapsed;
        return;
      }
      final elapsedDelta = elapsed - _lastElapsed;
      _lastElapsed = elapsed;

      _controller.tick(elapsedDelta);
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        body: Consumer<GameController>(
          builder: (context, controller, _) {
            return Focus(
              autofocus: true,
              onKeyEvent: (_, e) {
                controller.handleKeyEvent(e);
                return KeyEventResult.handled;
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: GameCanvasPainter(controller),
                    ),
                  ),
                  const SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HudStatusPanel(),
                          close_button_widget.CloseButton(),
                        ],
                      ),
                    ),
                  ),
                  const ControlsHint(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
