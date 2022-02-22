import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

class Rota extends StatefulWidget {
  static String tag = 'ListaPesquisa';
  @override
  State<StatefulWidget> createState() {
    return RotaState();
  }
}

//Declarando o MapCOntroler
class RotaState extends State<Rota> with OSMMixinObserver {
  //variaveis
  final _form = GlobalKey<FormState>();
  late final ValueChanged<String>? onChanged;
  late String pesquisa = '';
  late GlobalKey<ScaffoldState> scaffoldKey;
  ValueNotifier<GeoPoint?> lastGeoPoint = ValueNotifier(null);
  late GeoPoint lastMarkPosition =
      GeoPoint(latitude: 47.4358055, longitude: 8.4737384);
  ValueNotifier<bool> rastreio = ValueNotifier(false);
  ValueNotifier<bool> rota = ValueNotifier(false);
  ValueNotifier<IconData> IconeRastreio = ValueNotifier(Icons.my_location);
  double latDestino = 0.0;
  double longDestino = 0.0;
  double latPartida = 0.0;
  double longPartida = 0.0;

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
            //image: AssetImage("asset/pin.png"),
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
    final SheetController sheet = SheetController();
    return Scaffold(
      appBar: AppBar(
        title: Text('Navegação'),
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
                elevation: 50,
                child: Transform.rotate(
                  angle: 150 * pi / 100,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: rota,
                    builder: (ctx, isTracking, _) {
                      if (isTracking) {
                        return Icon(
                          Icons.send_outlined,
                          color: Colors.white,
                        );
                      }
                      return Icon(Icons.cancel_schedule_send_outlined,
                          color: Colors.deepOrangeAccent);
                    },
                  ),
                ),
                onPressed: () {
                  desenhaRota(latDestino, longDestino);
                }),
          ),
          Positioned(
            top: 160.0,
            right: 20.0,
            child:
                //floatingActionButton:
                Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              FloatingActionButton(
                elevation: 50,
                child: Icon(Icons.add),
                backgroundColor: Color(0xFF101427),
                onPressed: () async {
                  mapController.zoomIn();
                },
                mini: true,
              ),
              FloatingActionButton(
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
          SlidingSheet(
            controller: sheet,
            elevation: 20,
            cornerRadius: 16,
            snapSpec: const SnapSpec(
              snap: true,
              snappings: [20, 400, double.infinity],
              positioning: SnapPositioning.pixelOffset,
            ),
            builder: (context, state) {
              return Padding(
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
                                hintText: 'Destino',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                contentPadding: const EdgeInsets.all(15),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          //height: MediaQuery.of(context).size.height - 263,
                          child: FutureBuilder(
                              future: Future.delayed(Duration())
                                  .then((value) => pesquisaEndereco(pesquisa)),
                              builder: (context, AsyncSnapshot snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  final List<SearchInfo> _retorno =
                                      snapshot.data;
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
                                                latDestino = lat;
                                                longDestino = long;
                                                updatePosition(lat, long);
                                                adicionaMarcador(lat, long);
                                              },
                                              child: Card(
                                                elevation: 50,
                                                child: ListTile(
                                                  leading: Icon(Icons
                                                      .location_on_outlined),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
              );
            },
          ),
        ]),
      ),
    );
  }

  Future<void> desenhaRota(double latDestino, double longDestino) async {
    if (!rota.value) {
      rastreio.value = false;
      //await atualyPosition();
      GeoPoint geoPoint = await mapController.myLocation();
      RoadInfo roadInfo = await mapController.drawRoad(
        GeoPoint(latitude: latDestino, longitude: longDestino),
        GeoPoint(latitude: geoPoint.latitude, longitude: geoPoint.longitude),
        intersectPoint: [
          GeoPoint(latitude: latDestino, longitude: longDestino),
          GeoPoint(latitude: latPartida, longitude: longPartida)
        ],
        roadOption: RoadOption(
          roadWidth: 13,
          roadColor: Colors.blue,
          showMarkerOfPOI: true,
          zoomInto: true,
        ),
      );
      await mapController.currentLocation();
      await mapController.myLocation();
      await mapController.setZoom(zoomLevel: 18);
      print("${roadInfo.distance}km");
      print("${roadInfo.duration}sec");
    } else {
      rastreio.value = true;
      await mapController.removeLastRoad();
      // await atualyPosition();
      await mapController.currentLocation();
      await mapController.setZoom(zoomLevel: 17.5);
    }
    rota.value = !rota.value;
  }

  Future<void> locationChabge() async {
    await mapController
        .goToLocation(GeoPoint(latitude: 47.35387, longitude: 8.43609));
  }

  Future<void> getCenterMap() async {
    GeoPoint centerMap = await mapController.centerMap;
  }

  Future<void> atualyPosition() async {
    removerMarcador();
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
  }

  Future<void> removerMarcador() async {
    if (lastGeoPoint.value != null) {
      mapController.removeMarker(lastGeoPoint.value!);
    }
  }

  Future<void> adicionaMarcador(double lat, double long) async {
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
      mapController.removeMarker(lastGeoPoint.value!);
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
  }

  Future<void> updatePosition(double lat, double long) async {
    await mapController.disabledTracking();

    await mapController.goToLocation(GeoPoint(latitude: lat, longitude: long));

    await mapController.setZoom(zoomLevel: 17);
  }

  Future pesquisaEndereco(String endereco) async {
    List<SearchInfo> suggestions = await addressSuggestion(endereco);
    removerMarcador();
    return suggestions.toList();
  }
}
