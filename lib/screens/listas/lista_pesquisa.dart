import 'package:flutter/material.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_cliente.dart';

class lista_pesquisa extends StatelessWidget {
  final favoritosDao _dao = favoritosDao();
  final _form = GlobalKey<FormState>();

   // Classe que apresenta os dados
  @override
  Widget build(BuildContext context) {
     final TextEditingController controladorCampoPesquisa =
        TextEditingController();
    // Construtor dos Icones
    return Scaffold(
      body:   Stack(children: <Widget>[
            Card(
              color: Colors.blueGrey[50],
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white70, width: 1),
                borderRadius: BorderRadius.circular(30),
              ),
              margin: EdgeInsets.all(10.0),
              child: SizedBox(
                width: double.maxFinite,
                child: TextField(
                  controller: controladorCampoPesquisa,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Endereço',
                    hintText: 'Rua XV',
                    prefixIcon: Icon(Icons.search_rounded),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 3, color: Color(0xFF101427)),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
            ),
      /*
         FutureBuilder(
          future: Future.delayed(Duration(seconds: 1))
              .then((value) => _dao.findAll_favoritos()),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final List<redistro_favoritos> _cadastro = snapshot.data;
              return ListView.builder(
                itemCount: _cadastro.length,
                itemBuilder: (context, indice) {
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
         */
      ]),
    );
  }
}

class ListaPesquisa extends StatelessWidget {
  final redistro_favoritos
      _pesquisa; // Cria uma instâcia da lista de pesqusia para apresentar, armazena os dados em uma única classe

  // ignore: prefer_const_constructors_in_immutables, use_key_in_widget_constructors
  ListaPesquisa(
      this._pesquisa); // construtor da classe que armazena os dados da pesquisa

  @override
  Widget build(BuildContext context) {
    return Card(
      // Retorna os ícones construídos em card
      child: ListTile(
        //Lista apresentação interna do card
        leading: Icon(Icons.people), // ícone
        title: Text('Nome : ' + _pesquisa.Nome), // Título
        subtitle: Text('Telefone : ' + // Subtitulo fracionado
            _pesquisa.Telefone +
            '\nEstado : ' +
            _pesquisa.Estado +
            '\nCidade : ' +
            _pesquisa.Cidade +
            '\nEndereco : ' +
            _pesquisa.NumeroEnd.toString()),
      ),
    );
  }
}
