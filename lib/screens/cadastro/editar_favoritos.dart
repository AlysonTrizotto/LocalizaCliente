import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/edit_text_geral.dart';
import 'package:localiza_favoritos/database/DAO/categoria_dao.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_categoria.dart';
import 'package:localiza_favoritos/models/pesquisa_cliente.dart';

class editaFavoritos extends StatefulWidget {
  final int id;
  final String nome;
  final String lat;
  final String long;
  final int categoria;
  const editaFavoritos(this.id, this.nome, this.lat, this.long, this.categoria, {Key? key}) : super(key: key);
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
  final int categoria;
  editaFavoritosState(this.id, this.nome, this.lat, this.long, this.categoria);

  final double tamanhoFonte = 16.0;
  String campoVazio = '';
  late int itemInicial = categoria;

  final categoriaDao _daoCateg = categoriaDao();
  late TextEditingController controladorCampoNome = TextEditingController();
  late TextEditingController controladorCampoLatE = TextEditingController();
  late TextEditingController controladorCampoLongE = TextEditingController();
  late TextEditingController controladorCampoCategoria =
      TextEditingController();
  var _selectedValue;

  @override
  void initState() {
    super.initState();

    controladorCampoNome =  TextEditingController(text: nome);
    controladorCampoLatE =  TextEditingController(text: lat.toString());
    controladorCampoLongE =  TextEditingController(text: lat.toString());
  }

  void disponse() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              edit_text_geral(controladorCampoNome, 'Nome', 'Empresa',
                  Icons.apartment_rounded, true),
              edit_text_geral(controladorCampoLatE, '-41.258', "Latitude",
                  Icons.map_outlined, false),
              edit_text_geral(controladorCampoLongE, '15.523', 'Longitude',
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
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
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
                  child: const Text('Confirmar'),
                  onPressed: () {
                    if (controladorCampoNome.text.length > 2) {
                      _criaCadastro(
                          id,
                          controladorCampoNome.text,
                          lat.toString(),
                          long.toString(),
                          //controladorCampoLatE.text,
                          //controladorCampoLongE.text,
                          itemInicial,
                          context);

                      controladorCampoNome.clear();
                      controladorCampoLatE.clear();
                      controladorCampoLongE.clear();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Cadastro realizado com sucesso!'),
                          duration: Duration(milliseconds: 1500),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // retorna um objeto do tipo Dialog
                          return AlertDialog(
                            title: const Text("Não é possível salvar alteração"),
                            content: const Text("Preencha o campo NOME"),
                            actions: <Widget>[
                              // define os botões na base do dialogo
                               FlatButton(
                                child:  const Text("Fechar"),
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

void _criaCadastro(int id, String nome, String lat, String long, int idCateg,
    BuildContext context) {
  final favoritosDao _dao = favoritosDao();

  final cadastroCriado = redistro_favoritos(id, nome, lat, long, idCateg);
  _dao.editar_favoritos(cadastroCriado);

   Navigator.pop(context, cadastroCriado);
}
