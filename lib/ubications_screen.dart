import 'package:flutter/material.dart';

void main() {
  runApp(const ubications_screen());
}

class ubications_screen extends StatelessWidget {
  const ubications_screen({super.key});

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
