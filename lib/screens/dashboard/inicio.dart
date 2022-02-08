import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/mapa.dart';
import 'package:localiza_favoritos/screens/cadastro/formulario_favoritos.dart';
import 'package:localiza_favoritos/screens/dashboard/chama_paginas_pesquisa.dart';
import 'package:localiza_favoritos/screens/listas/lista_empresa.dart';

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

class dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return dashboardState();
  }
}

class dashboardState extends State<dashboard> {
  late String titulo = 'Dashboard';
  //ValueNotifier<int> _selectedIndex = ValueNotifier(0);
  int _selectedIndex = 0;

  final List<Widget> _telas = [
    NewPageScreenMapas(),
    NewPageScreenPesquisa(),
    NewPageScreenFormCad(),
  ];

  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(        
        body: _telas[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.map_rounded),
              label: 'Mapa',
              backgroundColor: Color(0xFF101427),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              label: 'Pesquisar',
              backgroundColor: Color(0xFF101427),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outlined),
              label: 'Favoritos',
              backgroundColor: Color(0xFF101427),
            )
          ],
          selectedItemColor: Colors.white,
          selectedIconTheme: IconThemeData(color: Colors.white, size: 40),
          selectedFontSize: 20,
          unselectedIconTheme: IconThemeData(
            color: Colors.deepOrangeAccent,
          ),
          unselectedItemColor: Colors.deepOrangeAccent,
          type: BottomNavigationBarType.shifting,
        ));
  }
}

class NewPageScreenMapas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Mapas();
  }
}

class NewPageScreenPesquisa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return chama_paginas_pesquisa();
  }
}

class NewPageScreenFormCad extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FormularioCadastro();
  }
}
