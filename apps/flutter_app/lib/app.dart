import 'package:flutter/material.dart';
import 'package:flutter_app/launcher/game_launcher_screen.dart';

class SquareSurvivalApp extends StatelessWidget {
  const SquareSurvivalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Square Survival',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF141419),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4CAF50),
          secondary: Color(0xFF03A9F4),
        ),
      ),
      home: const GameLauncherScreen(),
    );
  }
}
