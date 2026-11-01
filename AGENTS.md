# AGENTS.md

Instructions, operational rules, and architectural guidelines for AI agents working in this codebase.

## Operational Rules

1. **Read files only once to avoid token usage bloat.** Plan your context inspections ahead and avoid re-reading files you already accessed.
2. **Don't add comments unless explicitly asked.** Write clean, self-describing code without explanatory comments, docstrings, or inline notes unless specifically requested by the user.
3. **Run analyzers before finishing changes.** Ensure `dart analyze` and `flutter analyze` report zero errors and zero warnings across all packages and apps.

## Monorepo Structure & Separation of Concerns

```text
square_survival/
├── packages/
│   ├── game_core/       # Pure Dart: ECS, math, components, systems, packet serialization
│   ├── game_server/     # Pure Dart: Standalone WebSocket server and room logic
│   └── game_client/     # Pure Dart: Fixed-step accumulator, asset interfaces, network client
├── apps/
│   └── flutter_app/     # Flutter multi-platform shell (Desktop, Mobile, Web)
├── .vscode/             # Editor tasks for running client, web, and server
├── AGENTS.md            # Agent instructions and rules
└── README.md            # Quickstart and run instructions
```

### Architectural Principles

1. **Strict Dependency Hierarchy:**
   - `game_core`: Never import `dart:ui`, `package:flutter`, or `dart:io`. Must remain 100% pure Dart, runnable on any Dart runtime.
   - `game_server`: Pure Dart server runtime. Depends on `game_core` and `dart:io`. Never import `package:flutter` or `dart:ui`.
   - `game_client`: Pure Dart client library. Depends on `game_core` and `web_socket_channel`. Cross-platform across VM and Web. Never import `package:flutter` or `dart:ui`.
   - `apps/flutter_app`: The UI and rendering layer. Implements Flutter-specific adapters (`FlutterAssetLoader`, `CanvasRenderSystem`).

2. **Web Compatibility and Server Hosting Isolation:**
   - Flutter Web runs inside browsers and cannot access `dart:io` or bind server sockets (`HttpServer.bind`).
   - Web builds **cannot host** local servers. Web clients are restricted to **Single Player** (in-memory game loop) or **Connect to Server** (`ws://` / `wss://`).
   - Native platforms (macOS, Windows, Linux, Mobile) may host embedded servers.
   - Any server-hosting code referenced by `apps/flutter_app` must use conditional imports (`if (dart.library.io)`) to avoid breaking Web compilation.

3. **Deterministic Fixed-Timestep Loop:**
   - Both client and server employ fixed-step delta updates (`dt = 1/60` or `1/30`) with accumulator buffers to maintain deterministic state progression.
   - Canvas rendering interpolates positions using the accumulator alpha.
