
import 'package:flutter/material.dart';

class edit_text_geral extends StatelessWidget {
  final TextEditingController _controlador;
  final String _rotulo;
  final String _dica;
  final IconData _icone;

  edit_text_geral(this._controlador, this._dica, this._rotulo, this._icone);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      TextField(
        controller: _controlador,
        style: TextStyle(
          fontSize: 16.0,
        ),
        decoration: InputDecoration(
          labelText: _rotulo,
          hintText: _dica,
          icon: _icone != null ? Icon(_icone) : null,
        ),
        keyboardType: TextInputType.text,
        
      ),
    ]);
  }
}
