import 'dart:async';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:localiza_favoritos/componentes/mensagem.dart';
import 'package:geocoder/geocoder.dart';
/*
Future SugestionAdd(BuildContext context, String endereco) async {
  try {
    List<SearchInfo> suggestions = await addressSuggestion(endereco);
    return suggestions.toList();
  } catch (e) {
    mensgemScreen(context, 'Ocorreu um erro não previsto, \n Erro: ${e}');
  }
}

*/

SugestionAdd(BuildContext context, String endereco) async {
  try {
    var suggestions = await Geocoder.local.findAddressesFromQuery(endereco);

    List<ListaGeocoder> listaEnd = [];

    for (var element in suggestions) {
      listaEnd.add(ListaGeocoder(element.addressLine, element.coordinates.latitude, element.coordinates.longitude));
    }

    return listaEnd;
  } catch (e) {
    mensgemScreen(context,
        'Ocorreu um erro ao realizar a pesquisa de endereço, \n Erro: ${e}');
  }
}

class ListaGeocoder {
  final String rua;
  final double lat;
  final double long;
  ListaGeocoder(this.rua, this.lat, this.long);
}
