import 'package:flutter/material.dart';

Widget loadingScreen(BuildContext context, String extraInfo) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircularProgressIndicator.adaptive(),
        const SizedBox(height: 20),
        Text(
          'Carregando...\n$extraInfo',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
