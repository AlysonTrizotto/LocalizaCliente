
import 'package:localiza_favoritos/models/pesquisa_hotel.dart';
import 'package:sqflite/sqflite.dart';

import '../app_database.dart';

class hotelDao {
  static const String _tabelaNome = 'hotel';
  static const String _hotel_id = 'hotel_id';
  static const String _hotel_nome = 'hotel_nome';
  static const String _hotel_telefone = 'hotel_telefone';
  static const String _hotel_estado = 'hotel_estado';
  static const String _hotel_cidade = 'hotel_cidade';
  static const String _hotel_rua = 'hotel_rua';
  static const String _hotel_num = 'hotel_num';

  static const String TabelaSqlhotel =
      ' CREATE TABLE IF NOT EXISTS $_tabelaNome ('
      ' $_hotel_id     INTEGER PRIMARY KEY AUTOINCREMENT, '
      ' $_hotel_nome       text NOT NULL,'
      ' $_hotel_telefone   text,'
      ' $_hotel_estado     text NOT NULL,'
      ' $_hotel_cidade     text NOT NULL,'
      ' $_hotel_rua        text NOT NULL,'
      ' $_hotel_num     INTEGER NOT NULL'
      ' ); ';

  Future<int> save_hotel(registro_hoteis hotel) async {
    final Database db = await BancoDeDados();
    Map<String, dynamic> hotelMap = _toMap(hotel);
    return db.insert(_tabelaNome, hotelMap);
  }

  Map<String, dynamic> _toMap(registro_hoteis hotel) {
    final Map<String, dynamic> hotelMap = {};
    hotelMap[_hotel_nome] = hotel.nome_hotel;
    hotelMap[_hotel_telefone] = hotel.telefone_hotel;
    hotelMap[_hotel_estado] = hotel.estado_hotel;
    hotelMap[_hotel_cidade] = hotel.cidade_hotel;
    hotelMap[_hotel_rua] = hotel.rua_hotel;
    hotelMap[_hotel_num] = hotel.num_hotel.toInt();
    return hotelMap;
  }

  Future<List<registro_hoteis>> findAll_hotel() async {
    final Database db = await BancoDeDados();
    final List<Map<String, dynamic>> result = await db.query(_tabelaNome);
    List<registro_hoteis> hotels = _toList(result);
    return hotels;
  }

  List<registro_hoteis> _toList(List<Map<String, dynamic>> result) {
    final List<registro_hoteis> hotels = [];
    for (Map<String, dynamic> row in result) {
      final registro_hoteis hotel = registro_hoteis(
        row[_hotel_nome],
        row[_hotel_telefone],
        row[_hotel_estado],
        row[_hotel_cidade],
        row[_hotel_rua],
        row[_hotel_num],
      );
      hotels.add(hotel);
    }
    return hotels;
  }
}
