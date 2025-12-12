import 'package:flutter/material.dart';

class AddPointScreen extends StatefulWidget {
  final void Function(String? name, String? city, String? street, String? number)
      onAddPoint;

  const AddPointScreen({required this.onAddPoint, super.key});

  @override
  _AddPointScreenState createState() => _AddPointScreenState();
}

class _AddPointScreenState extends State<AddPointScreen> {
  late TextEditingController nameController;
  late TextEditingController cityController;
  late TextEditingController streetController;
  late TextEditingController numberController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    cityController = TextEditingController();
    streetController = TextEditingController();
    numberController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    cityController.dispose();
    streetController.dispose();
    numberController.dispose();
    super.dispose();
  }

  void savePoint() {
    final name = nameController.text.trim();
    final city = cityController.text.trim();
    final street = streetController.text.trim();
    final number = numberController.text.trim();

    if (city.isEmpty || street.isEmpty || number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Completá todos los campos obligatorios."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onAddPoint(
      name.isEmpty ? null : name,
      city,
      street,
      number,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Punto'),
        actions: [
          TextButton(
            onPressed: savePoint,
            child: const Text(
              'Guardar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(labelText: 'Nombre del punto (opcional)'),
            ),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: 'Ciudad'),
            ),
            TextField(
              controller: streetController,
              decoration: const InputDecoration(labelText: 'Calle'),
            ),
            TextField(
              controller: numberController,
              decoration: const InputDecoration(labelText: 'Número'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            /// Botón único
            ElevatedButton.icon(
              onPressed: savePoint,
              icon: const Icon(Icons.save),
              label: const Text("Guardar punto"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
