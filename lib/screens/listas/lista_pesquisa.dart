import 'package:flutter/material.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_cliente.dart';

class lista_pesquisa extends StatelessWidget {
  final favoritosDao _dao = favoritosDao();
  final _form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final TextEditingController controladorCampoPesquisa =
        TextEditingController();
   return Scaffold( body: 
    SingleChildScrollView(child: Column(
      children: <Widget>[
        SizedBox(
          child: TextFormField(
            decoration: InputDecoration(hintText: 'Pesquisa'),
          ),
        ),
       Container(height: MediaQuery.of(context).size.height - 263, 
          child: 
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
        
        
        ),
      
      ]),)
    );

  }
}

class ListaPesquisa extends StatelessWidget {
  final redistro_favoritos
      _pesquisa; 
  ListaPesquisa(
      this._pesquisa); 
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.people),
        trailing: GestureDetector(
          child: Icon(Icons.edit),
          onTap: () => print('Deletar'),),
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
    );
  }
}
