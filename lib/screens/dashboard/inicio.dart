import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:localiza_favoritos/componentes/mapa.dart';
import 'package:localiza_favoritos/screens/cadastro/formulario_categoria.dart';
import 'package:localiza_favoritos/screens/cadastro/formulario_favoritos.dart';
import 'package:localiza_favoritos/screens/dashboard/chama_paginas_pesquisa.dart';

class dashboard extends StatefulWidget {
  final int Index;
  dashboard(this.Index);
  static String tag = 'Dashboard';
  @override
  State<StatefulWidget> createState() {
    return dashboardState(Index);
  }
}

class dashboardState extends State<dashboard> {
  final int Index;
  dashboardState(this.Index);

  late int _selectedIndex = Index;
  late String titulo = 'Dashboard';

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
    final List<Widget> _telas = [
      NewPageScreenMapas(),
      NewPageScreenPesquisa(),
      NewPageScreenFormCad(),
    ];
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
              label: 'Categoria',
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
    return mapa();
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
    return FormularioCategoria();
  }
}
