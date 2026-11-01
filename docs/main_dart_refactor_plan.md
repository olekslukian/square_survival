# Plan: Decompose `main.dart` and Move to ChangeNotifier State

## Decisions

| Topic | Decision |
|-------|----------|
| Game logic placement | Pure-Dart `GameSession` in `packages/game_client`, plus a thin `GameController extends ChangeNotifier` in `apps/flutter_app` |
| Launcher state | `LauncherController extends ChangeNotifier` |
| Dependency injection | `provider` package |
| Per-frame updates | `CustomPaint` painter uses `repaint: controller`; no widget rebuild per frame |
| `GameSessionMode` enum | Lives in `game_controller.dart` |
| Tests | Unit tests for `GameSession`, `InputController`, `GameController` and `LauncherController`, plus a widget smoke test |

## Constraints (from AGENTS.md)

- `game_client` stays pure Dart: no `package:flutter`, no `dart:ui`, and no `dart:io`.
- `EmbeddedServerController` uses `dart:io`, so it stays in the app behind the existing conditional import in `lib/server/server_manager.dart`. `GameSession` must not know about it.
- No code comments or docstrings.
- `dart analyze` and `flutter analyze` must report zero errors and zero warnings in every package.

## Target Structure

```text
packages/game_client/lib/
├── game_client.dart                  # add export of engine/game_session.dart
└── engine/
    └── game_session.dart             # NEW, pure Dart

apps/flutter_app/lib/
├── main.dart                         # runApp only
├── app.dart                          # SquareSurvivalApp + theme
├── canvas_render_system.dart         # unchanged
├── flutter_asset_loader.dart         # unchanged
├── server/                           # unchanged
├── launcher/
│   ├── launcher_controller.dart
│   ├── game_launcher_screen.dart
│   └── widgets/
│       ├── launcher_header.dart
│       ├── launch_buttons.dart
│       └── server_url_field.dart
└── game/
    ├── game_controller.dart          # GameSessionMode enum + GameController
    ├── game_screen.dart
    ├── input_controller.dart
    ├── game_canvas_painter.dart
    └── widgets/
        ├── hud_status_panel.dart
        ├── controls_hint.dart
        └── close_button.dart
```

## Step 1: Add `provider`

1. From `apps/flutter_app`, run `flutter pub add provider`.

## Step 2: Extract app shell (mechanical)

1. Move `SquareSurvivalApp` into `lib/app.dart` and remove the `TODO(olekslukian)`.
2. Reduce `main.dart` to `WidgetsFlutterBinding.ensureInitialized(); runApp(const SquareSurvivalApp());`.
3. Run `flutter analyze`.

## Step 3: Create `GameSession` (pure Dart, `game_client`)

Create `engine/game_session.dart` and export it from `game_client.dart`.

**Owns:**
- `World`
- `MovementSystem`
- `FixedStepAccumulator`
- `NetworkClient?`
- `Entity? localPlayerEntity`
- `String? myPlayerId`
- Input velocity (`inputVx`, `inputVy`)

**Constructor:** takes `isSinglePlayer` and an optional `void Function(String status)? onStatusChanged`.

**API:**

| Member | Source in current `main.dart` |
|--------|------------------------------|
| `void startSinglePlayer()` | Creates the local entity with `TransformComponent(x: 200, y: 200)` and `VelocityComponent()` |
| `void connect(String url)` | `_connectNetwork`, with the `ConnectionStatus` to text switch |
| `void tick(double frameDt)` | `_accumulator.advance(frameDt, _update)` |
| `void setInput(double vx, double vy)` | Replaces `_inputVx` and `_inputVy` |
| `TransformComponent? get localTransform` | Currently computed in `build` |
| `int get entityCount` | `_world.query([TransformComponent]).length` |
| `void dispose()` | `_networkClient?.disconnect()` |

**Internals:**
- `_update(dt)` keeps the current logic. Single-player applies input to the local velocity before `MovementSystem`. Multiplayer sends `InputPacket` and then runs `MovementSystem`.
- `_handleServerPacket` moves over unchanged (Welcome and WorldState reconciliation).
- Add a `_disposed` flag. Status callbacks that arrive after `dispose()` are ignored. This replaces the `mounted` check.

## Step 4: Create `InputController`

`game/input_controller.dart`. It is Flutter-only because it uses `LogicalKeyboardKey`, but it has no `ChangeNotifier`.

- `static const speed = 180.0`
- `Set<LogicalKeyboardKey> _pressed`
- `bool handle(KeyEvent event)` updates the set on `KeyDownEvent` and `KeyUpEvent`.
- `({double vx, double vy}) get direction` contains the W/S/A/D and arrow-key logic from `_updateInputDirection`.

## Step 5: Create `GameController` (`game/game_controller.dart`)

Contains `enum GameSessionMode { singlePlayer, hostedServer, clientMultiplayer }` and `GameController extends ChangeNotifier`.

- **Constructor:** `GameController({required this.mode, this.serverUrl})`. It builds `GameSession` and `InputController`, and owns the `EmbeddedServerController?`.
- **State exposed to the UI:**
  - `statusText`
  - `isHealthy` (connected or single-player, drives the HUD dot colour)
  - `world`, `localPlayerEntity` and `renderSystem` for the painter
  - `entityCount` and `localTransform` for the HUD
