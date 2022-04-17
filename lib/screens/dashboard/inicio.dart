import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/mapa.dart';
import 'package:localiza_favoritos/screens/cadastro/formulario_categoria.dart';
import 'package:localiza_favoritos/screens/dashboard/chama_paginas_pesquisa.dart';

class Dashboard extends StatefulWidget {
  final int index;
  const Dashboard(this.index, {Key? key}) : super(key: key);
  static String tag = 'Dashboard';
  @override
  State<StatefulWidget> createState() {
    return DashboardState(index);
  }
}

class DashboardState extends State<Dashboard> {
  final int index;
  DashboardState(this.index);

  late int _selectedindex = index;
  late String titulo = 'Dashboard';

  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  void onItemTapped(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _telas = [
      const NewPageScreenMapas(),
      const NewPageScreenPesquisa(),
      const NewPageScreenFormCad(),
    ];
    return Scaffold(
        body: _telas[_selectedindex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedindex,
          onTap: onItemTapped,
          items: const [
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
          selectedIconTheme: const IconThemeData(color: Colors.white, size: 40),
          selectedFontSize: 20,
          unselectedIconTheme: const IconThemeData(
            color: Colors.deepOrangeAccent,
          ),
          unselectedItemColor: Colors.deepOrangeAccent,
          type: BottomNavigationBarType.shifting,
        ));
  }
}

class NewPageScreenMapas extends StatelessWidget {
  const NewPageScreenMapas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Mapa();
  }
}

class NewPageScreenPesquisa extends StatelessWidget {
  const NewPageScreenPesquisa({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const chamaPaginasPesquisa();
  }
}

class NewPageScreenFormCad extends StatelessWidget {
  const NewPageScreenFormCad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormularioCategoria();
  }
}
