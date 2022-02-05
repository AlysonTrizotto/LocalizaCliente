
import 'package:flutter/material.dart';

class containerCard extends StatelessWidget {
  final IconData _iconData;
  final String _rotulo;

  containerCard(this._iconData, this._rotulo);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 120,
      padding: const EdgeInsets.all(38),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          // ignore: prefer_const_constructors
          Icon(_iconData,
          size: 60,
          color: Colors.cyan[300]),
          Text(_rotulo,
          // ignore: prefer_const_constructors
          style:  TextStyle(
          fontSize: 18.0
          ),
          ),
        ],
      ),
    );
  }
}
