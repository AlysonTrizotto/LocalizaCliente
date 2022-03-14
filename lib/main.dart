//Apresentando Layout -
import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/mapa.dart';
import 'package:localiza_favoritos/componentes/nethort_help.dart';
import 'package:localiza_favoritos/componentes/rota.dart';
import 'package:localiza_favoritos/screens/cadastro/editar_favoritos.dart';
import 'package:localiza_favoritos/screens/cadastro/formulario_favoritos.dart';
import 'package:localiza_favoritos/screens/dashboard/chama_paginas_pesquisa.dart';

import 'screens/dashboard/inicio.dart';

void main() {
  runApp(CLHApp());
}

// ignore: use_key_in_widget_constructors
class CLHApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blueGrey[400],
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF101427), //use your hex code here
        ),
      ),
      home: dashboard(),
      /*initialRoute: 'dashboard',
        routes: {
          'dashboard' : (context) => dashboard(),
          'mapa': (context) => mapa(),
          'rota': (context) => rota(0.0,0.0),
        }*/
    );
  }
}
