import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MovilidadApp());
}

class MovilidadApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Úrbanika', // Cambiado el título de la app
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Color(0xFFFAFBF9),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // Shared in-memory state
  final List<PointItem> _points = [];
  final List<PointItem> _savedPoints = []; // Nueva lista para puntos guardados
  int _pointCounter = 1; // Contador para los nombres automáticos de los puntos
  final List<Reward> _rewards = [
    Reward('Café Verde Eco', '20% de descuento en bebidas', 120, 'https://via.placeholder.com/150/coffee'),
    Reward('BiciFix Taller', 'Ajuste de frenos gratuito', 250, 'https://via.placeholder.com/150/bike'),
    Reward('Tienda de Bicis', '300 pts descuento en accesorios', 300, 'https://via.placeholder.com/150/shop'),
    Reward('EcoMarket', '10% de descuento en productos', 200, 'https://via.placeholder.com/150/market'),
    Reward('Green Gym', '1 mes gratis de membresía', 500, 'https://via.placeholder.com/150/gym'),
    Reward('EcoViajes', '50% de descuento en tours', 800, 'https://via.placeholder.com/150/travel'),
    Reward('EcoModa', '15% de descuento en ropa', 180, 'https://via.placeholder.com/150/fashion'),
    Reward('CicloRutas', 'Acceso gratuito a rutas premium', 400, 'https://via.placeholder.com/150/routes'),
    Reward('EcoCine', '2 entradas gratis', 350, 'https://via.placeholder.com/150/cinema'),
    Reward('GreenTech', '20% de descuento en gadgets', 600, 'https://via.placeholder.com/150/tech'),
  ];
  int userPoints = 150;

  // Keys for AnimatedList
  final GlobalKey<AnimatedListState> _pointsListKey = GlobalKey<AnimatedListState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cambia la pestaña según el índice
    });
  }

  void _addPoint(String? name, String city, String street, String number) {
    final pointName = name?.isNotEmpty == true ? name! : 'Punto $_pointCounter'; // Asignar nombre automático si está vacío
    final newItem = PointItem(
      id: UniqueKey().toString(),
      name: pointName,
      city: city,
      street: street,
      number: number,
    );
    final index = _points.length;
    _points.add(newItem);
    _pointsListKey.currentState?.insertItem(index, duration: Duration(milliseconds: 350));
    _pointCounter++; // Incrementar el contador
  }

  void _removePoint(int index) {
    final removed = _points.removeAt(index);
    _pointsListKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        axis: Axis.vertical,
        child: PointCard(
          key: ValueKey(removed.id),
          item: removed,
          onDelete: () {}, // No se necesita un índice aquí
          onEdit: (s) {},
        ),
      ),
      duration: Duration(milliseconds: 300),
    );
  }

  void _editPoint(int index, String newName) {
    setState(() {
      _points[index].name = newName;
    });
  }

  void _redeemReward(Reward r) {
    if (userPoints >= r.cost) {
      setState(() {
        userPoints -= r.cost;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Canjeado: ${r.title} — ¡disfrutalo!'),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No tenés puntos suficientes.'),
        backgroundColor: Colors.orange,
      ));
    }
  }

  void _addPoints() {
    setState(() {
      userPoints += 100; // Incrementa los puntos del usuario en 100
    });
  }

  void _addSavedPoint(PointItem point) {
    setState(() {
      _savedPoints.add(point);
    });
  }

  void _removeSavedPoint(int index) {
    setState(() {
      _savedPoints.removeAt(index);
    });
  }

  void _editSavedPoint(int index, PointItem updatedPoint) {
    setState(() {
      _savedPoints[index] = updatedPoint;
    });
  }

  List<Widget> get _pages => [
        HomeScreen(
            onNavigate: (i) => _onItemTapped(i),
            userPoints: userPoints,
            onAddPoints: _addPoints,
            onAddPoint: _addPoint,   // ← ESTE ES EL FIX
          ),

        GenerateRouteScreen(
          points: _points,
          pointsListKey: _pointsListKey,
          onAddPoint: _addPoint,
          onRemovePoint: _removePoint,
          onEditPoint: _editPoint,
          savedPoints: _savedPoints,
        ),
        RewardsScreen(
          rewards: _rewards,
          userPoints: userPoints,
          onRedeem: _redeemReward,
        ),
        SavedPointsScreen(
          savedPoints: _savedPoints,
          onAddSavedPoint: _addSavedPoint,
          onRemoveSavedPoint: _removeSavedPoint,
          onEditSavedPoint: _editSavedPoint,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        }),
        title: Text('Úrbanika'), // Cambiado el título del AppBar
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(child: Text('$userPoints pts', style: TextStyle(fontWeight: FontWeight.w600))),
          ),
        ],
      ),
      drawer: AppDrawer(
        onSelect: (i) {
          Navigator.of(context).pop();
          _onItemTapped(i); // Asegurarse de que el índice correcto se pase aquí
        },
        userName: 'María',
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 350),
        child: _pages[_selectedIndex], // Cambia la página según el índice seleccionado
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey.shade600,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'), // Índice 0
          BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Recorrido'), // Índice 1
          BottomNavigationBarItem(icon: Icon(Icons.redeem), label: 'Recompensas'), // Índice 2
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Guardados'), // Índice 3
        ],
      ),
    );
  }
}

