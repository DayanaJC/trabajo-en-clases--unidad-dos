import 'package:flutter/material.dart';

void main() {
  runApp(const cliente_screen());
}

class cliente_screen extends StatelessWidget {
  const cliente_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
