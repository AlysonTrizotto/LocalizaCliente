import 'package:flutter/material.dart';

convert_Coord_End(double latCoord, double longCoord) {
    FutureBuilder(
        future: Future.delayed(Duration()).then((value) {}),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            String snap = snapshot.data;

            return Text('${snap}');
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text(''),
                ],
              ),
            );
          }
        });
  }