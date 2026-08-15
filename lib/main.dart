import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/search_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub User Search',



      themeMode: ThemeMode.system, // Automatically switch based on system settings
      home: const SearchScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
