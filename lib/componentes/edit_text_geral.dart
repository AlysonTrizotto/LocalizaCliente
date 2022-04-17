import 'package:flutter/material.dart';

class EditTextGeral extends StatelessWidget {
  final TextEditingController _controlador;
  final String _rotulo;
  final String _dica;
  final IconData _icone;
  final bool _enable;
  const EditTextGeral(this._controlador, this._dica, this._rotulo, this._icone, this._enable, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      TextField(
        controller: _controlador,
        enabled: _enable,
        style: const TextStyle(
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
