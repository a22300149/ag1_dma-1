import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class ActualizarPage extends StatefulWidget {//
  final String idLibro;
  final String tituloActual;
  final String generoActual;
  final String autorActual;
  final String portadaUrlActual;

  ActualizarPage({
    required this.idLibro,
    required this.tituloActual,
    required this.generoActual,
    required this.autorActual,
    required this.portadaUrlActual,
  });

  @override
  _ActualizarPageState createState() => _ActualizarPageState();
}

class _ActualizarPageState extends State<ActualizarPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _generoController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  File? _image; // Variable para almacenar la imagen seleccionada

  final ImagePicker _picker = ImagePicker(); // Instancia para seleccionar imágenes

  @override
  void initState() {
    super.initState();
    // Se inicializamos los campos con los datos actuales del libro
    _tituloController.text = widget.tituloActual;
    _generoController.text = widget.generoActual;
    _autorController.text = widget.autorActual;
  }

  // Aquí inicia la función para seleccionar la imagen
  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // Abre la galería para seleccionar una imagen
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Guarda la imagen que se ha seleccionado
      });
    }
  }

  // Se limpian los datos del formulario y la imagen después de que detecta que el envío ha sido exitoso
  void _clearForm() {
    _tituloController.clear();
    _generoController.clear();
    _autorController.clear();
    setState(() {
      _image = null; // Asegura que la imagen seleccionada se borre
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Actualizar libro"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Text("Actualiza los datos del libro:"),
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
                  child: Text('Selecciona una nueva imagen'),
                ),
                SizedBox(height: 10),
                // Se muestra la imagen seleccionada, de lo contrario muestra la imagen actual
                _image != null
                    ? Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Image.file(_image!),
                )
                    : widget.portadaUrlActual.isNotEmpty
                    ? Image.network(widget.portadaUrlActual)
                    : Text('No se ha seleccionado ninguna imagen'),
                SizedBox(height: 10),
                // Botón para enviar el formulario y actualizar el libro
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final titulo = _tituloController.text;
                      final genero = _generoController.text;
                      final autor = _autorController.text;

                      // Si no se selecciona una nueva imagen, utilizamos la URL actual
                      String portadaUrl = widget.portadaUrlActual;

                      if (_image != null) {
                        var request = http.MultipartRequest(
                            'POST', Uri.parse('http://192.168.0.78/catalogo/actualizar_libro.php'));
                        request.fields['id_libro'] = widget.idLibro;
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
                                _clearForm(); // Limpiar formulario después de éxito
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
                      } else {
                        // Si no se selecciona una nueva imagen, solo actualizamos los datos del libro
                        var response = await http.post(
                          Uri.parse('http://192.168.0.78/catalogo/actualizar_libro.php'),
                          body: {
                            'id_libro': widget.idLibro,
                            'titulo': titulo,
                            'genero': genero,
                            'autor': autor,
                            'portada_url': portadaUrl,
                          },
                        );

                        if (response.statusCode == 200) {
                          final respStr = response.body;
                          print("Respuesta del servidor: $respStr");

                          try {
                            final jsonResponse = jsonDecode(respStr);
                            if (jsonResponse['success']) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(jsonResponse['message'])),
                              );
                              _clearForm(); // Limpiar formulario después de éxito
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
                      }
                    }
                  },
                  child: Text('Actualizar libro'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
