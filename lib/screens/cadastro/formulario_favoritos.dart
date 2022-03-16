import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/edit_text_geral.dart';
import 'package:localiza_favoritos/database/DAO/categoria_dao.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_categoria.dart';
import 'package:localiza_favoritos/models/pesquisa_cliente.dart';
import 'package:localiza_favoritos/screens/dashboard/inicio.dart';
import 'package:localiza_favoritos/screens/listas/lista_categoria.dart';

class FormularioCadastro extends StatefulWidget {
  final double lat;
  final double long;
  FormularioCadastro(this.lat, this.long);

  @override
  State<StatefulWidget> createState() {
    return FormularioCadastroState(this.lat, this.long);
  }
}

class FormularioCadastroState extends State<FormularioCadastro> {
  final double lat;
  final double long;
  FormularioCadastroState(this.lat, this.long);

  final categoriaDao _daoCateg = categoriaDao();

  final double tamanhp_fonte = 16.0;

  late TextEditingController controladorCampoNome = TextEditingController();
  late TextEditingController controladorCampoLatF = TextEditingController();
  late TextEditingController controladorCampoLongF = TextEditingController();
  late TextEditingController controladorCampoCategoria =
      TextEditingController();

  List<DropdownMenuItem<String>> _categories = [];
  List<registro_categoria> ListaCategoria = [];

  void initState() {
    super.initState();

    _loadcategoria();
    controladorCampoNome = new TextEditingController(text: '');
    controladorCampoLatF = new TextEditingController(text: lat.toString());
    controladorCampoLongF = new TextEditingController(text: long.toString());
    controladorCampoCategoria = new TextEditingController(text: '');
  }

  void disponse() {
    super.dispose();
  }

  var _selectedValue;
  //var _categories = <DropdownMenuItem>[];

  _loadcategoria() async {
    var categories = await _daoCateg.findAll_categoria();

    categories.forEach((category) {
      setState(() {
        _categories.add(DropdownMenuItem<String>(
          child: Text(category.nome_categoria.toString()),
          value: category.nome_categoria.toString(),
        ));
      });
    });
  }

/*
  Future pesqCateg() async {
    print('entrou no pesq');
    ListaCategoria = await _daoCateg.findAll_categoria();
    ListaCategoria.forEach((listaCorrida) {
      Map<String, dynamic> categoriaMap = _toMap(listaCorrida);
      print(listaCorrida.nome_categoria);
      getDrop(categoriaMap);
    });
  }

  Map<String, dynamic> _toMap(registro_categoria categoria) {
    const String _categoria_nome = 'categoria_nome';
    final Map<String, dynamic> categoriaMap = {};
    categoriaMap[_categoria_nome] = categoria.nome_categoria;

    print(categoriaMap.toString());
    return categoriaMap;
  }*/
  @override
  Widget build(BuildContext context) {
    String campoVazio = '';

    // registro_categoria _itemSelecionado;

    var itemInicial;
    int quantidade = 0;
    if (quantidade == null) {
      ListaVazia();
    }

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
              edit_text_geral(controladorCampoLatF, '-41.258', "Latitude",
                  Icons.map_outlined),
              edit_text_geral(controladorCampoLongF, '15.523', 'Longitude',
                  Icons.map_sharp),
              DropdownButton(
                  value: _selectedValue,
                  items: _categories,
                  hint: Text('Selecione uma categoria'),
                  onChanged: (value) {
                    setState(() {
                      _selectedValue = value;
                    });
                  }),
          
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  child: Text('Confirmar'),
                  //onPressed: () => pesqCateg(),
                  onPressed: () {
                    if ((controladorCampoNome.text.length > 2) &&
                        (itemInicial.length != 0)) {
                      _criaCadastro(
                          controladorCampoNome.text,
                          controladorCampoLatF.text,
                          controladorCampoLongF.text,
                          itemInicial,
                          context);

                      controladorCampoNome.clear();
                      controladorCampoLatF.clear();
                      controladorCampoLongF.clear();
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
  } /*

  DropdownMenuItem<String> getDrop(Map<String, dynamic> map) {
    return DropdownMenuItem<String>(
        value: map['ITEM'], child: Text(map['ITEM']));
  }*/
}

void _criaCadastro(String Nome, String Lat, String Long, String Categoria,
    BuildContext context) {
  final favoritosDao _dao = favoritosDao();

  final CadastroCriado = redistro_favoritos(0, Nome, Lat, Long, Categoria);
  _dao.save_favoritos(CadastroCriado).then((_) => dashboard());
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
