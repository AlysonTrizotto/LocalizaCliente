 import 'package:flutter/material.dart';
import 'package:localiza_favoritos/database/DAO/categoria_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_categoria.dart';

class lista_categoria extends StatelessWidget {
  final categoriaDao _dao = categoriaDao();

  static const IconData local_pharmacy =
      IconData(0xe39e, fontFamily: 'MaterialIcons');
  // Classe que apresenta os dados
  @override
  Widget build(BuildContext context) {
    int quantidade = 0;
    if (quantidade == null) {
      ListaVazia();
    }
    // Construtor dos Icones
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: SingleChildScrollView(
          child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height - 263,
                child: FutureBuilder(
                    future: Future.delayed(Duration(seconds: 1))
                        .then((value) => _dao.find_categoria('')),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        final List<registro_categoria> _cadastro =
                            snapshot.data;
                        return ListView.builder(
                          itemCount: _cadastro.length,
                          itemBuilder: (context, indice) {
                            quantidade = indice;

                            final registro_categoria cadastro =
                                _cadastro[indice];

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
            ],
          ),
        ),
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
  final registro_categoria _pesquisa;
  ListaPesquisa(this._pesquisa);
  final categoriaDao _dao = categoriaDao();
  List<int> id = [];
  // int cod = 0;

  @override
  Widget build(BuildContext context) {
    var dist;
    bool visivel = true;

    print(_dao);

    return Card(
      child: ListTile(
        leading: Icon(Icons.people),
        title: Text(_pesquisa.nome_categoria),
      ),
    );
  }
}