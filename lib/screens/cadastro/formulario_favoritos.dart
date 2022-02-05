// ignore: use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/edit_text_geral.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_cliente.dart';

class FormularioCadastro extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FormularioCadastroState();
  }
}

class FormularioCadastroState extends State<FormularioCadastro> {
  // ignore: non_constant_identifier_names
  final double tamanhp_fonte = 16.0;

  final TextEditingController controladorCampoNome = TextEditingController();
  final TextEditingController controladorCampoTelefone =
      TextEditingController();
  final TextEditingController controladorCampoEstado = TextEditingController();
  final TextEditingController controladorCampoCidade = TextEditingController();
  final TextEditingController controladorCampoRua = TextEditingController();
  final TextEditingController controladorCampoNum = TextEditingController();

  // const FormularioCadastro({Key? key, this._controladorCampoNome, this._controladorCampoTelefone, this._controladorCampoEstado, this._controladorCampoCidade, this._controladorCampoRua, this._controladorCampoNum}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de favoritoss'),
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
                  onPressed: () => _criaCadastro(
                      controladorCampoNome.text,
                      controladorCampoTelefone.text,
                      controladorCampoEstado.text,
                      controladorCampoRua.text,
                      controladorCampoCidade.text,
                      int.parse(controladorCampoNum.text),
                      context),
                ),
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
  _dao.save_favoritos(CadastroCriado).then((id) => Navigator.pop(context));
}