/* ---------------------- MODELS ---------------------- */

class PointItem {
  final String id;
  String name;
  String city; // Nueva propiedad
  String street; // Nueva propiedad
  String number; // Nueva propiedad

  PointItem({
    required this.id,
    required this.name,
    required this.city,
    required this.street,
    required this.number,
  });

  @override
  String toString() {
    return '$name, $street $number, $city'; // Formato para mostrar el punto
  }
}

class Reward {
  final String title;
  final String description;
  final int cost;
  final String image;

  Reward(this.title, this.description, this.cost, this.image);
}

/* ---------------------- DRAWER ---------------------- */

class AppDrawer extends StatelessWidget {
  final void Function(int) onSelect;
  final String userName; // Nueva variable para el nombre del usuario

  AppDrawer({required this.onSelect, this.userName = 'Usuario'}); // Valor predeterminado: 'Usuario'

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green.shade700),
              child: Center(
                child: Text(
                  'Hola $userName 👋!', // Cambiado el texto del encabezado
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            ListTile(leading: Icon(Icons.home), title: Text('Inicio'), onTap: () => onSelect(0)), // Índice 0
            ListTile(leading: Icon(Icons.route), title: Text('Generar recorrido'), onTap: () => onSelect(1)), // Índice 1
            ListTile(leading: Icon(Icons.redeem), title: Text('Recompensas'), onTap: () => onSelect(2)), // Índice 2
            ListTile(leading: Icon(Icons.bookmark), title: Text('Puntos guardados'), onTap: () => onSelect(3)), // Índice 3
            Divider(),
            ListTile(leading: Icon(Icons.settings), title: Text('Configuración'), onTap: () {}),
            ListTile(leading: Icon(Icons.logout), title: Text('Cerrar sesión'), onTap: () {}),
          ],
        ),
      ),
    );
  }
}

/* ---------------------- HOME ---------------------- */

class HomeScreen extends StatelessWidget {
  final void Function(int) onNavigate;
  final int userPoints;
  final VoidCallback onAddPoints;
  final void Function(String name, String city, String street, String number) onAddPoint;


  HomeScreen({
  required this.onNavigate,
  required this.userPoints,
  required this.onAddPoints,
  required this.onAddPoint, // ← NUEVO
});


