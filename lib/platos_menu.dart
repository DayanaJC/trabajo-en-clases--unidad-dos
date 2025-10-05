import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlatosMenuScreen extends StatefulWidget {
  @override
  State<PlatosMenuScreen> createState() => _PlatosMenuScreenState();
}

class _PlatosMenuScreenState extends State<PlatosMenuScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _tamanoController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  String _categoria = 'Pollo a la brasa';
  bool _disponible = true;

  List<String> categorias = [
    'Pollo a la brasa',
    'Parrillas',
    'Bebidas',
    'Guarniciones',
    'Postres'
  ];

  void _guardarPlato({String? id}) async {
    if (_nombreController.text.isEmpty || _precioController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Completa todos los campos')));
      return;
    }

    Map<String, dynamic> plato = {
      'nombre': _nombreController.text,
      'categoria': _categoria,
      'tamano': _tamanoController.text,
      'precio': double.tryParse(_precioController.text) ?? 0,
      'disponible': _disponible,
    };

    if (id == null) {
      await _firestore.collection('platos').add(plato);
    } else {
      await _firestore.collection('platos').doc(id).update(plato);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plato guardado correctamente')),
    );

    _nombreController.clear();
    _tamanoController.clear();
    _precioController.clear();
    Navigator.pop(context);
  }

  void _mostrarFormulario({String? id, Map<String, dynamic>? data}) {
    if (data != null) {
      _nombreController.text = data['nombre'];
      _tamanoController.text = data['tamano'];
      _precioController.text = data['precio'].toString();
      _categoria = data['categoria'];
      _disponible = data['disponible'];
    } else {
      _nombreController.clear();
      _tamanoController.clear();
      _precioController.clear();
      _categoria = 'Pollo a la brasa';
      _disponible = true;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? 'Registrar Plato' : 'Editar Plato'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre del plato')),
              DropdownButtonFormField(
                value: _categoria,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: categorias.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _categoria = v!),
              ),
              TextField(controller: _tamanoController, decoration: const InputDecoration(labelText: 'Tamaño / Porción')),
              TextField(controller: _precioController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Precio')),
              SwitchListTile(
                title: const Text('Disponible'),
                value: _disponible,
                onChanged: (v) => setState(() => _disponible = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => _guardarPlato(id: id), child: const Text('Guardar')),
        ],
      ),
    );
  }

  void _eliminarPlato(String id) {
    _firestore.collection('platos').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plato eliminado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Platos y Menú')),
      body: StreamBuilder(
        stream: _firestore.collection('platos').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              var plato = docs[i].data();
              return ListTile(
                title: Text(plato['nombre']),
                subtitle: Text('${plato['categoria']} - S/.${plato['precio']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _mostrarFormulario(id: docs[i].id, data: plato)),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () => _eliminarPlato(docs[i].id)),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _mostrarFormulario(),
      ),
    );
  }
}
