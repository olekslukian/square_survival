# Square Survival

A 2D orthographic pixel-art multiplayer sandbox game engine and client built in 100% Pure Dart and Flutter.

## Project Structure

```text
square_survival/
├── packages/
│   ├── game_core/       # Pure Dart: ECS, components, systems, network packets
│   ├── game_server/     # Pure Dart: Standalone WebSocket server & game room simulation
│   └── game_client/     # Pure Dart: Fixed-step game loop, network client & asset contracts
├── apps/
│   └── flutter_app/     # Flutter application (macOS, Windows, Linux, iOS, Android, Web)
├── .vscode/             # VS Code automation tasks
├── AGENTS.md            # Guidelines and rules for AI agents
└── README.md
```

## Platform Capabilities

- **Desktop & Mobile:** Supports Single Player, Hosting Local Server, and Connecting to Remote Servers.
- **Web:** Supports Single Player and Connecting to Remote Servers (Web clients cannot host local servers due to browser networking sandbox).

---

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.32)
- Dart SDK (>= 3.8)

### 1. Running the Dedicated Game Server

From the root directory:

```bash
cd packages/game_server
dart pub get
dart run bin/server.dart
```

By default, the server listens on `http://localhost:8080` with WebSocket endpoint `ws://localhost:8080/ws`.

You can also specify a custom port:

```bash
dart run bin/server.dart 9000
```

Verify the server is running:

```bash
curl http://localhost:8080/health
# {"status":"online","players":0}
```

---

### 2. Running the Flutter Game Client

From the root directory:

```bash
cd apps/flutter_app
flutter pub get
```

#### Run on Web (Chrome)

```bash
flutter run -d chrome
```

#### Run on Desktop

- **macOS:**
  ```bash
  flutter run -d macos
  ```
- **Windows:**
  ```bash
  flutter run -d windows
  ```
- **Linux:**
  ```bash
  flutter run -d linux
  ```

#### Run on Mobile

```bash
flutter run -d android
# or
flutter run -d ios
```

---

### 3. Testing and Verification

Run tests and analyzer across the workspace:

```bash
# Core package
cd packages/game_core && dart test && dart analyze

# Server package
cd ../game_server && dart analyze

# Client package
cd ../game_client && dart analyze

# Flutter App
cd ../../apps/flutter_app && flutter test && flutter analyze
```
