import 'package:flutter/material.dart';
import 'package:localiza_favoritos/screens/listas/lista_categoria.dart';
import 'package:localiza_favoritos/screens/listas/lista_pesquisa.dart';

class chamaPaginasPesquisa extends StatefulWidget {
  const chamaPaginasPesquisa({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return chamaPaginasPesquisaState();
  }
}

class chamaPaginasPesquisaState extends State<chamaPaginasPesquisa> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
  length: 2,
  child: Scaffold(
    appBar: AppBar(
        bottom: const TabBar(
            indicatorColor: Colors.deepOrangeAccent,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(
                text: 'Categoria',
              ),
               Tab(
                text: 'Favoritos',
              )
            ],
          ),
        title: const Text('Pesquisa'),
      ),
      body: TabBarView(
        children: [
          lista_categoria(),   
          lista_pesquisa(),
        ],
      ),
    ),
  );
}
}