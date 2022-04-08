import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> mensgemScreen(
    BuildContext context, String mensagem) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensagem),
      duration: const Duration(milliseconds: 1500),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
