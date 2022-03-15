// ignore: use_key_in_widget_constructors
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
  String _itemSelecionado = '';

  List<registro_categoria> categoriaListaString = [];

  void initState() {
    super.initState();

    pesqCateg();
    controladorCampoNome = new TextEditingController(text: '');
    controladorCampoLatF = new TextEditingController(text: lat.toString());
    controladorCampoLongF = new TextEditingController(text: long.toString());
    controladorCampoCategoria = new TextEditingController(text: '');
  }

  void disponse() {
    super.dispose();
  }

  Future pesqCateg() async {
    categoriaListaString = await _daoCateg.findAll_categoria();
    //print(categoriaLista.length);

    for (int i = 0; i < categoriaListaString.length; i++) {
      //print(categoriaLista[i].nome_categoria);
      getDropDownWidget(categoriaListaString[i].nome_categoria);
    }
  }

  DropdownMenuItem<String> getDropDownWidget(String item) {
    print(item);
    return DropdownMenuItem<String>(
      value: item,
      child: Text(item),
    );
  }

  @override
  Widget build(BuildContext context) {
    int quantidade = 0;
    if (quantidade == null) {
      ListaVazia();
    }

    late registro_categoria _registro;

    String campoVazio = '';
    String itemInicial = "Cliente";
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
                        hint: Text('Choose an Option'),
                        //value: registro_categoria(_registro.nome_categoria, _registro.cor_categoria, _registro.icone_categoria),
                        onChanged: (registro_categoria? value) {
                          setState(() {
                            _registro = value!;
                          });
                        },
                        items: _cadastro
                            .map((categoria) =>
                                DropdownMenuItem<registro_categoria>(
                                  child: Text(categoria.nome_categoria),
                                  value: categoria,
                                ))
                            .toList(),
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
