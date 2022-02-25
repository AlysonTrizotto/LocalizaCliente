import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

class Rota extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RotaState();
  }
}

class RotaState extends State<Rota> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Stack(children: [
            FlutterMap(
              options: MapOptions(
                center: LatLng(45.5231, -122.6765),
                zoom: 13.0,
              ),
              layers: [
                TileLayerOptions(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c']),
              ],
            ),
            FloatingActionButton(onPressed: () {
              desenhaRota(-25.5114592, -49.1659281);
            })
          ]),
        ),
      ),
    );
  }

  Future<void> desenhaRota(double latDestino, double longDestino) async {
    List<LngLat> waypoints = [
      LngLat(lng: latDestino, lat: longDestino),
      LngLat(lng: -25.5119413, lat: -49.1668627),
    ];
    final manager = OSRMManager();
    final road = await manager.getRoad(
      waypoints: waypoints,
      geometrie: Geometries.polyline,
      steps: true,
      languageCode: "en",
    );
  }
}
