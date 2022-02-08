// ignore: use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/edit_text_geral.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_cliente.dart';
import 'package:localiza_favoritos/screens/dashboard/inicio.dart';

class FormularioCadastro extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FormularioCadastroState();
  }
}

class FormularioCadastroState extends State<FormularioCadastro> {
  // ignore: non_constant_identifier_names
  final double tamanhp_fonte = 16.0;

  late TextEditingController controladorCampoNome = TextEditingController();
  late TextEditingController controladorCampoTelefone = TextEditingController();
  late TextEditingController controladorCampoEstado = TextEditingController();
  late TextEditingController controladorCampoCidade = TextEditingController();
  late TextEditingController controladorCampoRua = TextEditingController();
  late TextEditingController controladorCampoNum = TextEditingController();

  // const Formula
  //rioCadastro({Key? key, this._controladorCampoNome, this._controladorCampoTelefone, this._controladorCampoEstado, this._controladorCampoCidade, this._controladorCampoRua, this._controladorCampoNum}) : super(key: key);
  void initState() {
    super.initState();

    controladorCampoNome = new TextEditingController(text: '');
    controladorCampoTelefone = new TextEditingController(text: '');
    controladorCampoEstado = new TextEditingController(text: '');
    controladorCampoRua = new TextEditingController(text: '');
    controladorCampoCidade = new TextEditingController(text: '');
    controladorCampoNum = new TextEditingController(text: '');
  }

  void disponse() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              TextField(
                controller: controladorCampoTelefone,
                // ignore: prefer_const_constructors
                style: TextStyle(
                  fontSize: tamanhp_fonte,
                ),
                // ignore: prefer_const_constructors
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  hintText: "(DDD) 9 0000-0000",
                  icon: Icon(Icons.phone_rounded),
                ),
                keyboardType: TextInputType.phone,
              ),
              edit_text_geral(controladorCampoEstado, 'Estado', "Paraná",
                  Icons.add_location_alt_outlined),
              edit_text_geral(controladorCampoCidade, 'Cidade', 'Curitiba',
                  Icons.location_city_rounded),
              edit_text_geral(controladorCampoRua, 'Rua', "Rui Barbosa",
                  Icons.add_road_rounded),
              TextField(
                controller: controladorCampoNum,
                style: TextStyle(
                  fontSize: tamanhp_fonte,
                ),
                // ignore: prefer_const_constructors
                decoration: InputDecoration(
                  labelText: 'Número',
                  hintText: "123",
                  // ignore: prefer_const_constructors
                  icon: Icon(Icons.local_convenience_store_rounded),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                    // ignore: prefer_const_constructors
                    child: Text('Confirmar'),
                    onPressed: () {
                      _criaCadastro(
                          controladorCampoNome.text,
                          controladorCampoTelefone.text,
                          controladorCampoEstado.text,
                          controladorCampoRua.text,
                          controladorCampoCidade.text,
                          int.parse(controladorCampoNum.text),
                          context);
                      //initState();
                      /*
                      controladorCampoTelefone = new TextEditingController(text: '');
                      controladorCampoEstado = new TextEditingController(text: '');
                      controladorCampoRua = new TextEditingController(text: '');
                      controladorCampoCidade = new TextEditingController(text: '');
                      controladorCampoNome = new TextEditingController(text: '');
                      controladorCampoNum = new TextEditingController(text: '');
*/
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _criaCadastro(String Nome, String Telefone, String Estado, String Cidade,
    String Rua, int numParse, BuildContext context) {
  final favoritosDao _dao = favoritosDao();

  final CadastroCriado =
      redistro_favoritos(Nome, Telefone, Estado, Cidade, Rua, numParse);
  _dao.save_favoritos(CadastroCriado).then((_) => dashboard());
  ;
}
/*
void reset() {
  for (final FormFieldState<dynamic> field in _fields)
    field.reset();
  _hasInteractedByUser = false;
  _fieldDidChange();
}*/