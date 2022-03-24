import 'dart:io';
import 'package:path_provider/path_provider.dart';

  pegaDiretorio() async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();

    new Directory(appDocDirectory.path + '/' + 'dir')
        .create(recursive: true)
        .then((Directory directory) {
      print('Path of New Dir: ' + directory.path);
    });
    return appDocDirectory.path.toString();
  }