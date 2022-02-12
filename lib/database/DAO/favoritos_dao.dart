import 'package:localiza_favoritos/models/pesquisa_cliente.dart';
import 'package:sqflite/sqflite.dart';

import '../app_database.dart';

class favoritosDao {
  static const String _tabelaNome = 'favoritos';
  static const String _favoritos_id = 'id';
  static const String _favoritos_nome = 'nome';
  static const String _favoritos_telefone = 'telefone';
  static const String _favoritos_estado = 'estado';
  static const String _favoritos_cidade = 'cidade';
  static const String _favoritos_rua = 'rua';
  static const String _favoritos_num = 'num';
  static const String _categoria = 'categoria';

  static const String TabelaSqlFavoritos =
      ' CREATE TABLE IF NOT EXISTS $_tabelaNome ('
      ' $_favoritos_id     INTEGER PRIMARY KEY AUTOINCREMENT, '
      ' $_favoritos_nome       text NOT NULL,'
      ' $_favoritos_telefone   text,'
      ' $_favoritos_estado     text NOT NULL,'
      ' $_favoritos_cidade     text NOT NULL,'
      ' $_favoritos_rua        text NOT NULL,'
      ' $_favoritos_num        int NOT NULL,'
      ' $_categoria     text NOT NULL'
      ' ); ';

  Future<int> save_favoritos(redistro_favoritos favoritos) async {
    final Database db = await BancoDeDados();
    Map<String, dynamic> favoritosMap = _toMap(favoritos);
    return db.insert(_tabelaNome, favoritosMap);
  }

  Map<String, dynamic> _toMap(redistro_favoritos favoritos) {
    final Map<String, dynamic> favoritosMap = {};
    favoritosMap[_favoritos_nome] = favoritos.Nome;
    favoritosMap[_favoritos_telefone] = favoritos.Telefone;
    favoritosMap[_favoritos_estado] = favoritos.Endereco;
    favoritosMap[_favoritos_cidade] = favoritos.Cidade;
    favoritosMap[_favoritos_rua] = favoritos.Endereco;
    favoritosMap[_favoritos_num] = favoritos.NumeroEnd.toInt();
    favoritosMap[_categoria] = favoritos.Categoria;
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
    //print('Dentro do find' + _pesquisa);
    //print(favoritoss.toList());
    return favoritoss;
  }
  
  Future delete_favoritos(int id) async {
    final Database db = await BancoDeDados();
     await db.delete(_tabelaNome, where: '$_favoritos_id = ?', whereArgs: [id]);
  }

  List<redistro_favoritos> _toList(List<Map<String, dynamic>> result) {
    final List<redistro_favoritos> favoritoss = [];
    for (Map<String, dynamic> row in result) {
      final redistro_favoritos favoritos = redistro_favoritos(
        row[_favoritos_id],
        row[_favoritos_nome],
        row[_favoritos_telefone],
        row[_favoritos_estado],
        row[_favoritos_cidade],
        row[_favoritos_rua],
        row[_favoritos_num],
        row[_categoria],
      );
      favoritoss.add(favoritos);
    }
    return favoritoss;
  }
}