  void _showUnavailableMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Funcionalidad no disponible. Estamos trabajando para mejorarlo.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            // Puntos destacados en la parte superior
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Puntos disponibles:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                    ),
                    Text(
                      '$userPoints pts',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20), // Espaciado entre los puntos y el resto del contenido
              BigCard(
                icon: Icons.add,
                title: 'Agregar Punto',
                subtitle: 'Añadí un nuevo punto para tus rutas',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPointScreen(
                        onAddPoint: (name, city, street, number) {
                          final mainState = context.findAncestorStateOfType<_MainScaffoldState>();

                          if (mainState != null) {
                            mainState._addPoint(
                              name ?? "",
                              city,
                              street,
                              number,
                            );
                          }

                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              ),


            SizedBox(height: 12),
            BigCard(
              icon: Icons.directions_bike,
              title: 'Generar Recorrido',
              subtitle: 'Creá rutas sustentables con tus puntos',
              onTap: () => onNavigate(1), // Índice correcto para "Recorrido"
            ),
            SizedBox(height: 18),
            BigCard(
              icon: Icons.card_giftcard,
              title: 'Recompensas',
              subtitle: 'Canjeá tus puntos por beneficios',
              onTap: () => onNavigate(2), // Índice correcto para "Recompensas"
            ),
            SizedBox(height: 18),
            BigCard(
              icon: Icons.bookmark,
              title: 'Puntos Guardados',
              subtitle: 'Gestioná tus puntos favoritos',
              onTap: () => onNavigate(3), // Índice correcto para "Guardados"
            ),
            SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SmallCard(
                  icon: Icons.emoji_events,
                  title: 'Mis Logros',
                  onTap: () => _showUnavailableMessage(context), // Muestra el mensaje
                ),
                SmallCard(
                  icon: Icons.event,
                  title: 'Eventos',
                  onTap: () => _showUnavailableMessage(context), // Muestra el mensaje
                ),
                SmallCard(
                  icon: Icons.timeline,
                  title: 'Historial de recorridos',
                  onTap: () => _showUnavailableMessage(context), // Muestra el mensaje
                ),
                SmallCard(
                  icon: Icons.store,
                  title: 'Comercios adheridos',
                  onTap: () => _showUnavailableMessage(context), // Muestra el mensaje
                ),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddPoints,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  BigCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell( // Cambiado de GestureDetector a InkWell para agregar feedback visual
      onTap: onTap,
      borderRadius: BorderRadius.circular(14), // Efecto ripple con bordes redondeados
      child: Material(
        borderRadius: BorderRadius.circular(14),
        elevation: 2,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              CircleAvatar(radius: 28, backgroundColor: Colors.green.shade50, child: Icon(icon, size: 28, color: Colors.green.shade700)),
              SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
                ]),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class SmallCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  SmallCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 48) / 2;
    return InkWell( // Cambiado de GestureDetector a InkWell para agregar feedback visual
      onTap: onTap,
      borderRadius: BorderRadius.circular(12), // Efecto ripple con bordes redondeados
      child: Material(
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: Container(
          width: width,
          height: 112,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.green.shade700),
              SizedBox(height: 10),
              Text(title, style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------------- GENERATE ROUTE ---------------------- */

class GenerateRouteScreen extends StatefulWidget {
  final List<PointItem> points;
  final GlobalKey<AnimatedListState> pointsListKey;
  final void Function(String, String, String, String) onAddPoint; // Actualizado para aceptar 4 parámetros
  final void Function(int) onRemovePoint;
  final void Function(int, String) onEditPoint;
  final List<PointItem> savedPoints; // Nueva lista para puntos guardados

  GenerateRouteScreen({
    required this.points,
    required this.pointsListKey,
    required this.onAddPoint,
    required this.onRemovePoint,
    required this.onEditPoint,
    required this.savedPoints, // Inicializar la lista de puntos guardados
  });

  @override
  _GenerateRouteScreenState createState() => _GenerateRouteScreenState();
}

class _GenerateRouteScreenState extends State<GenerateRouteScreen> {
  void _showAddDialog() {
    // Controladores con valores predeterminados
    final nameController = TextEditingController();
    final cityController = TextEditingController(text: 'Ciudad predeterminada');
    final streetController = TextEditingController(text: 'Calle predeterminada');
    final numberController = TextEditingController(text: '123');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Agregar punto al trayecto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre del punto (opcional)'),
              ),
              TextField(
                controller: cityController,
                decoration: InputDecoration(labelText: 'Ciudad'),
              ),
              TextField(
                controller: streetController,
                decoration: InputDecoration(labelText: 'Calle'),
              ),
              TextField(
                controller: numberController,
                decoration: InputDecoration(labelText: 'Número'),
                keyboardType: TextInputType.number,
              ),
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

              if (city.isNotEmpty && street.isNotEmpty && number.isNotEmpty) {
                setState(() {
                  widget.onAddPoint(name.isEmpty ? "" : name, city, street, number);
                });
                Navigator.of(ctx).pop();
              }
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(int index) {
    final point = widget.points[index];
    final nameController = TextEditingController(text: point.name);
    final cityController = TextEditingController(text: point.city);
    final streetController = TextEditingController(text: point.street);
    final numberController = TextEditingController(text: point.number);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar punto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre del punto'),
              ),
              TextField(
                controller: cityController,
                decoration: InputDecoration(labelText: 'Ciudad'),
              ),
              TextField(
                controller: streetController,
                decoration: InputDecoration(labelText: 'Calle'),
              ),
              TextField(
                controller: numberController,
                decoration: InputDecoration(labelText: 'Número'),
                keyboardType: TextInputType.number,
              ),
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
                setState(() {
                  widget.onEditPoint(index, name); // Actualizar el nombre
                  point.city = city; // Actualizar la ciudad
                  point.street = street; // Actualizar la calle
                  point.number = number; // Actualizar el número
                });
                Navigator.of(ctx).pop();
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = widget.points.removeAt(oldIndex);
      widget.points.insert(newIndex, item);
    });
  }

  void _showLoadingDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita que se cierre al tocar fuera del diálogo
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Evita que se cierre con el botón de retroceso
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.green),
                SizedBox(height: 16),
                Text('Generando trayecto...', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    // Simula un tiempo de espera de 2 segundos
    await Future.delayed(Duration(seconds: 2));

    // Cierra el diálogo
    Navigator.of(context).pop();

    // Cambia el índice a la pantalla principal y reconstruye la interfaz
    final mainScaffoldState = context.findAncestorStateOfType<_MainScaffoldState>();
    if (mainScaffoldState != null) {
      mainScaffoldState.setState(() {
        mainScaffoldState._selectedIndex = 0; // Cambia al índice de HomeScreen
      });

      // Muestra el SnackBar con el mensaje
      ScaffoldMessenger.of(mainScaffoldState.context).showSnackBar(
        SnackBar(
          content: Text('Trayecto generado correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2), // Duración del mensaje
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey('generate'),
      children: [
        // Map placeholder
        Container(
          height: 240,
          margin: EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(14)),
          child: Center(child: Icon(Icons.map, size: 72, color: Colors.green.shade700)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(children: [
            Text('Puntos agregados:', style: TextStyle(fontWeight: FontWeight.bold)),
            Spacer(),
            Text('${widget.points.length}'),
          ]),
        ),
        SizedBox(height: 8),
        Expanded(
          child: ReorderableListView.builder(
            onReorder: _onReorder,
            proxyDecorator: (child, index, animation) {
              return Material(
                elevation: 2,
                child: child,
              );
            },
            buildDefaultDragHandles: false, // Desactiva los íconos de reordenamiento predeterminados
            itemCount: widget.points.length,
            itemBuilder: (context, index) {
              return PointCard(
                key: ValueKey(widget.points[index].id),
                item: widget.points[index],
                index: index, // Pasa el índice real al PointCard
                onDelete: () => widget.onRemovePoint(index),
                onEdit: (s) => _showEditDialog(index),
                showReorderIcon: true, // Asegúrate de que el ícono izquierdo sea funcional
              );
            },
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.play_arrow),
                  label: Text('Crear recorrido'),
                  onPressed: widget.points.isEmpty
                      ? null
                      : () {
                          _showLoadingDialog(); // Muestra el diálogo de carga
                        },
                ),
              ),
              SizedBox(width: 12),
              FloatingActionButton(
                onPressed: _showAddDialog,
                child: Icon(Icons.add),
                mini: true,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class PointCard extends StatelessWidget {
  final PointItem item;
  final int? index; // Hacemos que el índice sea opcional
  final VoidCallback onDelete;
  final void Function(String) onEdit;
  final bool showReorderIcon; // Propiedad para mostrar el ícono de reordenamiento

  const PointCard({
    Key? key,
    required this.item,
    this.index, // Ahora es opcional
    required this.onDelete,
    required this.onEdit,
    this.showReorderIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              if (showReorderIcon && index != null) ...[
                ReorderableDragStartListener( // Usa el índice solo si no es null
                  index: index!,
                  child: Icon(Icons.drag_handle, color: Colors.grey.shade700),
                ),
                SizedBox(width: 12),
              ],
              Icon(Icons.location_on, color: Colors.green.shade700),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text(
                      '${item.city}, ${item.street} ${item.number}', // Subtítulo con ciudad, calle y número
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: () => onEdit(item.name), child: Text('Editar')),
              IconButton(onPressed: onDelete, icon: Icon(Icons.delete_outline, color: Colors.red.shade400)),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------------- REWARDS ---------------------- */

class RewardsScreen extends StatelessWidget {
  final List<Reward> rewards;
  final int userPoints;
  final void Function(Reward) onRedeem;

  RewardsScreen({
    required this.rewards,
    required this.userPoints,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey('rewards'),
      padding: const EdgeInsets.all(12.0),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ------- CHIPS DE FILTRO -------
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    avatar: Icon(Icons.local_cafe, size: 18),
                    label: Text("Cafeterías"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    avatar: Icon(Icons.restaurant, size: 18),
                    label: Text("Restaurantes"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    avatar: Icon(Icons.shopping_bag, size: 18),
                    label: Text("Tiendas"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    avatar: Icon(Icons.percent, size: 18),
                    label: Text("Descuentos"),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // ------- LISTA DE RECOMPENSAS -------
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                final r = rewards[index];
                return RewardCard(
                  r: r,
                  userPoints: userPoints,
                  onTapDetail: () async {
                    await showDialog(
                      context: context,
                      builder: (_) => RewardDetailDialog(
                        reward: r,
                        userPoints: userPoints,
                        onRedeem: () => onRedeem(r),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (_, __) => SizedBox(height: 12),
              itemCount: rewards.length,
            ),
          ),
        ],
      ),
    );
  }
}


class RewardCard extends StatelessWidget {
  final Reward r;
  final int userPoints;
  final VoidCallback onTapDetail;

  RewardCard({required this.r, required this.userPoints, required this.onTapDetail});

  @override
  Widget build(BuildContext context) {
    final available = userPoints >= r.cost;

    return InkWell(
      onTap: onTapDetail,
      borderRadius: BorderRadius.circular(12),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(image: NetworkImage(r.image), fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text(r.description, style: TextStyle(color: Colors.grey.shade700)),
                ]),
              ),
              Column(
                children: [
                  Text('${r.cost} pts', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Icon(available ? Icons.check_circle : Icons.lock, color: available ? Colors.green : Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class RewardDetailDialog extends StatefulWidget {
  final Reward reward;
  final int userPoints;
  final VoidCallback onRedeem;

  RewardDetailDialog({required this.reward, required this.userPoints, required this.onRedeem});

  @override
  _RewardDetailDialogState createState() => _RewardDetailDialogState();
}

class _RewardDetailDialogState extends State<RewardDetailDialog> {
  String? _redeemCode;

  String _generateRedeemCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final available = widget.userPoints >= widget.reward.cost;

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.reward.title),
          SizedBox(height: 4),
          Text('Comercio: ${widget.reward.title}', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
            child: Center(child: Icon(Icons.local_cafe, size: 48)),
          ),
          SizedBox(height: 12),
          Text(widget.reward.description),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Puntos necesarios:', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('${widget.reward.cost} pts'),
            ],
          ),
          if (_redeemCode != null) ...[
            SizedBox(height: 16),
            Text(
              'Código generado:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 8),
            Text(
              _redeemCode!,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancelar')),
        ElevatedButton(
          onPressed: available
              ? () {
                  setState(() {
                    _redeemCode = _generateRedeemCode();
                  });
                  widget.onRedeem();
                }
              : null,
          child: Text('Canjear'),
        ),
      ],
    );
  }
}

/* ---------------------- SAVED POINTS ---------------------- */

class SavedPointsScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey('saved_points'),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                final point = savedPoints[index];
                return SavedPointCard(
                  point: point,
                  onDelete: () => onRemoveSavedPoint(index),
                  onEdit: (updatedPoint) => onEditSavedPoint(index, updatedPoint),
                );
              },
              separatorBuilder: (_, __) => SizedBox(height: 12),
              itemCount: savedPoints.length,
            ),
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () {
              // Lógica para agregar un nuevo punto guardado
              final newPoint = PointItem(
                id: UniqueKey().toString(),
                name: 'Nuevo Punto',
                city: 'Ciudad',
                street: 'Calle',
                number: '456',
              );
              onAddSavedPoint(newPoint);
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class SavedPointCard extends StatelessWidget {
  final PointItem point;
  final VoidCallback onDelete;
  final void Function(PointItem) onEdit;

  const SavedPointCard({
    Key? key,
    required this.point,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Colors.green.shade700),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(point.name, style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text(
                    '${point.city}, ${point.street} ${point.number}', // Subtítulo con ciudad, calle y número
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // Lógica para editar el punto guardado
                final updatedPoint = PointItem(
                  id: point.id,
                  name: '${point.name} (editado)',
                  city: point.city,
                  street: point.street,
                  number: point.number,
                );
                onEdit(updatedPoint);
              },
              icon: Icon(Icons.edit, color: Colors.blue.shade400),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------------- ADD POINT SCREEN ---------------------- */

class AddPointScreen extends StatelessWidget {
  final void Function(String? name, String city, String street, String number) onAddPoint;

  AddPointScreen({required this.onAddPoint});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final cityController = TextEditingController();
    final streetController = TextEditingController();
    final numberController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Punto'),
        actions: [
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final city = cityController.text.trim();
              final street = streetController.text.trim();
              final number = numberController.text.trim();

              if (city.isNotEmpty && street.isNotEmpty && number.isNotEmpty) {
                onAddPoint(name.isEmpty ? null : name, city, street, number);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Por favor, completa todos los campos.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre del punto (opcional):', style: TextStyle(fontSize: 16)),
            TextField(
              controller: nameController,
              decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Ej. Mi Punto Favorito'),
            ),
            SizedBox(height: 16),
            Text('Ciudad:', style: TextStyle(fontSize: 16)),
            TextField(
              controller: cityController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            Text('Calle:', style: TextStyle(fontSize: 16)),
            TextField(
              controller: streetController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            Text('Número:', style: TextStyle(fontSize: 16)),
            TextField(
              controller: numberController,
              decoration: InputDecoration(border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}
