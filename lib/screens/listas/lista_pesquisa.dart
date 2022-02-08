import 'package:flutter/material.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_cliente.dart';

class lista_favoritos extends StatelessWidget {
  final favoritosDao _dao = favoritosDao();
  final _form = GlobalKey<FormState>();

   // Classe que apresenta os dados
  @override
  Widget build(BuildContext context) {
    // Construtor dos Icones
    return Scaffold(
      body: FutureBuilder(
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
