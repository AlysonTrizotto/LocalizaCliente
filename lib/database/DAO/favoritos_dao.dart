import 'package:localiza_favoritos/models/pesquisa_cliente.dart';
import 'package:sqflite/sqflite.dart';

import '../app_database.dart';

class favoritosDao {
  static const String _tabelaNome = 'favoritos';
  static const String _favoritos_id = 'id';
  static const String _favoritos_nome = 'nome';
  static const String _favoritos_lat = 'Lat';
  static const String _favoritos_long = 'Long';
  static const String _favoritos_categ = 'categ';
  static const String _Cate_Foreign = 'categoria_id';

  static const String TabelaSqlFavoritos =
      ' CREATE TABLE IF NOT EXISTS $_tabelaNome ('
      ' $_favoritos_id     INTEGER PRIMARY KEY AUTOINCREMENT, '
      ' $_favoritos_nome       text NOT NULL,'
      ' $_favoritos_lat       text NOT NULL,'
      ' $_favoritos_long     text NOT NULL,'
      ' $_favoritos_categ     integer,'
      ' FOREIGN KEY ($_favoritos_categ) '
      ' REFERENCES $_Cate_Foreign ($_favoritos_categ)'
      ' ); ';

  Future<int> save_favoritos(redistro_favoritos favoritos) async {
    final Database db = await BancoDeDados();
    Map<String, dynamic> favoritosMap = _toMap(favoritos);
    return db.insert(_tabelaNome, favoritosMap);
  }

  Map<String, dynamic> _toMap(redistro_favoritos favoritos) {
    final Map<String, dynamic> favoritosMap = {};
    favoritosMap[_favoritos_nome] = favoritos.Nome;
    favoritosMap[_favoritos_lat] = favoritos.Lat;
    favoritosMap[_favoritos_long] = favoritos.Long;
    favoritosMap[_favoritos_categ] = favoritos.Categoria;
    return favoritosMap;
  }

  Future<List<redistro_favoritos>> findAll_favoritos() async {
    final Database db = await BancoDeDados();
    final List<Map<String, dynamic>> result = await db.query(_tabelaNome);
    List<redistro_favoritos> favoritoss = _toList(result);
    return favoritoss;
  }

  Future<List<redistro_favoritos>> find_favoritos(String _pesquisa) async {
    final Database db = await BancoDeDados();
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT * FROM ${_tabelaNome} WHERE ${_favoritos_nome} LIKE "%${_pesquisa}%" ;');
    List<redistro_favoritos> favoritoss = _toList(result);

    return favoritoss;
  }

  Future delete_favoritos(int id) async {
    final Database db = await BancoDeDados();
    await db.delete(_tabelaNome, where: '$_favoritos_id = ?', whereArgs: [id]);
  }

  Future editar_favoritos(redistro_favoritos favoritos) async {
    final Database db = await BancoDeDados();
    Map<String, dynamic> favoritosMap = _toMap(favoritos);
    await db.update(_tabelaNome, favoritosMap,
        where: '${_favoritos_id} = ?', whereArgs: [favoritos.id]);
  }

  List<redistro_favoritos> _toList(List<Map<String, dynamic>> result) {
    final List<redistro_favoritos> favoritoss = [];
    for (Map<String, dynamic> row in result) {
      final redistro_favoritos favoritos = redistro_favoritos(
        row[_favoritos_id],
        row[_favoritos_nome],
        row[_favoritos_lat],
        row[_favoritos_long],
        row[_favoritos_categ],
      );
      favoritoss.add(favoritos);
    }
    return favoritoss;
  }
}
