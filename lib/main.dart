// @dart=2.9
//Apresentando Layout -
import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/tema.dart';
import 'screens/dashboard/inicio.dart';

void main() async {
  runApp(CLHApp());
}


// ignore: use_key_in_widget_constructors
class CLHApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: localizaTema,
      debugShowCheckedModeBanner: false,
      //home: mapa(),
      //home: FormularioCadastro(0.0,0.0),
      home: const dashboard(0),

      routes: {
        '/retornoEditaFavorios': (BuildContext context) => const dashboard(1),
      },
    );
  }
}
