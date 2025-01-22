import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'nuevo_reg.dart';
import 'busqueda.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';

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
      routes: {//Rutas para navegar entre pantallas
        'main/': (context) => HomePage(),
        '/nuevo_reg': (context) => NuevoPage(),
        '/busqueda': (context) => BuscarPage(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Catalogo de libros"),
        centerTitle: true,
      ),
      body: Center(
        child: Center(
          child: Card(
            child: SizedBox(

            ),
          ),
        ),
      ),
      drawer: Drawer(
        //Aquí comienza el menú hamburguesa
        child: new ListView(
          children: <Widget>[
            ListTile(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  _scaffoldKey.currentState?.closeDrawer(); //Cerrar menú hamburguesa
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
                Navigator.pushNamed(context, '/nuevo_reg');
              },
            ),
            ListTile(
              title: Text("Búsqueda"),
              leading: Icon(Icons.search),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/busqueda');
              },
            )
          ],
        ),
      ),
    );
  }
}