- **Lifecycle:**
  - `Future<void> init()` is the old `_initSession` switch. For hosted mode it starts the embedded server, sets the status, then calls `session.connect('ws://localhost:8080/ws')`.
  - `void tick(Duration elapsed)` computes `frameDt` from the last elapsed value and calls `session.tick(frameDt)`. It then calls `notifyListeners()` so the painter repaints.
  - `KeyEventResult onKeyEvent(KeyEvent e)` calls `input.handle(e)` and then `session.setInput(...)`.
  - `dispose()` calls `session.dispose()`, `unawaited(_embeddedServer?.stop())`, then `super.dispose()`.
- `GameSession.onStatusChanged` updates `statusText` and calls `notifyListeners()`.
- Make `dispose()` idempotent and guard `notifyListeners()` with a `_disposed` flag.

## Step 6: Painter and `GameScreen`

1. `game/game_canvas_painter.dart`: public `GameCanvasPainter(GameController controller) : super(repaint: controller)`. It reads `controller.world` and `controller.localPlayerEntity` inside `paint`, and `shouldRepaint` returns `false` because repaint is driven by the listenable.
2. `game/game_screen.dart`:
   - `StatefulWidget` + `SingleTickerProviderStateMixin`. It owns only the `Ticker` and the `ChangeNotifierProvider<GameController>`.
   - The ticker callback calls `controller.tick(elapsed)`.
   - `Focus(autofocus: true, onKeyEvent: (_, e) => controller.onKeyEvent(e))`.
   - The body is a `Stack` containing `CustomPaint(painter: GameCanvasPainter(controller))`, the HUD, and the controls hint.
   - Call `controller.init()` in `initState`.
3. HUD widgets, each a `StatelessWidget` reading the controller with `context.watch` or `Selector`:
   - `HudStatusPanel` shows the status dot and text, the entity count, and the player position. It rebuilds on tick, which is acceptable because it is a small subtree. If this proves costly, drive it with a throttled `ValueNotifier` later.
   - `ControlsHint` is const.
   - `CloseButton` calls `Navigator.pop`.

## Step 7: Launcher

1. `launcher/launcher_controller.dart`:
   - `LauncherController extends ChangeNotifier`.
   - Owns `TextEditingController serverUrl` (default `ws://localhost:8080/ws`).
   - `bool get canHost => EmbeddedServerController.isSupported`.
   - `String? validatedUrl()` returns the trimmed URL, or null if empty.
   - Disposes the text controller.
2. `launcher/game_launcher_screen.dart`:
   - `ChangeNotifierProvider(create: (_) => LauncherController())`.
   - Same `Card` layout, composed from the widgets below.
3. Widgets: `LauncherHeader`, `LaunchButtons` (single player, host, join, and the web-unsupported hint), and `ServerUrlField`.
4. A shared `pushGameScreen(context, mode, {serverUrl})` helper replaces the three duplicated `Navigator.push` blocks.
5. `GameSessionMode` is imported from `game_controller.dart`.

## Step 8: Tests

| Test file | Covers |
|-----------|--------|
| `packages/game_client/test/game_session_test.dart` | Single-player spawn; input moves the entity; `tick` is deterministic for fixed `dt`; WelcomePacket and WorldStatePacket reconciliation (add, update, remove entities, set the local entity); no status callback after `dispose` |
| `apps/flutter_app/test/input_controller_test.dart` | W/A/S/D and arrow mapping, diagonal combinations, key-up reset |
| `apps/flutter_app/test/game_controller_test.dart` | Single-player init sets `statusText`; `tick` calls `notifyListeners`; `dispose` is idempotent |
| `apps/flutter_app/test/launcher_controller_test.dart` | Empty or whitespace URL returns null; valid URL is trimmed |
| `apps/flutter_app/test/widget_test.dart` | Update the existing test to the new structure; launcher shows the three actions |

Add `test` to the `game_client` dev dependencies if it is missing.

## Step 9: Verification

1. `dart analyze` in `packages/game_core`, `packages/game_server` and `packages/game_client`.
2. `flutter analyze` in `apps/flutter_app`.
3. `dart test` in `game_client`, and `flutter test` in `apps/flutter_app`.
4. Manual runs:
   - macOS: single player (WASD and arrows), host and play, and connect to a standalone server.
   - Web: `flutter run -d chrome` to confirm it still compiles. The host button must stay disabled.
5. Check in Flutter DevTools that no widget outside the HUD rebuilds per frame.

## Suggested Order and Checkpoints

1. Steps 1 and 2 (dependency and shell), then analyze.
2. Step 3 and its tests (`GameSession`), then analyze.
3. Steps 4 to 6 (game screen), then manual single-player check.
4. Step 7 (launcher), then manual check of all three modes.
5. Steps 8 and 9 (remaining tests and final verification).

## Risks

- **Status callback after dispose.** Covered by the `_disposed` guards in `GameSession` and `GameController`.
- **`shouldRepaint` returning `false`.** Safe only because the painter is built with `repaint: controller`. If the painter later gets other mutable inputs, revisit it.
- **HUD rebuilding every tick.** Acceptable now. Fall back to a throttled notifier if the HUD grows.
- **Web compilation.** Keep every reference to `EmbeddedServerController` going through `server/server_manager.dart`.
