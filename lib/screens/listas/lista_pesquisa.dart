import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:localiza_favoritos/componentes/edit_text_geral.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_cliente.dart';
import 'package:localiza_favoritos/screens/cadastro/editar_favoritos.dart';
import 'package:path/path.dart';

class lista_pesquisa extends StatefulWidget {
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
  final favoritosDao _dao = favoritosDao();
  List<int> id = [];
  // int cod = 0;
  ListaPesquisa(this._pesquisa);
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
              //editaFavoritosState().id_ = cod;
            },
          ),
        ],
      ),
      closeOnScroll: true,
      child: Column(children: [
        ListTile(
          leading: Icon(Icons.people),
          
          title: Text('Nome : ' + _pesquisa.Nome),
          subtitle: Text('Telefone : ' +
              _pesquisa.Telefone +
              '\nEstado : ' +
              _pesquisa.Estado +
              '\nCidade : ' +
              _pesquisa.Cidade +
              '\nEndereco : ' +
              _pesquisa.NumeroEnd.toString()),
        ),
        Text(_pesquisa.id.toString()),
      ]),
    );
  }
}
