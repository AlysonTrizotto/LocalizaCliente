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
        id, nome, double.parse(lat), double.parse(long), categoria);
  }
}

class editaFavoritosState extends State<editaFavoritos> {
  final int id;
  final String nome;
  final double lat;
  final double long;
  final String categoria;
  editaFavoritosState(this.id, this.nome, this.lat, this.long, this.categoria);

  final double tamanhp_fonte = 16.0;
  String campoVazio = '';
  String itemInicial = "Cliente";

  late TextEditingController controladorCampoNome = TextEditingController();
  late TextEditingController controladorCampoLatE = TextEditingController();
  late TextEditingController controladorCampoLongE = TextEditingController();
  late TextEditingController controladorCampoCategoria =
      TextEditingController();
  String _itemSelecionado = 'Cliente';

  void initState() {
    super.initState();

    controladorCampoNome = new TextEditingController(text: '');
    controladorCampoCategoria = new TextEditingController(text: '');
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
    controladorCampoNome.text = nome;

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
              edit_text_geral(controladorCampoLatE, '-41.258', "Latitude",
                  Icons.map_outlined),
              edit_text_geral(controladorCampoLongE, '15.523', 'Longitude',
                  Icons.map_sharp),
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
                  child: Text('Confirmar'),
                  onPressed: () {
                    if ((controladorCampoNome.text.length > 2) &&
                        (itemInicial.length != 0)) {
                      _criaCadastro(
                          controladorCampoNome.text,
                          controladorCampoLatE.text,
                          controladorCampoLongE.text,
                          itemInicial,
                          context);

                      controladorCampoNome.clear();
                      controladorCampoLatE.clear();
                      controladorCampoLongE.clear();
                      controladorCampoCategoria.clear();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              const Text('Cadastro realizado com sucesso!'),
                          duration: const Duration(milliseconds: 1500),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      campoVazio = '';
                      if (controladorCampoNome.text.length == 0) {
                        campoVazio = ' Nome\n';
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

void _criaCadastro(String Nome, String Lat, String Long, String Categoria,
    BuildContext context) {
  final favoritosDao _dao = favoritosDao();

  final CadastroCriado = redistro_favoritos(0, Nome, Lat, Long, Categoria);
  _dao.editar_favoritos(CadastroCriado).then((_) => dashboard());

  Navigator.pop(context, CadastroCriado);
}
