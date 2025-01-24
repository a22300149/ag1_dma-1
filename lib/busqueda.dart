import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuscarPage extends StatefulWidget {
  @override
  _BuscarPageState createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  final TextEditingController _busquedaController = TextEditingController(); // Controlador para el campo de búsqueda
  List<dynamic> _resultados = []; // Lista para almacenar los resultados de búsqueda
  bool _cargando = false; // Indica si se está realizando una búsqueda

  // Función para realizar la búsqueda
  Future<void> _buscarLibros() async {
    final query = _busquedaController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor ingrese un término de búsqueda')),
      );
      return;
    }

    setState(() {
      _cargando = true; // Muestra el indicador de carga
    });

    try {
      final url = Uri.parse('http://192.168.80.1/catalogo/buscar_libros.php'); // Cambiar a la ruta del servidor
      final response = await http.post(
        url,
        body: {'query': query}, // Envía el término de búsqueda
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body); // Decodifica la respuesta JSON
        setState(() {
          _resultados = data['libros'] ?? []; // Almacena los resultados
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar libros: Código ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar con el servidor: $e')),
      );
    } finally {
      setState(() {
        _cargando = false; // Oculta el indicador de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buscar Libros"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de texto para la búsqueda
            TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                labelText: 'Buscar',
                hintText: 'Ingrese el título, autor o género',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _buscarLibros(), // Realiza la búsqueda al presionar "Enter"
            ),
            SizedBox(height: 16.0),

            // Botón de búsqueda
            ElevatedButton(
              onPressed: _buscarLibros,
              child: Text('Buscar'),
            ),
            SizedBox(height: 16.0),

            // Indicador de carga o lista de resultados
            _cargando
                ? CircularProgressIndicator() // Muestra un spinner mientras se carga
                : Expanded(
              child: _resultados.isEmpty
                  ? Text('No se encontraron resultados') // Muestra mensaje si no hay resultados
                  : ListView.builder(
                itemCount: _resultados.length,
                itemBuilder: (context, index) {
                  final libro = _resultados[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: libro['portada_url'] != null
                          ? Image.network(libro['portada_url'], width: 50, height: 50, fit: BoxFit.cover)
                          : Icon(Icons.book),
                      title: Text(libro['titulo'] ?? 'Sin título'),
                      subtitle: Text('Autor: ${libro['autor'] ?? 'Desconocido'}\nGénero: ${libro['genero'] ?? 'No especificado'}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
