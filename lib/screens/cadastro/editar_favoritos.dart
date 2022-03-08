import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/edit_text_geral.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_cliente.dart';
import 'package:localiza_favoritos/screens/dashboard/inicio.dart';

class editaFavoritos extends StatefulWidget {
  final int id;
  final String nome;
  final String lat;
  final String long;
  final String categoria;
  editaFavoritos(this.id, this.nome, this.lat, this.long, this.categoria);
  @override
  State<StatefulWidget> createState() {
    return editaFavoritosState(
        id, nome, lat, long, categoria);
  }
}

class editaFavoritosState extends State<editaFavoritos> {
   final int id;
  final String nome;
  final String lat;
  final String long;
  final String categoria;
  editaFavoritosState(this.id, this.nome, this.lat, this.long, this.categoria);

  final double tamanhp_fonte = 16.0;
  String campoVazio = '';
  String itemInicial = "Cliente";

  late TextEditingController controladorCampoNome = TextEditingController();
  late TextEditingController controladorCampoLat = TextEditingController();
  late TextEditingController controladorCampoLong = TextEditingController();
  late TextEditingController controladorCampoCategoria =
      TextEditingController();

  String _itemSelecionado = 'Cliente';

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
    controladorCampoNome.text = nome;
    controladorCampoLat.text = lat;
    controladorCampoLong.text = long;
    _itemSelecionado = categoria;
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              edit_text_geral(controladorCampoNome, 'Nome', 'Empresa',
                  Icons.apartment_rounded),
              
              edit_text_geral(controladorCampoLat, 'Estado', "Paraná",
                  Icons.add_location_alt_outlined),
              edit_text_geral(controladorCampoLong, 'Cidade', 'Curitiba',
                  Icons.location_city_rounded),
              edit_text_geral(controladorCampoCategoria, 'Rua', "Rui Barbosa",
                  Icons.add_road_rounded),
              DropdownButtonFormField(
                onChanged: (value) {
                  itemInicial = value as String;
                  setState(() {});
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
                        (controladorCampoLat.text != '') &&
                        (controladorCampoLong.text != '') &&
                        (controladorCampoCategoria.text != '') &&
                        (itemInicial != '')) {
                      _criaCadastro(
                          id,
                          controladorCampoNome.text,
                          controladorCampoLat.text,
                          controladorCampoLong.text,
                          controladorCampoCategoria.text,
                          context);

                      controladorCampoNome.clear();
                      controladorCampoLat.clear();
                      controladorCampoLong.clear();
                      controladorCampoCategoria.clear();
                      controladorCampoCategoria.clear();
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar( 
                          content: const Text('Cadastro atualizado com sucesso!'),
                          duration: const Duration(milliseconds: 1500),
                          behavior: SnackBarBehavior.floating,
                        ),);
                    } else {
                      campoVazio = '';
                      if (controladorCampoNome.text != null) {
                        campoVazio = ' Nome\n';
                      }
                      if (controladorCampoLat.text != null) {
                        campoVazio = campoVazio + ' Telefone\n';
                      }
                      if (controladorCampoLong.text != null) {
                        campoVazio = campoVazio + ' Estado\n';
                      }
                      if (controladorCampoCategoria.text != null) {
                        campoVazio = campoVazio + ' Rua\n';
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
}

void _criaCadastro(
    int id,
    String Nome,
    String Lat,
    String Long,
    String Categoria,
    BuildContext context) {
  final favoritosDao _dao = favoritosDao();

  final CadastroCriado = redistro_favoritos(
      id, Nome, Lat, Long, Categoria);
  _dao.editar_favoritos(CadastroCriado).then((_) => dashboard());

  Navigator.pop(context, CadastroCriado);
}
