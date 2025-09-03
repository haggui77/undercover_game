import 'package:flutter/material.dart';
import 'package:undercover_game/screens/home_screen.dart';
import 'package:undercover_game/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Undercover Game',
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
