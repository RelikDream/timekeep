import 'package:flutter/material.dart';

void main() {
  runApp(const TimekeepApp());
}

/// Root widget of the app.
class TimekeepApp extends StatelessWidget {
  /// Creates the root widget.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pointage',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const Scaffold(
        body: Center(child: Text('Pointage')),
      ),
    );
  }
}
