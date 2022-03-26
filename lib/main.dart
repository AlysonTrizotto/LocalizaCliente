//Apresentando Layout -
import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/mapa.dart';
import 'package:localiza_favoritos/componentes/nethort_help.dart';
import 'package:localiza_favoritos/componentes/rota.dart';
import 'package:localiza_favoritos/componentes/tema.dart';
import 'package:localiza_favoritos/screens/cadastro/editar_favoritos.dart';
import 'package:localiza_favoritos/screens/cadastro/formulario_categoria.dart';
import 'package:localiza_favoritos/screens/cadastro/formulario_favoritos.dart';
import 'package:localiza_favoritos/screens/dashboard/chama_paginas_pesquisa.dart';

import 'package:path_provider/path_provider.dart';
import 'screens/dashboard/inicio.dart';
import 'dart:io';

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
      home: dashboard(0),

      routes: {
        '/retornoEditaFavorios': (BuildContext context) => dashboard(1),
      },
    );
  }
}
