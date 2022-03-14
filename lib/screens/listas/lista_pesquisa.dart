/*import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:localiza_favoritos/componentes/edit_text_geral.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_cliente.dart';
import 'package:localiza_favoritos/screens/cadastro/editar_favoritos.dart';
import 'package:localiza_favoritos/screens/dashboard/chama_paginas_pesquisa.dart';
import 'package:localiza_favoritos/screens/dashboard/inicio.dart';
import 'package:path/path.dart';

class lista_pesquisa extends StatefulWidget {
  static String tag = 'ListaPesquisa';
  @override
  State<StatefulWidget> createState() {
    return lista_pesquisaState();
  }
}

class lista_pesquisaState extends State<lista_pesquisa> {
  String _itemSelecionado = 'Cliente';
  final favoritosDao _dao = favoritosDao();
  final _form = GlobalKey<FormState>();
  late final ValueChanged<String>? onChanged;
  late String pesquisa = '';
  final _globalKey = GlobalKey<ScaffoldMessengerState>();
  late TextEditingController controladorCampoNome = TextEditingController();
  late TextEditingController controladorCampoTelefone = TextEditingController();
  late TextEditingController controladorCampoEstado = TextEditingController();
  late TextEditingController controladorCampoCidade = TextEditingController();
  late TextEditingController controladorCampoRua = TextEditingController();
  late TextEditingController controladorCampoNum = TextEditingController();
  late TextEditingController controladorCampoCategoria =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    final TextEditingController controladorCampoPesquisa =
        TextEditingController();
    int quantidade = 0;
    if (quantidade == null) {
      ListaVazia();
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          SizedBox(
            child: TextField(
                decoration: InputDecoration(hintText: 'Pesquisa'),
                onChanged: (String value) {
                  setState(() {
                    pesquisa = value;
                  });
                }),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 263,
            child: FutureBuilder(
                future: Future.delayed(Duration(seconds: 1))
                    .then((value) => _dao.find_favoritos(pesquisa)),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final List<redistro_favoritos> _cadastro = snapshot.data;
                    return ListView.builder(
                      itemCount: _cadastro.length,
                      itemBuilder: (context, indice) {
                        quantidade = indice;

                        final redistro_favoritos cadastro = _cadastro[indice];

                        return ListaPesquisa(cadastro);
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
      ),
    );
  }
}

class ListaVazia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}

class ListaPesquisa extends StatelessWidget {
  final redistro_favoritos _pesquisa;
  ListaPesquisa(this._pesquisa);

  final favoritosDao _dao = favoritosDao();
  List<int> id = [];
  // int cod = 0;

  @override
  Widget build(BuildContext context) {
    // cod = id[0].toInt();
    return Slidable(
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              label: 'Delete',
              backgroundColor: Colors.red,
              icon: Icons.delete,
              onPressed: (context) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Cadastro excluído com sucesso!'),
                    duration: const Duration(milliseconds: 1500),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                _dao.delete_favoritos(_pesquisa.id);
              },
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
                label: 'Editar',
                backgroundColor: Colors.blue,
                icon: Icons.archive,
                onPressed: (context) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return editaFavoritos(_pesquisa.id, _pesquisa.Nome,
                        _pesquisa.Lat, _pesquisa.Long, _pesquisa.Categoria);
                  }));
                }),
          ],
        ),
        closeOnScroll: true,
        child: Column(children: [
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Nome : ' + _pesquisa.Nome),
            subtitle: Text('Telefone : ' +
                _pesquisa.Lat +
                '\nEstado : ' +
                _pesquisa.Long +
                '\nCidade : ' +
                _pesquisa.Categoria),
          )
        ]));
  }
}*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:localiza_favoritos/componentes/edit_text_geral.dart';
import 'package:localiza_favoritos/componentes/nethort_help.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_cliente.dart';
import 'package:localiza_favoritos/screens/cadastro/editar_favoritos.dart';
import 'package:localiza_favoritos/screens/dashboard/chama_paginas_pesquisa.dart';
import 'package:localiza_favoritos/screens/dashboard/inicio.dart';
import 'package:path/path.dart';

class lista_pesquisa extends StatefulWidget {
  static String tag = 'ListaPesquisa';
  @override
  State<StatefulWidget> createState() {
    return lista_pesquisaState();
  }
}

class lista_pesquisaState extends State<lista_pesquisa> {
  String _itemSelecionado = 'Cliente';
  final favoritosDao _dao = favoritosDao();

  late String pesquisa = '';

  @override
  Widget build(BuildContext context) {
    final TextEditingController controladorCampoPesquisa =
        TextEditingController();
    int quantidade = 0;
    if (quantidade == null) {
      ListaVazia();
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          SizedBox(
            child: TextField(
                decoration: InputDecoration(hintText: 'Pesquisa'),
                onChanged: (String value) {
                  setState(() {
                    pesquisa = value;
                  });
                }),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 263,
            child: FutureBuilder(
                future: Future.delayed(Duration(seconds: 1))
                    .then((value) => _dao.find_favoritos(pesquisa)),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final List<redistro_favoritos> _cadastro = snapshot.data;
                    return ListView.builder(
                      itemCount: _cadastro.length,
                      itemBuilder: (context, indice) {
                        quantidade = indice;
                        final redistro_favoritos cadastro = _cadastro[indice];
                        return ListaPesquisa(cadastro);
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
      ),
    );
  }
}

class ListaVazia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}

class ListaPesquisa extends StatelessWidget {
  final redistro_favoritos _pesquisa;
  ListaPesquisa(this._pesquisa);
  final favoritosDao _dao = favoritosDao();
  List<int> id = [];
  // int cod = 0;
  @override
  Widget build(BuildContext context) {
    var dist;
    bool visivel = true;
    return Visibility(
      visible: visivel,
      child: Slidable(
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                label: 'Delete',
                backgroundColor: Colors.red,
                icon: Icons.delete,
                onPressed: (context) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Cadastro excluído com sucesso!'),
                      duration: const Duration(milliseconds: 1500),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  _dao.delete_favoritos(_pesquisa.id);
                  visivel = false;
                },
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                  label: 'Editar',
                  backgroundColor: Colors.blue,
                  icon: Icons.archive,
                  onPressed: (context) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return editaFavoritos(_pesquisa.id, _pesquisa.Nome,
                          _pesquisa.Lat, _pesquisa.Long, _pesquisa.Categoria);
                    }));
                  }),
            ],
          ),
          closeOnScroll: true,
          child: Column(children: [
            FutureBuilder(
              future: Future.delayed(Duration(seconds: 1))
                  .then((value) => distancia(_pesquisa.Lat, _pesquisa.Long)),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  var distanciaFuture = snapshot.data;
                  return ListTile(
                      leading: Icon(Icons.people),
                      title: Text('Nome : ' + _pesquisa.Nome),
                      subtitle: Text('Distância: ' + distanciaFuture));
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
              },
            ),
          ])),
    );
  }
}

Future distancia(String Lat, String Long) async {
  String distanciaString = '';
  double distanciaKm = 0.0;
  double distancia_convertida = 0.0;
  double distanciaMetros = 
  await pegaDistanciaDOisPontos(double.parse(Lat), double.parse(Long));

  if (distanciaMetros >= 1000) {
    distanciaKm = distanciaMetros / 1000;
    distancia_convertida = double.parse(distanciaKm.toStringAsFixed(2));
    distanciaString = 'Distância: ${distancia_convertida.toDouble()} KM';
    print('++++++++distancia+++++++');
    print(distanciaString);
  } else {
    num distancia_convertida =
        num.parse(distanciaMetros.toStringAsPrecision(1));
    distanciaString = 'Distância: ${distanciaMetros.toInt()} Metros';
    print('++++++++distancia+++++++');
    print(distanciaMetros);
  }
  await Future.delayed(Duration(seconds: 1));
  return distanciaString;
}
