import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'platos_menu.dart';
import 'empleados.dart';
import 'proveedores.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Gestión del Restaurante',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 3,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Principal')),
      body: const Center(
        child: Text(
          'Bienvenido a la Pollería Don Pollo S.A.C.',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text(
                'Gestión de la Polleria Don Pollo',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant, color: Colors.teal),
              title: const Text('Platos y Menú'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PlatosMenuScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.teal),
              title: const Text('Empleados'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EmpleadosScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping, color: Colors.teal),
              title: const Text('Proveedores'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProveedoresScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
