import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

Future SugestionAdd(String endereco) async {
  try {
    List<SearchInfo> suggestions = await addressSuggestion(endereco);

    return suggestions.toList();
  } catch (e) {
    print("********Pesquisa*******\n");
    print(e);
    print("\n*********************");
  }
}
