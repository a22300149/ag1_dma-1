import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'eliminar.dart';
import 'nuevo_reg.dart';
import 'busqueda.dart';
import 'actualizar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      routes: {
        '/main': (context) => HomePage(),
        '/eliminar': (context) => EliminarPage(libroId: '', libroTitulo: ''), // Actualiza esta ruta si es necesario
        '/nuevo_reg': (context) => NuevoPage(), // Ruta para nuevo registro
        '/busqueda': (context) => BuscarPage(), // Ruta para búsqueda
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> _libros = []; // Lista para almacenar los libros obtenidos del servidor
  bool _isLoading = true; // Bandera para controlar el estado de carga

  @override
  void initState() {
    super.initState();
    _fetchLibros(); // Cargar los libros al iniciar la pantalla
  }

  // Función para obtener los libros del servidor
  Future<void> _fetchLibros() async {
    final url = Uri.parse('http://192.168.80.1/catalogo/buscar_libros.php');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _libros = data['libros'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showError('Error al cargar libros: Código ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error al conectar con el servidor: $e');
    }
  }

  // Mostrar un mensaje de error en la pantalla
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Eliminar un libro de la lista
  void _eliminarLibroDeLista(String libroId) {
    setState(() {
      _libros.removeWhere((libro) => libro['id_libro'] == libroId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Catálogo de libros"),
        centerTitle: true,
        actions: [
          // Botón de actualización en el AppBar
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _fetchLibros(); // Llama la función para recargar los libros
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Mostrar indicador de carga
          : _libros.isEmpty
          ? Center(child: Text('No hay libros disponibles')) // Mensaje si no hay libros
          : ListView.builder(
        itemCount: _libros.length,
        itemBuilder: (context, index) {
          final libro = _libros[index];
          final libroId = libro['id_libro'];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: libro['portada_url'] != null
                  ? Image.network(
                libro['portada_url'], // URL de la portada
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : Icon(Icons.book, size: 50), // Ícono si no hay portada
              title: Text(libro['titulo'] ?? 'Sin título'),
              subtitle: Text(
                'Autor: ${libro['autor'] ?? 'Desconocido'}\nGénero: ${libro['genero'] ?? 'Desconocido'}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min, // Esto asegura que los íconos se alineen en una fila
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      // Acción para editar el libro (navegar a la página de actualización)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActualizarPage(
                            idLibro: libroId,
                            tituloActual: libro['titulo'],
                            generoActual: libro['genero'],
                            autorActual: libro['autor'],
                            portadaUrlActual: libro['portada_url'] ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Navegar a la página de eliminar libro pasando el ID y título
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EliminarPage(
                            libroId: libroId,
                            libroTitulo: libro['titulo'] ?? 'Desconocido', // Pasamos el título
                          ),
                        ),
                      ).then((value) {
                        if (value == true) {
                          _eliminarLibroDeLista(libroId); // Elimina el libro de la lista
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  _scaffoldKey.currentState?.closeDrawer();
                },
              ),
            ),
            ListTile(
              title: Text("Inicio"),
              leading: Icon(Icons.home),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/main');
              },
            ),
            ListTile(
              title: Text("Nuevo registro"),
              leading: Icon(Icons.add),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/nuevo_reg'); // Navega a la página de nuevo registro
              },
            ),
            ListTile(
              title: Text("Búsqueda"),
              leading: Icon(Icons.search),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/busqueda'); // Navega a la página de búsqueda
              },
            ),
          ],
        ),
      ),
    );
  }
}
