import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

class mapa extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MapaState();
  }
}

class MapaState extends State<mapa> {
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



/************************************************************* */

/*
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Mapa extends StatefulWidget {
  const Mapa({Key? key}) : super(key: key);
  static String tag = 'ListaPesquisa';
  @override
  State<StatefulWidget> createState() {
    return MapaState();
  }
}

//Declarando o MapCOntroler
class MapaState extends State<Mapa> with OSMMixinObserver {
  //variaveis

  final _form = GlobalKey<FormState>();
  late final ValueChanged<String>? onChanged;
  late String pesquisa = '';
  late GlobalKey<ScaffoldState> scaffoldKey;
  ValueNotifier<GeoPoint?> lastGeoPoint = ValueNotifier(null);
  late GeoPoint lastMarkPosition =
      GeoPoint(latitude: 47.4358055, longitude: 8.4737384);
  ValueNotifier<bool> rastreio = ValueNotifier(false);
  ValueNotifier<IconData> IconeRastreio = ValueNotifier(Icons.my_location);
  Timer? timer;
  //----------------------------

  //controller
  final MapController mapController = MapController(
    initMapWithUserPosition: true,
    initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
    areaLimit: BoundingBox(
      east: 10.4922941,
      north: 47.8084648,
      south: 45.817995,
      west: 5.9559113,
    ),
  );
  //------------------------

  @override
  void initState() {
    //super.initState();
    mapController.addObserver(this);
    scaffoldKey = GlobalKey<ScaffoldState>();
    mapController.listenerMapLongTapping.addListener(() async {
      if (mapController.listenerMapLongTapping.value != null) {
        print(mapController.listenerMapLongTapping.value);
        await mapController.addMarker(
          mapController.listenerMapLongTapping.value!,
          markerIcon: MarkerIcon(
            icon: Icon(
              Icons.store,
              color: Colors.brown,
              size: 48,
            ),
          ),
          angle: pi / 3,
        );
      }
    });
    mapController.listenerMapSingleTapping.addListener(() async {
      if (mapController.listenerMapSingleTapping.value != null) {
        if (lastGeoPoint.value != null) {
          mapController.removeMarker(lastGeoPoint.value!);
        }
        print(mapController.listenerMapSingleTapping.value);
        lastGeoPoint.value = mapController.listenerMapSingleTapping.value;
        await mapController.addMarker(
          lastGeoPoint.value!,
          markerIcon: MarkerIcon(
            icon: Icon(
              Icons.location_on_outlined,
              size: 68,
            ),
          ),
        );
      }
    });
    mapController.listenerRegionIsChanging.addListener(() async {
      if (mapController.listenerRegionIsChanging.value != null) {
        print(mapController.listenerRegionIsChanging.value);
      }
    });
  }

  Future<void> mapIsInitialized() async {
    await mapController.setZoom(zoomLevel: 12);
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      await mapIsInitialized();
    }
  }

  @override
  void dispose() {
    if (timer != null && timer!.isActive) {
      timer?.cancel();
    }

    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controladorCampoPesquisa =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa'),
      ),
      body: Container(
        child: Stack(children: [
          OSMFlutter(
            controller: mapController,
            trackMyPosition: rastreio.value,
            androidHotReloadSupport: true,
            mapIsLoading: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.blueGrey[400],
                  ),
                  Text("Carregando Mapa..."),
                ],
              ),
            ),
            onMapIsReady: (isReady) {},
            initZoom: 8,
            minZoomLevel: 3,
            maxZoomLevel: 19,
            stepZoom: 1.0,
            onLocationChanged: (myLocation) {
              print(myLocation);
            },
            userLocationMarker: UserLocationMaker(
              personMarker: MarkerIcon(
                icon: Icon(
                  Icons.location_on_rounded,
                  color: Colors.deepPurpleAccent,
                  size: 48,
                ),
              ),
              directionArrowMarker: MarkerIcon(
                icon: Icon(
                  Icons.personal_injury_rounded,
                  size: 48,
                ),
              ),
            ),
            roadConfiguration: RoadConfiguration(
              startIcon: MarkerIcon(
                icon: Icon(
                  Icons.person,
                  size: 64,
                  color: Colors.brown,
                ),
              ),
              roadColor: Colors.yellowAccent,
            ),
            markerOption: MarkerOption(
              defaultMarker: MarkerIcon(
                icon: Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 56,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30.0,
            left: 20.0,
            child: FloatingActionButton(
                heroTag: 'rota',
                elevation: 50,
                child: Transform.rotate(
                  angle: 150 * pi / 100,
                  child: Icon(Icons.send_outlined),
                ),
                onPressed: () {
                  CalculaRota();
                  //Navigator.of(context).pushNamed('rota');
                }),
          ),
          Positioned(
            top: 130.0,
            right: 20.0,
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              FloatingActionButton(
                heroTag: 'zoomIn',
                elevation: 50,
                child: Icon(Icons.add),
                backgroundColor: Color(0xFF101427),
                onPressed: () async {
                  mapController.zoomIn();
                },
                mini: true,
              ),
              FloatingActionButton(
                heroTag: 'zoomOut',
                elevation: 50,
                child: Icon(Icons.remove),
                backgroundColor: Color(0xFF101427),
                onPressed: () async {
                  mapController.zoomOut();
                },
                mini: true,
              ),
            ]),
          ),
          Positioned(
            bottom: 30.0,
            right: 20.0,
            child: FloatingActionButton(
              heroTag: 'localizador',
              elevation: 50,
              backgroundColor: Color(0xFF101427),
              onPressed: () async {
                removerMarcador();
                atualyPosition();
              },
              child: ValueListenableBuilder<bool>(
                valueListenable: rastreio,
                builder: (ctx, isTracking, _) {
                  if (isTracking) {
                    return Icon(
                      Icons.my_location,
                      color: Color.fromARGB(255, 226, 215, 215),
                    );
                  }
                  return Icon(Icons.gps_off_sharp,
                      color: Colors.deepOrangeAccent);
                },
              ),
            ),
          ),
          SlidingUpPanel(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0)),
            minHeight: 28.0,
            panel: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: Stack(children: <Widget>[
                Container(
                  height: 500,
                  child: SingleChildScrollView(
                    child: Column(children: <Widget>[
                      SizedBox(
                        child: Card(
                          elevation: 50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          color: Colors.white,
                          child: TextField(
                            controller: controladorCampoPesquisa,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: Colors.black,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    pesquisa = controladorCampoPesquisa.text;
                                    print(pesquisa);
                                  });
                                },
                                child: Icon(
                                  Icons.search,
                                  color: Colors.black,
                                ),
                              ),
                              hintText: 'Pesquisa',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding: const EdgeInsets.all(15),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: FutureBuilder(
                            future: Future.delayed(Duration())
                                .then((value) => pesquisaEndereco(pesquisa)),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                final List<SearchInfo> _retorno = snapshot.data;
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _retorno.length,
                                  itemBuilder: (context, indice) {
                                    final String _endereco =
                                        _retorno[indice].address.toString();
                                    final double lat =
                                        _retorno[indice].point!.latitude;
                                    final double long =
                                        _retorno[indice].point!.longitude;
                                    return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              updatePosition(lat, long);
                                              adicionaMarcador(lat, long);
                                            },
                                            child: Card(
                                              elevation: 50,
                                              child: ListTile(
                                                leading: Icon(
                                                    Icons.location_on_outlined),
                                                title: Text(_endereco),
                                                subtitle: Text('Latitude: ' +
                                                    lat.toString() +
                                                    '\nLongitude: ' +
                                                    long.toString()),
                                              ),
                                            ),
                                          ),
                                        ]);
                                  },
                                );
                              } else {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      Text(''),
                                    ],
                                  ),
                                );
                              }
                            }),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> CalculaRota() async {
    try {
      atualyPosition();
      RoadInfo roadInfo = await mapController.drawRoad(
        GeoPoint(latitude: -25.5121038, longitude: -49.1649872),
        GeoPoint(latitude: -25.5119462, longitude: -49.1668627),
        roadType: RoadType.car,
        intersectPoint: [
          GeoPoint(latitude: -25.5121038, longitude: -49.1649872),
          GeoPoint(latitude: -25.5119462, longitude: -49.1668627),
        ],
        roadOption: RoadOption(
          roadWidth: 10,
          roadColor: Colors.blue,
          showMarkerOfPOI: false,
          zoomInto: true,
        ),
      );
      print("${roadInfo.distance}km");
      print("${roadInfo.duration}sec");
    } catch (e) {
      print('*******************');
      print(e);
      print('*******************');
    }
  }

  Future<void> locationChabge() async {
    try {
      await mapController
          .goToLocation(GeoPoint(latitude: 47.35387, longitude: 8.43609));
    } catch (e) {
      print("************************\n");
      print(e);
      print("\n************************");
    }
  }

  Future<void> getCenterMap() async {
    try {
      GeoPoint centerMap = await mapController.centerMap;
    } catch (e) {
      print("************************\n");
      print(e);
      print("\n************************");
    }
  }

  Future<void> atualyPosition() async {
    try {
      if (!rastreio.value) {
        await mapController.currentLocation();
        await mapController.enableTracking();
        await mapController.setZoom(zoomLevel: 18);
        IconeRastreio.value = Icons.gps_off_sharp;
      } else {
        await mapController.disabledTracking();
        await mapController.setZoom(zoomLevel: 17.8);
        IconeRastreio.value = Icons.my_location_rounded;
      }
      rastreio.value = !rastreio.value;
    } catch (e) {
      print("************************\n");
      print(e);
      print("\n************************");
    }
  }

  Future<void> removerMarcador() async {
    try {
      if (lastGeoPoint.value != null) {
        mapController.removeMarker(lastGeoPoint.value!);
      }
    } catch (e) {
      print("************************\n");
      print(e);
      print("\n************************");
    }
  }

  Future<void> adicionaMarcador(double lat, double long) async {
    try {
      removerMarcador();
      if (lastGeoPoint.value == null) {
        lastGeoPoint.value = GeoPoint(latitude: lat, longitude: long);
        await mapController.addMarker(
          lastGeoPoint.value!,
          markerIcon: MarkerIcon(
            icon: Icon(
              Icons.location_on_outlined,
              size: 68,
            ),
          ),
        );
      }
      if (lastGeoPoint.value != null) {
        lastGeoPoint.value = GeoPoint(latitude: lat, longitude: long);
        await mapController.addMarker(
          lastGeoPoint.value!,
          markerIcon: MarkerIcon(
            icon: Icon(
              Icons.location_on_outlined,
              size: 68,
            ),
          ),
        );
      }
      await mapController.setZoom(zoomLevel: 17);
    } catch (e) {
      print("************************\n");
      print(e);
      print("\n************************");
    }
  }

  Future<void> updatePosition(double lat, double long) async {
    try {
      await mapController.disabledTracking();

      await mapController
          .goToLocation(GeoPoint(latitude: lat, longitude: long));

      await mapController.setZoom(zoomLevel: 17);
    } catch (e) {
      print("************************\n");
      print(e);
      print("\n************************");
    }
  }

  Future pesquisaEndereco(String endereco) async {
    try {
      List<SearchInfo> suggestions = await addressSuggestion(endereco);

      return suggestions.toList();
    } catch (e) {
      print("************************\n");
      print(e);
      print("\n************************");
    }
  }
}
*/