import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/edit_text_geral.dart';
import 'package:localiza_favoritos/componentes/loading.dart';
import 'package:localiza_favoritos/componentes/mensagem.dart';
import 'package:localiza_favoritos/database/DAO/categoria_dao.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_categoria.dart';
import 'package:localiza_favoritos/models/pesquisa_cliente.dart';

class FormularioCadastro extends StatefulWidget {
  final double lat;
  final double long;
  const FormularioCadastro(this.lat, this.long, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FormularioCadastroState(lat, long);
  }
}

class FormularioCadastroState extends State<FormularioCadastro> {
  final double lat;
  final double long;
  FormularioCadastroState(this.lat, this.long);

  final categoriaDao _daoCateg = categoriaDao();

  final double tamanhoFonte = 16.0;

  late TextEditingController controladorCampoNome = TextEditingController();
  late TextEditingController controladorCampoLatF = TextEditingController();
  late TextEditingController controladorCampoLongF = TextEditingController();
  late TextEditingController controladorCampoCategoria =
      TextEditingController();
  int itemInicial = -1;
  var _selectedValue;

  @override
  void initState() {
    super.initState();

    controladorCampoNome = TextEditingController(text: '');
    controladorCampoLatF = TextEditingController(text: lat.toString());
    controladorCampoLongF = TextEditingController(text: long.toString());
    controladorCampoCategoria = TextEditingController(text: '');
  }

  void disponse() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String campoVazio = '';
    int quantidade = 0;
    if (quantidade == null) {
      mensgemScreen(context, 'Cadastro realizado com sucesso!');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              edit_text_geral(controladorCampoNome, 'Nome', 'Empresa',
                  Icons.apartment_rounded, true),
              edit_text_geral(controladorCampoLatF, '-41.258', "Latitude",
                  Icons.map_outlined, false),
              edit_text_geral(controladorCampoLongF, '15.523', 'Longitude',
                  Icons.map_sharp, false),
              FutureBuilder(
                  future: Future.delayed(const Duration(seconds: 1))
                      .then((value) => _daoCateg.findAll_categoria()),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final List<registro_categoria> _cadastro = snapshot.data;
                      if (_selectedValue == "Selecione uma categoria") {
                        _selectedValue =
                            _cadastro.first.nome_categoria.toString();
                      }
                      return DropdownButton(
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value;
                            for (int i = 0; i < _cadastro.length; i++) {
                              if (_cadastro[i].nome_categoria ==
                                  _selectedValue) {
                                itemInicial = _cadastro[i].id_categoria;
                              }
                            }
                          });
                        },
                        value: _selectedValue,
                        items: _cadastro.map((map) {
                          return DropdownMenuItem(
                            child: Text(map.nome_categoria.toString()),
                            value: map.nome_categoria.toString(),
                          );
                        }).toList(),
                        hint: const Text('Selecione uma categoria'),
                      );
                    } else {
                      return loadingScreen(context, 'Carregando favoritos');
                    }
                  }),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  child: const Text('Confirmar'),
                  onPressed: () {
                    if ((controladorCampoNome.text.length > 2) &&
                        (itemInicial != null)) {
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

                      mensgemScreen(context, 'Cadastro realizado com sucesso!');
                    } else {
                      campoVazio = '';
                      if (controladorCampoNome.text.isEmpty) {
                        campoVazio = ' Nome\n';
                      }
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // retorna um objeto do tipo Dialog
                          return AlertDialog(
                            title: const Text("Não é permitido campos vazios"),
                            content:
                                Text("Preencha os campos: \n" + campoVazio),
                            actions: <Widget>[
                              // define os botões na base do dialogo
                              FlatButton(
                                child: const Text("Fechar"),
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
    String nome, String lat, String lng, int idCateg, BuildContext context) {
  final favoritosDao _dao = favoritosDao();

  final cadastroCriado = redistro_favoritos(0, nome, lat, lng, idCateg);
  _dao.save_favoritos(cadastroCriado);
}
