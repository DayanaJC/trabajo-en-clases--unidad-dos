import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class home_screen extends StatelessWidget {
  const home_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Productos"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('productos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar productos"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final productos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              var producto = productos[index];
              return ListTile(
                title: Text(producto['nombre']),
                subtitle: Text("Precio: S/. ${producto['precio']}"),
                trailing: Text("Stock: ${producto['stock']}"),
              );
            },
          );
        },
      ),
    );
  }
}
