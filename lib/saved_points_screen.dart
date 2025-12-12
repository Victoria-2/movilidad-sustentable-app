import 'package:flutter/material.dart';

class SavedPointsScreen extends StatefulWidget {
  final List<PointItem> savedPoints;
  final void Function(PointItem) onAddSavedPoint;
  final void Function(int) onRemoveSavedPoint;
  final void Function(int, PointItem) onEditSavedPoint;

  SavedPointsScreen({
    required this.savedPoints,
    required this.onAddSavedPoint,
    required this.onRemoveSavedPoint,
    required this.onEditSavedPoint,
  });

  @override
  _SavedPointsScreenState createState() => _SavedPointsScreenState();
}

class _SavedPointsScreenState extends State<SavedPointsScreen> {
  @override
  void initState() {
    super.initState();
    print(">>> ENTRÉ A LA PANTALLA DE PUNTOS GUARDADOS <<<");
  }

  // ------------------ AGREGAR ------------------
  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final cityController = TextEditingController();
    final streetController = TextEditingController();
    final numberController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Agregar punto guardado'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nombre')),
              TextField(controller: cityController, decoration: InputDecoration(labelText: 'Ciudad')),
              TextField(controller: streetController, decoration: InputDecoration(labelText: 'Calle')),
              TextField(controller: numberController, decoration: InputDecoration(labelText: 'Número')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final city = cityController.text.trim();
              final street = streetController.text.trim();
              final number = numberController.text.trim();

              if (name.isNotEmpty && city.isNotEmpty && street.isNotEmpty && number.isNotEmpty) {
                widget.onAddSavedPoint(PointItem(
                  id: UniqueKey().toString(),
                  name: name,
                  city: city,
                  street: street,
                  number: number,
                ));
                Navigator.of(ctx).pop();
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // ------------------ EDITAR ------------------
  void _showEditDialog(BuildContext context, int index) {
    final point = widget.savedPoints[index];

    final nameController = TextEditingController(text: point.name);
    final cityController = TextEditingController(text: point.city);
    final streetController = TextEditingController(text: point.street);
    final numberController = TextEditingController(text: point.number);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar punto guardado'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nombre')),
              TextField(controller: cityController, decoration: InputDecoration(labelText: 'Ciudad')),
              TextField(controller: streetController, decoration: InputDecoration(labelText: 'Calle')),
              TextField(controller: numberController, decoration: InputDecoration(labelText: 'Número')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final updatedName = nameController.text.trim();
              final updatedCity = cityController.text.trim();
              final updatedStreet = streetController.text.trim();
              final updatedNumber = numberController.text.trim();

              if (updatedName.isNotEmpty && updatedCity.isNotEmpty && updatedStreet.isNotEmpty && updatedNumber.isNotEmpty) {
                widget.onEditSavedPoint(
                  index,
                  PointItem(
                    id: point.id,
                    name: updatedName,
                    city: updatedCity,
                    street: updatedStreet,
                    number: updatedNumber,
                  ),
                );
                Navigator.of(ctx).pop();
              }
            },
            child: Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Puntos Guardados')),
      body: ListView.builder(
        itemCount: widget.savedPoints.length,
        itemBuilder: (context, index) {
          final point = widget.savedPoints[index];
          return ListTile(
            title: Text(point.name),
            subtitle: Text('${point.city}, ${point.street} ${point.number}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditDialog(context, index),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => widget.onRemoveSavedPoint(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

// ------------------ MODELO ------------------
class PointItem {
  final String id;
  String name;
  String city;
  String street;
  String number;

  PointItem({
    required this.id,
    required this.name,
    required this.city,
    required this.street,
    required this.number,
  });

  @override
  String toString() {
    return '$name, $street $number, $city';
  }
}
