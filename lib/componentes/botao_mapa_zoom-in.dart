import 'package:flutter/material.dart';

class botao extends StatelessWidget{
 @override
  Widget build(BuildContext context) {
   return Ink(
          decoration: const ShapeDecoration(
            color: Colors.lightBlue,
            shape: CircleBorder(),
          ),
          child: IconButton(
            icon: const Icon(Icons.android),
            color: Colors.white,
            onPressed: () {},
          ),
        
   );
  }
}