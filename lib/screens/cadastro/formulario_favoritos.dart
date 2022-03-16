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
  var _selectedValue = 'Selecione uma categoria';

  void initState() {
    super.initState();


    controladorCampoNome = new TextEditingController(text: '');
    controladorCampoLatF = new TextEditingController(text: lat.toString());
    controladorCampoLongF = new TextEditingController(text: long.toString());
    controladorCampoCategoria = new TextEditingController(text: '');
  }


  void disponse() {
    super.dispose();
  }
   @override
  Widget build(BuildContext context) {
    String campoVazio = '';
    String itemInicial = "Cliente";

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
              FutureBuilder(
                  future: Future.delayed(Duration(seconds: 1))
                      .then((value) => _daoCateg.findAll_categoria()),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final List<registro_categoria> _cadastro = snapshot.data;
                      return DropdownButton(
                        onChanged: (value) {
                          _selectedValue = value as String;
                          setState(() {});
                        },
                        value: _selectedValue,
                        items: _cadastro.map((map) {
                          return DropdownMenuItem(
                            child: Text(map.nome_categoria.toString()),
                            value: map.nome_categoria.toString(),
                          );
                        }).toList(),
                        hint: Text('Selecione uma categoria'),
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
            
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  child: Text('Confirmar'),
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
  }

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


//testes
  /*List<DropdownMenuItem<String>> _categories = [];
  List<DropdownMenuItem<String>> list = [];
  List<registro_categoria> ListaCategoria = [];*/

  /*String? _selecione;
  List<registro_categoria> _refeitorios = <registro_categoria>[];
  //registro_categoria controller = new registro_categoria();
*/
  

/* 
    //_loadcategoria();
/*
    _daoCateg.findAll_categoria().then((listaMap) {
      listaMap.map((map) {
        print(map.toString());

        return getDropDownWidget(map);
      }).forEach((dropDownItem) {
          list.add(dropDownItem);
      });
      setState(() {
        
      });
    });*/

  Map<String, dynamic> _toMap(registro_categoria categoria) {
    const String _categoria_nome = 'categoria_nome';
    const String _categoria_cor = 'categoria_cor';
    const String _categoria_icone = 'categoria_icone';

    final Map<String, dynamic> categoriaMap = {};
    categoriaMap[_categoria_nome] = categoria.nome_categoria;
    categoriaMap[_categoria_cor] = categoria.cor_categoria;
    categoriaMap[_categoria_icone] = categoria.icone_categoria;
    return categoriaMap;
  }


  /* _loadcategoria() async {
    List<registro_categoria> categories = await _daoCateg.findAll_categoria();
    print(categories.length);
    if (categories.length == 0 || categories.length == null)
      _selectedValue = 'Não possui categorias cadastradas';
    setState(() {
      for (int i = 0; i < categories.length; i++) {
        _refeitorios.add(
          categories[i],
        );
        print(categories[i].nome_categoria);
      }
    });
  }*/

  /* List<String> categoriaLista = [];

  _loadcategoria() async {
    List<registro_categoria> categories = await _daoCateg.findAll_categoria();
    print(categories.length);
    if (categories.length == 0 || categories.length == null)
      _selectedValue = 'Não possui categorias cadastradas';
    for (int i = 0; i < categories.length; i++) {
      categoriaLista.add(
        categories[i].nome_categoria.toString(),
      );
      print(categories[i].nome_categoria);
    }

    setState(() {});
  }
*/
 

            /*DropdownButton(
                hint: Text('Escolha um valor'),
                onChanged: (value) {},
                items: list,
              ),*/

              /*DropdownButton<String>(
                hint: Text("Selecione Refeitório"),
                dropdownColor: Colors.white,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 36,
                isExpanded: true,
                underline: SizedBox(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
                value: _selecione,
                onChanged: (novoValor) {
                  setState(() {
                    _selecione = novoValor;
                    print(_selecione);
                  });
                },
                items: _refeitorios.map((registro_categoria valueItem) {
                  return new DropdownMenuItem<String>(
                    value: valueItem.nome_categoria,
                    child: new Text(valueItem.nome_categoria),
                  );
                }).toList(),
              ),*/

               /*DropdownButton(
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value;
                  });
                },
                value: _selectedValue,
                items: _categories,
                hint: Text('Selecione uma categoria'),
              ),*/

              /*
  DropdownMenuItem<String> getDropDownWidget(Map<String, dynamic> map) {
    
    return DropdownMenuItem(value: map['ITEM'], child: Text(map['ITEM']));
  }*/

   
*/