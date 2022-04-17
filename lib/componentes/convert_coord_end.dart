import 'package:flutter/material.dart';

convertCoordEnd(double latCoord, double longCoord) {
    FutureBuilder(
        future: Future.delayed(const Duration()).then((value) {}),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            String snap = snapshot.data;

            return Text(snap);
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  Text(''),
                ],
              ),
            );
          }
        });
  }