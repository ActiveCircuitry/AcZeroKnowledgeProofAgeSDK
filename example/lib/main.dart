/**
 * Active Circuitry Zero Knowledge Age Verification SDK
 * Example Application
 * 
 * Demonstrates privacy-preserving age verification using ZKP.
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 * Author: Zeng Han Jun
 */

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/generate_proof_screen.dart';
import 'screens/verify_proof_screen.dart';
import 'screens/key_management_screen.dart';
import 'screens/about_screen.dart';

void main() {
  runApp(const AcZkpExampleApp());
}

class AcZkpExampleApp extends StatelessWidget {
  const AcZkpExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AC ZKP Age Verification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1E88E5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          elevation: 2,
          centerTitle: true,
          backgroundColor: Color(0xFF1E88E5),
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1E88E5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/generate': (context) => const GenerateProofScreen(),
        '/verify': (context) => const VerifyProofScreen(),
        '/keys': (context) => const KeyManagementScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}
