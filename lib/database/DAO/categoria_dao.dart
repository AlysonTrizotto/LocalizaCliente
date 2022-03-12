
import 'package:localiza_favoritos/models/pesquisa_categoria.dart';
import 'package:sqflite/sqflite.dart';

import '../app_database.dart';

class categoriaDao {
  static const String _tabelaNome = 'categoria';
  static const String _categoria_id = 'categoria_id';
  static const String _categoria_nome = 'categoria_nome';
  static const String _categoria_cor = 'categoria_cor';
  static const String _categoria_icone = 'categoria_icone';

  static const String TabelaSqlcategoria =
      ' CREATE TABLE IF NOT EXISTS $_tabelaNome ('
      ' $_categoria_id     INTEGER PRIMARY KEY AUTOINCREMENT, '
      ' $_categoria_nome       text NOT NULL,'
      ' $_categoria_cor   text,'
      ' $_categoria_icone     text'
      ' ); ';

  Future<int> save_c_categoria_corategoria(registro_categoria categoria) async {
    final Database db = await BancoDeDados();
    Map<String, dynamic> categoriaMap = _toMap(categoria);
    return db.insert(_tabelaNome, categoriaMap);
  }

  Map<String, dynamic> _toMap(registro_categoria categoria) {
    final Map<String, dynamic> categoriaMap = {};
    categoriaMap[_categoria_nome] = categoria.nome_categoria;
    categoriaMap[_categoria_cor] = categoria.cor_categoria;
    categoriaMap[_categoria_icone] = categoria.icone_categoria;
    return categoriaMap;
  }

  Future<List<registro_categoria>> findAll_categoria() async {
    final Database db = await BancoDeDados();
    final List<Map<String, dynamic>> result = await db.query(_tabelaNome);
    List<registro_categoria> categorias = _toList(result);
    return categorias;
  }

  
  Future<List<registro_categoria>> find_categoria(String _pesquisa) async {
    final Database db = await BancoDeDados();
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT * FROM ${_tabelaNome} WHERE ${_categoria_nome} LIKE "%${_pesquisa}%" ;');
    List<registro_categoria> favoritoss = _toList(result);

    return favoritoss;
  }


  List<registro_categoria> _toList(List<Map<String, dynamic>> result) {
    final List<registro_categoria> categorias = [];
    for (Map<String, dynamic> row in result) {
      final registro_categoria categoria = registro_categoria(
        row[_categoria_nome],
        row[_categoria_cor],
        row[_categoria_icone],
      );
      categorias.add(categoria);
    }
    return categorias;
  }
}
