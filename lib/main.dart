import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() {
  runApp(const BarcodeScannerApp());
}
class BarcodeScannerApp extends StatelessWidget {
  const BarcodeScannerApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jinsovik Сканер',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 4,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.blueAccent),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 6,
            backgroundColor: Colors.blueAccent,
            shadowColor: const Color(0x9945A1FF), // 45A1FF at 60% opacity
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            minimumSize: const Size(200, 50),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          bodyMedium: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          headlineSmall: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
