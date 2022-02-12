import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/edit_text_geral.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_cliente.dart';
import 'package:localiza_favoritos/screens/dashboard/inicio.dart';

class editaFavoritos extends StatefulWidget {
  final int id;
  editaFavoritos(this.id);
  @override
  State<StatefulWidget> createState() {
    return editaFavoritosState();
  }
}

class editaFavoritosState extends State<editaFavoritos> {
  final double tamanhp_fonte = 16.0;
  String campoVazio = '';
  String itemInicial = "Cliente";
  int id_ = 0;

  late TextEditingController controladorCampoNome = TextEditingController();
  late TextEditingController controladorCampoTelefone = TextEditingController();
  late TextEditingController controladorCampoEstado = TextEditingController();
  late TextEditingController controladorCampoCidade = TextEditingController();
  late TextEditingController controladorCampoRua = TextEditingController();
  late TextEditingController controladorCampoNum = TextEditingController();
  late TextEditingController controladorCampoCategoria =
      TextEditingController();
  String _itemSelecionado = 'Cliente';

  String get Categoria => itemInicial;

  int get id => id_;

  String get Cidade => controladorCampoCidade.text;

  String get Estado => controladorCampoTelefone.text;

  String get Nome => controladorCampoNome.text;

  String get Rua => controladorCampoRua.text;

  String get Telefone => controladorCampoTelefone.text;
  int numero = 0;
  int get numParse => numero;
 
  void initState() {
    super.initState();
  }

  void disponse() {
    super.dispose();
  }

  List<String> categoriaLista = [
    'Cliente',
    'Hotel',
    'Posto de combustível',
    'Restaurante',
    'Mercado',
    'Hospital',
    'Farmácia',
  ];

  @override
  Widget build(BuildContext context) {
     
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              edit_text_geral(controladorCampoNome, 'Nome', 'Empresa',
                  Icons.apartment_rounded),
              TextField(
                controller: controladorCampoTelefone,
                // ignore: prefer_const_constructors
                style: TextStyle(
                  fontSize: tamanhp_fonte,
                ),
                // ignore: prefer_const_constructors
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  hintText: "(DDD) 9 0000-0000",
                  icon: Icon(Icons.phone_rounded),
                ),
                keyboardType: TextInputType.phone,
              ),
              edit_text_geral(controladorCampoEstado, 'Estado', "Paraná",
                  Icons.add_location_alt_outlined),
              edit_text_geral(controladorCampoCidade, 'Cidade', 'Curitiba',
                  Icons.location_city_rounded),
              edit_text_geral(controladorCampoRua, 'Rua', "Rui Barbosa",
                  Icons.add_road_rounded),
              TextField(
                controller: controladorCampoNum,
                style: TextStyle(
                  fontSize: tamanhp_fonte,
                ),
                // ignore: prefer_const_constructors
                decoration: InputDecoration(
                  labelText: 'Número',
                  hintText: "123",
                  // ignore: prefer_const_constructors
                  icon: Icon(Icons.local_convenience_store_rounded),
                ),
                keyboardType: TextInputType.number,
              ),
              
              DropdownButtonFormField(
                onChanged: (value) {
                  itemInicial = value as String;
                  setState(() {
                    
                  });
                },
                value: itemInicial,
                items: categoriaLista.map((items) {
                  return DropdownMenuItem(value: items, child: Text(items));
                }).toList(),
              ),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  child: Text('Salvar'),
                  onPressed: () {
                    if ((controladorCampoNome.text != '') &&
                        (controladorCampoTelefone.text != '') &&
                        (controladorCampoEstado.text != '') &&
                        (controladorCampoRua.text != '') &&
                        (controladorCampoCidade.text != '') &&
                        (controladorCampoNum.text != '') &&
                        (itemInicial != '')) {
                      _criaCadastro(
                          controladorCampoNome.text,
                          controladorCampoTelefone.text,
                          controladorCampoEstado.text,
                          controladorCampoRua.text,
                          controladorCampoNum.text,
                          int.parse(controladorCampoNum.text),
                          itemInicial,
                          context);

                      controladorCampoNome.clear();
                      controladorCampoTelefone.clear();
                      controladorCampoEstado.clear();
                      controladorCampoCidade.clear();
                      controladorCampoRua.clear();
                      controladorCampoNum.clear();
                      controladorCampoCategoria.clear();
                    } else {
                      campoVazio = '';
                      if (controladorCampoNome.text != null) {
                        campoVazio = ' Nome\n';
                      }
                      if (controladorCampoTelefone.text != null) {
                        campoVazio = campoVazio + ' Telefone\n';
                      }
                      if (controladorCampoEstado.text != null) {
                        campoVazio = campoVazio + ' Estado\n';
                      }
                      if (controladorCampoRua.text != null) {
                        campoVazio = campoVazio + ' Rua\n';
                      }
                      if (controladorCampoCidade.text != null) {
                        campoVazio = campoVazio + ' Cidade\n';
                      }
                      if (controladorCampoNum.text != null) {
                        campoVazio = campoVazio + ' Número\n';
                      }
                      if (itemInicial != null) {
                        campoVazio = campoVazio + ' Categoria\n';
                      }

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // retorna um objeto do tipo Dialog
                          return AlertDialog(
                            title: new Text("Não é permitido campos vazios"),
                            content:
                                new Text("Preencha os campos: \n" + campoVazio),
                            actions: <Widget>[
                              // define os botões na base do dialogo
                              new FlatButton(
                                child: new Text("Fechar"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void preenche(int id, String Nome, String Telefone, String Estado,
      String Cidade, String Rua, int numParse, String Categoria) {
    final carrega = preenche(this.id, this.Nome, this.Telefone, this.Estado,
        this.Cidade, this.Rua, this.numParse, this.Categoria);
  }
}

mixin Cidade {}

void _criaCadastro(String Nome, String Telefone, String Estado, String Cidade,
    String Rua, int numParse, String Categoria, BuildContext context) {
  final favoritosDao _dao = favoritosDao();

  final CadastroCriado = redistro_favoritos(
      0, Nome, Telefone, Estado, Cidade, Rua, numParse, Categoria);
  _dao
      .editar_favoritos(
          0, Nome, Telefone, Estado, Cidade, Rua, numParse, Categoria)
      .then((_) => dashboard());
}
