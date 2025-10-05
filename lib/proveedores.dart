import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProveedoresScreen extends StatefulWidget {
  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _razonController = TextEditingController();
  final TextEditingController _rucController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _contactoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _categoria = 'Carnes';

  List<String> categorias = [
    'Carnes',
    'Verduras',
    'Bebidas',
    'Insumos',
  ];

  void _guardarProveedor({String? id}) async {
    if (_razonController.text.isEmpty || _rucController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa todos los campos')));
      return;
    }

    Map<String, dynamic> proveedor = {
      'razon': _razonController.text,
      'ruc': _rucController.text,
      'direccion': _direccionController.text,
      'contacto': _contactoController.text,
      'email': _emailController.text,
      'categoria': _categoria,
    };

    if (id == null) {
      await _firestore.collection('proveedores').add(proveedor);
    } else {
      await _firestore.collection('proveedores').doc(id).update(proveedor);
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Proveedor guardado correctamente')));

    _razonController.clear();
    _rucController.clear();
    _direccionController.clear();
    _contactoController.clear();
    _emailController.clear();
    Navigator.pop(context);
  }

  void _mostrarFormulario({String? id, Map<String, dynamic>? data}) {
    if (data != null) {
      _razonController.text = data['razon'];
      _rucController.text = data['ruc'];
      _direccionController.text = data['direccion'];
      _contactoController.text = data['contacto'];
      _emailController.text = data['email'];
      _categoria = data['categoria'];
    } else {
      _razonController.clear();
      _rucController.clear();
      _direccionController.clear();
      _contactoController.clear();
      _emailController.clear();
      _categoria = 'Carnes';
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? 'Registrar Proveedor' : 'Editar Proveedor'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _razonController, decoration: const InputDecoration(labelText: 'Razón Social')),
              TextField(controller: _rucController, decoration: const InputDecoration(labelText: 'RUC')),
              TextField(controller: _direccionController, decoration: const InputDecoration(labelText: 'Dirección')),
              TextField(controller: _contactoController, decoration: const InputDecoration(labelText: 'Contacto')),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
              DropdownButtonFormField(
                value: _categoria,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: categorias.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _categoria = v!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => _guardarProveedor(id: id), child: const Text('Guardar')),
        ],
      ),
    );
  }

  void _eliminarProveedor(String id) {
    _firestore.collection('proveedores').doc(id).delete();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Proveedor eliminado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Proveedores')),
      body: StreamBuilder(
        stream: _firestore.collection('proveedores').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              var proveedor = docs[i].data();
              return ListTile(
                title: Text(proveedor['razon']),
                subtitle: Text('${proveedor['categoria']} - ${proveedor['ruc']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _mostrarFormulario(id: docs[i].id, data: proveedor)),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () => _eliminarProveedor(docs[i].id)),
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
