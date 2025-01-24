import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';

class NuevoPage extends StatefulWidget {
  @override
  _NuevoPageState createState() => _NuevoPageState();
}

class _NuevoPageState extends State<NuevoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _generoController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  File? _image; // Variable para almacenar la imagen seleccionada

  final ImagePicker _picker = ImagePicker(); // Instancia para seleccionar imágenes

  // Aquí inicia la función para seleccionar la imagen
  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // Abre la galería para seleccionar una imagen
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Guarda la imagen que se ha seleccionado
      });
    }
  }

  // Limpia el formulario y la imagen después de que detecta que el envío ha sido exitoso
  void _clearForm() {
    _tituloController.clear();
    _generoController.clear();
    _autorController.clear();
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registro de libro"),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Envolvemos el contenido en SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Text("Ingresa los datos del libro a registrar:"),
                SizedBox(height: 20),
                // Campo para el título del libro
                TextFormField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    prefixIcon: Icon(Icons.book),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el título';
                    }
                    return null;
                  },
                ),
                // Campo para el género del libro
                TextFormField(
                  controller: _generoController,
                  decoration: InputDecoration(
                    labelText: 'Género',
                    prefixIcon: Icon(Icons.live_tv),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el género';
                    }
                    return null;
                  },
                ),
                // Campo para el autor del libro
                TextFormField(
                  controller: _autorController,
                  decoration: InputDecoration(
                    labelText: 'Autor',
                    prefixIcon: Icon(Icons.perm_identity),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el autor';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Botón para seleccionar la imagen
                ElevatedButton(
                  onPressed: _selectImage,
                  child: Text('Selecciona una imagen'),
                ),
                SizedBox(height: 10),
                // Se muestra la imagen seleccionada, de lo contrario muestra un texto de error
                _image != null
                    ? Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Image.file(_image!),
                )
                    : Text('No se ha seleccionado ninguna imagen'),
                SizedBox(height: 10),
                // Botón para enviar el formulario y registrar el libro
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final titulo = _tituloController.text;
                      final genero = _generoController.text;
                      final autor = _autorController.text;

                      if (_image == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Por favor, selecciona una imagen')),
                        );
                        return;
                      }

                      var request = http.MultipartRequest(
                          'POST', Uri.parse('http://192.168.0.78/catalogo/guardar_libro.php'));
                      request.fields['titulo'] = titulo;
                      request.fields['genero'] = genero;
                      request.fields['autor'] = autor;

                      var imageFile = await http.MultipartFile.fromPath(
                          'imagen', _image!.path,
                          contentType: MediaType('image', 'jpg'));
                      request.files.add(imageFile);

                      try {
                        var response = await request.send();
                        if (response.statusCode == 200) {
                          final respStr = await response.stream.bytesToString();
                          print("Respuesta del servidor: $respStr");

                          try {
                            final jsonResponse = jsonDecode(respStr);
                            if (jsonResponse['success']) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(jsonResponse['message'])),
                              );
                              _clearForm();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${jsonResponse['message']}')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al analizar la respuesta JSON: $e')),
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
                      }
                    }
                  },
                  child: Text('Registrar libro'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
