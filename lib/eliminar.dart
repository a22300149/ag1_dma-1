import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EliminarPage extends StatefulWidget {
  final String libroId; // Recibe el ID del libro a eliminar
  final String libroTitulo; // Opcionalmente, puedes recibir también el título del libro

  EliminarPage({required this.libroId, required this.libroTitulo});

  @override
  _EliminarPageState createState() => _EliminarPageState();
}

class _EliminarPageState extends State<EliminarPage> {
  bool _isDeleting = false; // Para mostrar un indicador de carga

  // Función para eliminar el libro
  Future<void> _eliminarLibro() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.80.1/catalogo/eliminar_libro.php'), // URL para eliminar el libro
        body: {'id_libro': widget.libroId},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
          Navigator.pop(context); // Cierra la página después de eliminar
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${jsonResponse['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en el servidor. Código: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar con el servidor: $e')),
      );
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  // Confirmación antes de eliminar
  void _confirmarEliminacion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text(
            '¿Estás seguro de que deseas eliminar el libro "${widget.libroTitulo}"?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                _eliminarLibro(); // Llama a la función de eliminación
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Eliminar libro"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _isDeleting
              ? CircularProgressIndicator() // Muestra un indicador de carga mientras se elimina el libro
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.delete_forever, size: 60, color: Colors.red),
              SizedBox(height: 20),
              Text(
                "¿Estás seguro de que deseas eliminar este libro?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _confirmarEliminacion, // Llama al metodo de confirmación
                child: Text("Eliminar libro"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context), // Regresar a la página anterior
                child: Text("Cancelar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
