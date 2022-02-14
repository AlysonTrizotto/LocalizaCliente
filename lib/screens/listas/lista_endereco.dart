import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:localiza_favoritos/models/organiza_busca.dart';
import 'package:osm_nominatim/osm_nominatim.dart';

import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/mapa.dart';

class lista_favoritos extends StatefulWidget {
  static String tag = 'ListaPesquisa';
  @override
  State<StatefulWidget> createState() {
    return lista_favoritosState();
  }
}

class lista_favoritosState extends State<lista_favoritos> {
  final Mapas mapa = Mapas();

  final _form = GlobalKey<FormState>();

  late final ValueChanged<String>? onChanged;
  late String pesquisa = '';

  // Classe que apresenta os dados
  @override
  Widget build(BuildContext context) {
    // Construtor dos Icones
    return SingleChildScrollView(
      child: Column(children: <Widget>[
        SizedBox(
          child: TextField(
              decoration: InputDecoration(hintText: 'Pesquisa'),
              onChanged: (String value) {
                setState(() {
                  pesquisa = value;
                  pesquisaEndereco(pesquisa);
                });
              }),
        ),
        Container(),
      ]),
    );
  }
}

Future pesquisaEndereco(String endereco) async {
  List<SearchInfo> suggestions = await addressSuggestion(endereco);
  print(suggestions.toList());
}
