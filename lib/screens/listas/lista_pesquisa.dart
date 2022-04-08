import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:localiza_favoritos/componentes/loading.dart';
import 'package:localiza_favoritos/componentes/nethort_help.dart';
import 'package:localiza_favoritos/database/DAO/categoria_dao.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_categoria.dart';
import 'package:localiza_favoritos/models/pesquisa_cliente.dart';
import 'package:localiza_favoritos/screens/cadastro/editar_favoritos.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class lista_pesquisa extends StatefulWidget {
  static String tag = 'ListaPesquisa';
  @override
  State<StatefulWidget> createState() {
    return lista_pesquisaState();
  }
}

class lista_pesquisaState extends State<lista_pesquisa> {
  final favoritosDao _dao = favoritosDao();

  final List<redistro_favoritos> _cadastro = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
      

  late String pesquisa = '';

  void restartApp() {
    setState(() {});
  }

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
                    return  loadingScreen(context, 'Post favor, aguarde');
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

  bool visivel = true;

  @override
  Widget build(BuildContext context) {
    var dist;
    return Visibility(
      //visible: visivel,
      child: Slidable(
          key: const ValueKey(0),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            dismissible: DismissiblePane(onDismissed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cadastro excluído com sucesso!'),
                  duration: const Duration(milliseconds: 1500),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _dao.delete_favoritos(_pesquisa.id);
            }),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                label: 'Delete',
                backgroundColor: Colors.red,
                icon: Icons.delete,
                onPressed: (context) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Arraste para excluir!'),
                      duration: const Duration(milliseconds: 1500),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
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
                      return editaFavoritos(
                          _pesquisa.id,
                          _pesquisa.Nome,
                          _pesquisa.Lat,
                          _pesquisa.Long,
                          _pesquisa.id_categoria);
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
                  return  loadingScreen(context, 'Mais um instante');
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
  } else {
    num distancia_convertida =
        num.parse(distanciaMetros.toStringAsPrecision(1));
    distanciaString = 'Distância: ${distanciaMetros.toInt()} Metros';
  }
  await Future.delayed(Duration(seconds: 1));
  return distanciaString;
}
