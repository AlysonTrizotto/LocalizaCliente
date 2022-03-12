import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'DAO/favoritos_dao.dart';
import 'DAO/categoria_dao.dart';

Future<Database> BancoDeDados() async {
  final String path = join(await getDatabasesPath(), 'GIS-mobile.db');

  //deleteDatabase(path);


  return openDatabase(
    path,
    onCreate: (db, version) {
      db.execute(favoritosDao.TabelaSqlFavoritos);
      db.execute(categoriaDao.TabelaSqlcategoria);
    },
    version: 1,
    onDowngrade: onDatabaseDowngradeDelete,
  );
}
/*
Future<void> deleteDatabase(String path) async {
  print('Entrou no delete');
  databaseFactory.deleteDatabase(path);
}
*/