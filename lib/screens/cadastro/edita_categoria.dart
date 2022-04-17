import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/edit_text_geral.dart';
import 'package:localiza_favoritos/componentes/mensagem.dart';
import 'package:localiza_favoritos/database/DAO/categoria_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_categoria.dart';
import 'package:localiza_favoritos/screens/dashboard/inicio.dart';

class editaCategoria extends StatefulWidget {
  final int id;
  final String nome;
  final String cor;
  final String icone;
  editaCategoria(this.id, this.nome, this.cor, this.icone);
  @override
  State<StatefulWidget> createState() {
    return editaCategoriaState(id, nome, cor, icone);
  }
}

class editaCategoriaState extends State<editaCategoria> {
  final int id;
  final String nome;
  final String cor;
  final String icone;
  editaCategoriaState(this.id, this.nome, this.cor, this.icone);

  final double tamanhp_fonte = 16.0;
  String campoVazio = '';
  int itemInicial = 0;

  final categoriaDao _daoCateg = categoriaDao();
  late TextEditingController controladorCampoNome = TextEditingController();
  var _selectedValue;

  void initState() {
    super.initState();

    controladorCampoNome = new TextEditingController(text: '');
  }

  void disponse() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controladorCampoNome.text = nome;

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              EditTextGeral(controladorCampoNome, 'Nome', 'Empresa',
                  Icons.apartment_rounded, true),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  child: Text('Confirmar'),
                  onPressed: () {
                    if (controladorCampoNome.text.length != 0) {
                      _criaCadastro(
                          id, controladorCampoNome.text, cor, icone, context);

                      controladorCampoNome.clear();

                      mensgemScreen(context, 'Cadastro editado com sucesso!');
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

void _criaCadastro(int id, String Nome, cor, icone, BuildContext context) {
  final categoriaDao _dao = categoriaDao();

  final CadastroCriado = registro_categoria(id, Nome, cor, icone);
  _dao.editar_favoritos(CadastroCriado);

  Navigator.pop(context, CadastroCriado);
}
