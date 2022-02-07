

//Apresentando Layout -
import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/mapa.dart';
import 'package:localiza_favoritos/componentes/teste.dart';

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
    );
  }
}
