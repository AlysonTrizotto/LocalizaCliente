import 'dart:async';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:localiza_favoritos/componentes/mensagem.dart';

Future SugestionAdd(BuildContext context, String endereco) async {
  try {
    List<SearchInfo> suggestions = await addressSuggestion(endereco);
    return suggestions.toList();
  } catch (e) {
    mensgemScreen(context, 'Ocorreu um erro não previsto, \n Erro: ${e}');
  }
}


