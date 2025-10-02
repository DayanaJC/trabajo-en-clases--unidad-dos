import 'cliente_screen.dart';
import 'home_screen.dart';
import 'ubications_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp()); 
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Bottom Nav Bar",
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const BottomNav(),
    );
  }
}

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _seleccion = 0;

  final List<Widget> _pantallas = const [
    home_screen(),      // 👈 aquí va tu lista de productos
    cliente_screen(),
    ubications_screen(),
  ];

  void _onItemSelected(int item) {
    setState(() {
      _seleccion = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_seleccion],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _seleccion,
        onTap: _onItemSelected,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Clientes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Ubicaciones",
          ),
        ],
      ),
    );
  }
}
