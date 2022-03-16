import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

    return Slidable(
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
           _dao.delete_favoritos(_pesquisa.id_categoria);
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
                /*
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return editaFavoritos(_pesquisa.id, _pesquisa.Nome,
                      _pesquisa.Lat, _pesquisa.Long, _pesquisa.Categoria);
                }));*/
              }),
        ],
      ),
      closeOnScroll: true,
      child: ListTile(
        leading: Icon(Icons.people),
        title: Text('Nome : ' + _pesquisa.nome_categoria),
      ),
    );
  }
}
