import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmpleadosScreen extends StatefulWidget {
  @override
  State<EmpleadosScreen> createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends State<EmpleadosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _busquedaController = TextEditingController();

  String _area = 'Cocina';
  bool _activo = true;
  DateTime _fechaIngreso = DateTime.now();

  String _filtro = ""; // <- texto de búsqueda

  List<String> areas = ['Cocina', 'Atención', 'Delivery', 'Administración'];

  void _guardarEmpleado({String? id}) async {
    if (_nombreController.text.isEmpty || _dniController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    Map<String, dynamic> empleado = {
      'nombre': _nombreController.text,
      'dni': _dniController.text,
      'area': _area,
      'cargo': _cargoController.text,
      'fechaIngreso': _fechaIngreso.toIso8601String(),
      'activo': _activo,
    };

    if (id == null) {
      await _firestore.collection('empleados').add(empleado);
    } else {
      await _firestore.collection('empleados').doc(id).update(empleado);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Empleado guardado correctamente')),
    );

    _nombreController.clear();
    _dniController.clear();
    _cargoController.clear();
    Navigator.pop(context);
  }

  void _mostrarFormulario({String? id, Map<String, dynamic>? data}) {
    if (data != null) {
      _nombreController.text = data['nombre'] ?? '';
      _dniController.text = data['dni'] ?? '';
      _cargoController.text = data['cargo'] ?? '';
      _area = data['area'] ?? 'Cocina';
      _activo = data['activo'] ?? true;
      _fechaIngreso = data['fechaIngreso'] != null
          ? DateTime.tryParse(data['fechaIngreso']) ?? DateTime.now()
          : DateTime.now();
    } else {
      _nombreController.clear();
      _dniController.clear();
      _cargoController.clear();
      _area = 'Cocina';
      _activo = true;
      _fechaIngreso = DateTime.now();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? 'Registrar Empleado' : 'Editar Empleado'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
              ),
              TextField(
                controller: _dniController,
                decoration: const InputDecoration(labelText: 'DNI'),
              ),
              DropdownButtonFormField(
                value: _area,
                decoration: const InputDecoration(labelText: 'Área'),
                items: areas
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _area = v!),
              ),
              TextField(
                controller: _cargoController,
                decoration: const InputDecoration(labelText: 'Cargo'),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Activo'),
                value: _activo,
                onChanged: (v) => setState(() => _activo = v),
              ),
              const SizedBox(height: 10),
              Text(
                'Fecha de ingreso: ${_fechaIngreso.toLocal().toString().split(' ')[0]}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _guardarEmpleado(id: id),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _eliminarEmpleado(String id) {
    _firestore.collection('empleados').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Empleado eliminado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Empleados')),
      body: Column(
        children: [
          // 🔎 Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _busquedaController,
              decoration: const InputDecoration(
                labelText: "Buscar por nombre o DNI",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _filtro = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('empleados').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // Aplicar filtro
                final filtrados = docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  var nombre = (data['nombre'] ?? "").toString().toLowerCase();
                  var dni = (data['dni'] ?? "").toString().toLowerCase();
                  return nombre.contains(_filtro) || dni.contains(_filtro);
                }).toList();

                if (filtrados.isEmpty) {
                  return const Center(child: Text("No se encontraron resultados"));
                }

                return ListView.builder(
                  itemCount: filtrados.length,
                  itemBuilder: (context, i) {
                    var data = filtrados[i].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['nombre'] ?? 'Sin nombre'),
                      subtitle: Text(
                        '${data['area'] ?? 'Sin área'} - ${data['cargo'] ?? 'Sin cargo'}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _mostrarFormulario(
                              id: filtrados[i].id,
                              data: data,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _eliminarEmpleado(filtrados[i].id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _mostrarFormulario(),
      ),
    );
  }
}
