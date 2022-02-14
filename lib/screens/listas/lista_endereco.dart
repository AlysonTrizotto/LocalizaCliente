import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:localiza_favoritos/screens/dashboard/inicio.dart';
import 'package:localiza_favoritos/screens/dashboard/inicio.dart';
import 'package:localiza_favoritos/screens/dashboard/inicio.dart';

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
  final Mapas mapa = Mapas(47.4358055, 8.4737324);

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
                  //pesquisaEndereco(pesquisa);
                });
              }),
        ),
        Container(
          height: MediaQuery.of(context).size.height - 263,
          child: FutureBuilder(
              future: Future.delayed(Duration(seconds: 1))
                  .then((value) => pesquisaEndereco(pesquisa)),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final List<SearchInfo> _retorno = snapshot.data;
                  return ListView.builder(
                    itemCount: _retorno.length,
                    itemBuilder: (context, indice) {
                      final String _endereco =
                          _retorno[indice].address.toString();
                      final double lat = _retorno[indice].point!.latitude;
                      final double long = _retorno[indice].point!.longitude;
                      return CardEndereco(_endereco, lat, long);
                    },
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        Text('Carregando favoritos'),
                      ],
                    ),
                  );
                }
              }),
        ),
      ]),
    );
  }
}

Future pesquisaEndereco(String endereco) async {
  int i = 0;
  List<SearchInfo> suggestions = await addressSuggestion(endereco);
  i = suggestions.length;
  return suggestions.toList();
}

class CardEndereco extends StatelessWidget {
  final String? end;
  final double? lat;
  final double? long;
  CardEndereco(this.end, this.lat, this.long);
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Mapas(lat!, long!);
              NewPageScreenMapas();
            },
            child: Card(
              child: ListTile(
                leading: Icon(Icons.location_on_outlined),
                title: Text(end!),
                subtitle: Text('Latitude: ' +
                    lat.toString() +
                    '\nLongitude: ' +
                    long.toString()),
              ),
            ),
          ),
        ]);
  }
}
