// ignore: use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/edit_text_geral.dart';
import 'package:localiza_favoritos/database/DAO/categoria_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_categoria.dart';

class FormularioCategoria extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FormularioCategoriaState();
  }
}

class FormularioCategoriaState extends State<FormularioCategoria> {
  // ignore: non_constant_identifier_names
  final double tamanhp_fonte = 16.0;

  late TextEditingController controladorCampoNome = TextEditingController();

  @override
  void initState() {
    super.initState();

    controladorCampoNome = TextEditingController(text: '');
  }

  void disponse() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String campoVazio = '';
    String cor = '';

    const double tamanhoIconeCor = 40.0;
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
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    direction: Axis.horizontal,
                    spacing: 8,
                    runSpacing: 15,
                    children: [
                      GestureDetector(
                        onTap: () {
                          cor = 'amberAccent';
                        },
                        child: const Icon(
                          Icons.radio_button_checked,
                          color: Colors.amberAccent,
                          size: tamanhoIconeCor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          cor = 'amber';
                        },
                        child: const Icon(
                          Icons.radio_button_checked,
                          color: Colors.amber,
                          size: tamanhoIconeCor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          cor = 'orangeAccent';
                        },
                        child: const Icon(
                          Icons.radio_button_checked,
                          color: Colors.orangeAccent,
                          size: tamanhoIconeCor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          cor = 'orange';
                        },
                        child: const Icon(
                          Icons.radio_button_checked,
                          color: Colors.orange,
                          size: tamanhoIconeCor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          cor = 'orangeAccent';
                        },
                        child: const Icon(
                          Icons.radio_button_checked,
                          color: Colors.redAccent,
                          size: tamanhoIconeCor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          cor = 'red';
                        },
                        child: const Icon(
                          Icons.radio_button_checked,
                          color: Colors.red,
                          size: tamanhoIconeCor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          cor = 'purpleAccent';
                        },
                        child: const Icon(
                          Icons.radio_button_checked,
                          color: Colors.purpleAccent,
                          size: tamanhoIconeCor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          cor = 'purple';
                        },
                        child: const Icon(
                          Icons.radio_button_checked,
                          color: Colors.purple,
                          size: tamanhoIconeCor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          cor = 'blueAccent';
                        },
                        child: const Icon(
                          Icons.radio_button_checked,
                          color: Colors.blueAccent,
                          size: tamanhoIconeCor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          cor = 'blue';
                        },
                        child: const Icon(
                          Icons.radio_button_checked,
                          color: Colors.blue,
                          size: tamanhoIconeCor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          cor = 'green';
                        },
                        child: const Icon(
                          Icons.radio_button_checked,
                          color: Colors.green,
                          size: tamanhoIconeCor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          cor = 'greenAccent';
                        },
                        child: const Icon(
                          Icons.radio_button_checked,
                          color: Color.fromARGB(255, 21, 34, 28),
                          size: tamanhoIconeCor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  child: const Text('Confirmar'),
                  onPressed: () {
                    if (controladorCampoNome.text.isNotEmpty) {
                      _criaCadastro(
                          controladorCampoNome.text, cor, 'Icone', context);

                      controladorCampoNome.clear();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Cadastro realizado com sucesso!'),
                          duration: Duration(milliseconds: 1500),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
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
    String nome, String cor, String icone, BuildContext context) {
  final categoriaDao _dao = categoriaDao();

  final cadastroCriado = registro_categoria(0, nome, cor, icone);
  _dao.save_corategoria(cadastroCriado);
}
