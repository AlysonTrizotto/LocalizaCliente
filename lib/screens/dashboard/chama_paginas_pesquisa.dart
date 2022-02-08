import 'package:flutter/material.dart';
import 'package:localiza_favoritos/screens/listas/lista_empresa.dart';

class chama_paginas_pesquisa extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return chama_paginas_pesquisaState();
  }
}

class chama_paginas_pesquisaState extends State<chama_paginas_pesquisa> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: AppBar(
        bottom: TabBar(
            indicatorColor: Colors.deepOrangeAccent,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(
                text: 'Categoria',
              ),
              Tab(
              text: 'Pesquisar',
              ),
              Tab(
                text: 'Favoritos',
              )
            ],
          ),
        title: Text('Pesquisa'),
      ),
      body: TabBarView(
        children: [
          lista_favoritos(),
          lista_favoritos(),
          lista_favoritos(),
        ],
      ),
    ),
  );
}
}