import 'dart:convert'; // Importa la librería para manejar JSON.
import 'package:flutter/material.dart'; // Importa Flutter para usar componentes visuales.
import 'package:flutter/widgets.dart'; // Importa Flutter para widgets básicos.
import 'package:http/http.dart' as http; // Importa la librería http para hacer solicitudes web.
import 'package:image_picker/image_picker.dart'; // Importa la librería para seleccionar imágenes desde la galería.
import 'dart:io'; // Importa la librería para trabajar con archivos.
import 'package:path/path.dart'; // Importa la librería para trabajar con rutas de archivos.
import 'package:http_parser/http_parser.dart'; // Importa la librería para establecer tipos de contenido en solicitudes HTTP.

class NuevoPage extends StatefulWidget {
  @override
  _NuevoPageState createState() => _NuevoPageState(); // Crea el estado de la página
}

class _NuevoPageState extends State<NuevoPage> {
  final _formKey = GlobalKey<FormState>(); // Clave para validar el formulario
  final TextEditingController _tituloController = TextEditingController(); // Controlador para el campo de título
  final TextEditingController _generoController = TextEditingController(); // Controlador para el campo de género
  final TextEditingController _autorController = TextEditingController(); // Controlador para el campo de autor
  File? _image; // Variable para almacenar la imagen seleccionada

  final ImagePicker _picker = ImagePicker(); // Instancia de ImagePicker para seleccionar imágenes

  // Función para seleccionar la imagen desde la galería
  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // Abre la galería para seleccionar una imagen
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Guarda la imagen seleccionada
      });
    }
  }

  // Función para limpiar el formulario y la imagen después de un envío exitoso
  void _clearForm() {
    _tituloController.clear(); // Limpia el campo de título
    _generoController.clear(); // Limpia el campo de género
    _autorController.clear(); // Limpia el campo de autor
    setState(() {
      _image = null; // Borra la imagen seleccionada
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registro de libro"), // Título de la barra de navegación
        centerTitle: true, // Centra el título
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Agrega un padding de 16 píxeles
        child: Form(
          key: _formKey, // Asocia el formulario con la clave para validarlo
          child: Column(
            children: <Widget>[
              // Campo para el título del libro
              TextFormField(
                controller: _tituloController, // Asocia el controlador con el campo
                decoration: InputDecoration(labelText: 'Título'), // Agrega una etiqueta
                validator: (value) {
                  if (value == null || value.isEmpty) { // Valida que el campo no esté vacío
                    return 'Por favor ingrese el título'; // Mensaje de error si está vacío
                  }
                  return null; // Si está bien, no hay mensaje de error
                },
              ),
              // Campo para el género del libro
              TextFormField(
                controller: _generoController, // Asocia el controlador con el campo
                decoration: InputDecoration(labelText: 'Género'), // Agrega una etiqueta
                validator: (value) {
                  if (value == null || value.isEmpty) { // Valida que el campo no esté vacío
                    return 'Por favor ingrese el género'; // Mensaje de error si está vacío
                  }
                  return null; // Si está bien, no hay mensaje de error
                },
              ),
              // Campo para el autor del libro
              TextFormField(
                controller: _autorController, // Asocia el controlador con el campo
                decoration: InputDecoration(labelText: 'Autor'), // Agrega una etiqueta
                validator: (value) {
                  if (value == null || value.isEmpty) { // Valida que el campo no esté vacío
                    return 'Por favor ingrese el autor'; // Mensaje de error si está vacío
                  }
                  return null; // Si está bien, no hay mensaje de error
                },
              ),
              SizedBox(height: 10), // Espacio entre los campos
              // Botón para seleccionar la imagen
              ElevatedButton(
                onPressed: _selectImage, // Llama a la función _selectImage cuando se presiona
                child: Text('Seleccionar Imagen'), // Texto del botón
              ),
              SizedBox(height: 10), // Espacio entre el botón y la imagen

              // Muestra la imagen seleccionada si existe, de lo contrario muestra un texto
              _image != null
                  ? Image.file(_image!) // Muestra la imagen seleccionada
                  : Text('No se ha seleccionado ninguna imagen'), // Mensaje si no se seleccionó una imagen
              SizedBox(height: 20), // Espacio adicional

              // Botón para enviar el formulario y registrar el libro
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) { // Valida que el formulario esté correcto
                    // Obtiene los datos del formulario
                    final titulo = _tituloController.text;
                    final genero = _generoController.text;
                    final autor = _autorController.text;

                    // Verifica si se ha seleccionado una imagen
                    if (_image == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Por favor, selecciona una imagen')), // Muestra mensaje si no se seleccionó imagen
                      );
                      return;
                    }

                    // Crea una solicitud multipart para enviar los datos y la imagen
                    var request = http.MultipartRequest(
                        'POST', Uri.parse('http://192.168.0.78/catalogo/guardar_libro.php')
                    );
                    request.fields['titulo'] = titulo; // Añade el título a la solicitud
                    request.fields['genero'] = genero; // Añade el género a la solicitud
                    request.fields['autor'] = autor; // Añade el autor a la solicitud

                    // Añade la imagen a la solicitud multipart
                    var imageFile = await http.MultipartFile.fromPath(
                        'imagen', _image!.path,
                        contentType: MediaType('image', 'jpg') // Ajusta el tipo de contenido según el formato
                    );
                    request.files.add(imageFile); // Añade el archivo de imagen a la solicitud

                    // Envia la solicitud al servidor
                    try {
                      var response = await request.send();

                      // Maneja la respuesta del servidor
                      if (response.statusCode == 200) {
                        final respStr = await response.stream.bytesToString(); // Convierte la respuesta en texto
                        print("Respuesta del servidor: $respStr"); // Imprime la respuesta del servidor en consola

                        try {
                          final jsonResponse = jsonDecode(respStr); // Decodifica la respuesta JSON
                          if (jsonResponse['success']) { // Si la respuesta es exitosa
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(jsonResponse['message'])), // Muestra el mensaje de éxito
                            );
                            _clearForm();  // Limpia el formulario e imagen
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${jsonResponse['message']}')), // Muestra el error
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al analizar la respuesta JSON: $e')), // Maneja errores al analizar JSON
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error en el servidor. Código: ${response.statusCode}')), // Error de servidor
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al conectar con el servidor: $e')), // Error de conexión
                      );
                    }
                  }
                },
                child: Text('Registrar Libro'), // Texto del botón para registrar el libro
              ),
            ],
          ),
        ),
      ),
    );
  }
}
