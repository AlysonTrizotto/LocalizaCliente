import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/mapa.dart';

class formularioDashboard extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blueGrey[400],
      ),
      home: dashboard(),
    );
  }
}

class dashboard extends StatelessWidget {
  static const String titulo = 'Dashboard';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
      ),
      body:  Mapas(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.map_rounded),
              label: 'Mapa',
              backgroundColor: Colors.red),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outlined),
            label: 'Favoritos',
            backgroundColor: Colors.yellow,
          )
        ],
      ),
    );
  }
}

