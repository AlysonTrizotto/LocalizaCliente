import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';



class PolylinePage extends StatefulWidget {
  static const String route = 'polyline';

  @override
  State<PolylinePage> createState() => _PolylinePageState();
}

class _PolylinePageState extends State<PolylinePage> {
  late Future<List<Polyline>> polylines;

  Future<List<Polyline>> getPolylines() async {
    var polyLines = [
      Polyline(
        points: [
          LatLng(50.5, -0.09),
          LatLng(51.3498, -6.2603),
          LatLng(53.8566, 2.3522),
        ],
        strokeWidth: 4.0,
        color: Colors.amber,
      ),
    ];
    await Future.delayed(Duration(seconds: 3));
    return polyLines;
  }

  @override
  void initState() {
    polylines = getPolylines();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var points = <LatLng>[
      LatLng(51.5, -0.09),
      LatLng(53.3498, -6.2603),
      LatLng(48.8566, 2.3522),
    ];

    return Scaffold(
        appBar: AppBar(title: Text('Polylines')),
        //drawer: buildDrawer(context, PolylinePage.route),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: FutureBuilder<List<Polyline>>(
            future: polylines,
            builder:
                (BuildContext context, AsyncSnapshot<List<Polyline>> snapshot) {
              debugPrint('snapshot: ${snapshot.hasData}');
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text('Polylines'),
                    ),
                    Flexible(
                      child: FlutterMap(
                        options: MapOptions(
                          center: LatLng(51.5, -0.09),
                          zoom: 5.0,
                        
                        ),
                        layers: [
                          TileLayerOptions(
                              urlTemplate:
                                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: ['a', 'b', 'c']),
                          PolylineLayerOptions(
                            polylines: [
                              Polyline(
                                  points: points,
                                  strokeWidth: 4.0,
                                  color: Colors.purple),
                            ],
                          ),
                          
                          
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const Text(
                  'Getting map data...\n\nTap on map when complete to refresh map data.');
            },
          ),
        ));
  }
}