// ignore: use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/edit_text_geral.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
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
  // ignore: non_constant_identifier_names
  final double tamanhp_fonte = 16.0;

  late TextEditingController controladorCampoNome = TextEditingController();
  late TextEditingController controladorCampoLat = TextEditingController();
  late TextEditingController controladorCampoLong = TextEditingController();
  late TextEditingController controladorCampoCategoria =
      TextEditingController();
  String _itemSelecionado = 'Cliente';

  void initState() {
    super.initState();

    controladorCampoNome = new TextEditingController(text: '');
    controladorCampoLat = new TextEditingController(text: lat.toString());
    controladorCampoLong = new TextEditingController(text: long.toString());
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
              edit_text_geral(controladorCampoLat, '-41.258', "Latitude",
                  Icons.map_outlined),
              edit_text_geral(
                  controladorCampoLong, '15.523', 'Longitude', Icons.map_sharp),
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
                    if ((controladorCampoNome.text.length > 2 ) &&
                       (itemInicial.length != 0)){
                      _criaCadastro(
                          controladorCampoNome.text,
                          controladorCampoLat.text,
                          controladorCampoLong.text,
                          itemInicial,
                          context);

                      controladorCampoNome.clear();
                      controladorCampoLat.clear();
                      controladorCampoLong.clear();
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
