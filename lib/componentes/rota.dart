import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geocoder2/geocoder2.dart';

import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:localiza_favoritos/componentes/search.dart';

import 'nethort_help.dart';

class rota extends StatefulWidget {
  LatLng latLng;
  rota(this.latLng);
  @override
  State<StatefulWidget> createState() {
    return RotaState(latLng);
  }
}

class RotaState extends State<rota> {
  late LatLng latLng;
  double lat_final = 0.0;
  double lng_final = 0.0;
  RotaState(this.latLng);
  /********************variveis********************/
  double long = 106.816666;
  double lat = -6.200000;
  double zoom = 15.0;
  late double zoomAtual = 5.0;
  LatLng currentCenter = LatLng(51.5, -0.09);
  final FitBoundsOptions options =
      const FitBoundsOptions(padding: EdgeInsets.all(12.0));
  late String pesquisa = '';
  List<Marker> markersInit = [];
  List<Marker> markersFinal = [];
  List<Marker> markersTracker = [];
  String? _error;
  /**************************************************/

  /*****************Notifier*************************/
  ValueNotifier<bool> rastreio = ValueNotifier(false);
  /**************************************************/

  /*****************Controllers**********************/
  MapController mapController = MapController();
  late MapState map;
  late bool _serviceEnabled;
  late Location location = Location();
  LocationData? _locationData;
  StreamSubscription<LocationData>? _locationSubscription;
  late List<LatLng> points = [];
  /**************************************************/

  @override
  void initState() {
    super.initState();
    points = <LatLng>[
      LatLng(51.5, -0.09),
      LatLng(53.3498, -6.2603),
      LatLng(48.8566, 2.3522),
    ];
    getCurrentLocation();
  }

  getCurrentLocation() async {
    Location getLocation = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData? _locationData;

    _serviceEnabled = await getLocation.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await getLocation.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await getLocation.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await getLocation.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await getLocation.getLocation();
    setState(() {
      print(LatLng(parseToDouble(_locationData?.latitude),
          parseToDouble(_locationData?.longitude)));

      currentCenter = LatLng(parseToDouble(_locationData?.latitude),
          parseToDouble(_locationData?.longitude));
      mapController.move(
          LatLng(parseToDouble(_locationData?.latitude),
              parseToDouble(_locationData?.longitude)),
          13.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controladorCampoPesquisa =
        TextEditingController();
    String chave = '5b3ce3597851110001cf6248c78ca55096174c19a21280e2d83a5133';
    addMarker(latLng);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Navegação'),
          backgroundColor: Color(0xFF101427),
        ),
        body: Center(
          child: Stack(children: [
            FlutterMap(
                mapController: mapController,
                options: MapOptions(
                    maxZoom: 18,
                    minZoom: 4,
                    center: currentCenter,
                    zoom: zoomAtual,
                    plugins: []),
                layers: [
                  TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      //   "https://api.openrouteservice.org/v2/directions/driving-car?api_key=${chave}&start=${lat_init},${lng_init}&end=${lat_final},${lng_final}",
                      subdomains: ['a', 'b', 'c']),
                  PolylineLayerOptions(
                    polylines: [
                      Polyline(
                          points: points,
                          strokeWidth: 4.0,
                          color: Colors.purple),
                    ],
                  ),
                  MarkerLayerOptions(markers: [
                    for (int i = 0; i < markersInit.length; i++) markersInit[i]
                  ]),
                  MarkerLayerOptions(markers: [
                    for (int i = 0; i < markersFinal.length; i++)
                      markersFinal[i]
                  ]),
                  MarkerLayerOptions(markers: [
                    for (int i = 0; i < markersTracker.length; i++)
                      markersTracker[i],
                  ]),
                ]),
            Positioned(
              bottom: 130.0,
              left: 20.0,
              child: FloatingActionButton(
                  heroTag: 'rota',
                  elevation: 50,
                  child: Text(
                    'IR',
                    style: TextStyle(fontSize: 25),
                  ),
                  onPressed: () {
                    //points.clear();
                    print(points);
                    setState(() {
                      routeHelper();
                    });
                    //print(points);
                  }),
            ),
            Positioned(
              top: 30.0,
              right: 20.0,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                FloatingActionButton(
                  heroTag: 'zoomIn',
                  elevation: 50,
                  child: Icon(Icons.add),
                  backgroundColor: Color(0xFF101427),
                  onPressed: () async => _zoomIn(),
                  mini: true,
                ),
                FloatingActionButton(
                  heroTag: 'zoomOut',
                  elevation: 50,
                  child: Icon(Icons.remove),
                  backgroundColor: Color(0xFF101427),
                  onPressed: () async => _zoomOut(),
                  mini: true,
                ),
              ]),
            ),
            Positioned(
              bottom: 130.0,
              right: 20.0,
              child: FloatingActionButton(
                heroTag: 'localizador',
                elevation: 50,
                backgroundColor: Color(0xFF101427),
                onPressed: () async {
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
              minHeight: 110.0,
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
                                hintText: 'Destino',
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
                                  .then((value) => SugestionAdd(pesquisa)),
                              builder: (context, AsyncSnapshot snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  final List _retorno = snapshot.data;
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
                                                setState(() {
                                                  adicionaMarcador(lat, long);
                                                });
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
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> routeHelper() async {
    late List<LatLng> ponto = [];
    double latPoint = 0.0;
    double longPoint = 0.0;

    points.clear();

    List<LngLat> waypoints = [
      LngLat(lat: latLng.latitude, lng: latLng.longitude),
      LngLat(lat: currentCenter.latitude, lng: currentCenter.longitude),
    ];
    print('WAYPOINTS');
    print(waypoints);

    final manager = OSRMManager();
    final road = await manager.getTrip(
      waypoints: waypoints,
      roundTrip: true,
      destination: DestinationGeoPointOption.last,
      source: SourceGeoPointOption.first,
      geometry: Geometries.polyline,
      steps: true,
      languageCode: "en",
    );

    print(road.details.toString());
    print(road.distance);
    print(road.duration.toString());
    print(road.instructions);
    print(road.polyline);
    print(decodePolyline(road.polylineEncoded.toString()));
    List resultado = decodePolyline(road.polylineEncoded.toString());
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      print(resultado);
      for (int x = 0; x < resultado.length; x++) {
        List passagem = resultado[x];
        print(passagem);
        points.add(LatLng(passagem[0], passagem[1]));
      }
      print('points');
      print(points);
    });
  }

  void erroServidor(String err) {
    print('Servidor temporáriamente indisponível');
  }

  void removeMarker() {
    try {
      markersInit.clear();
    } catch (e) {
      print(e);
    }
  }

  void addMarker(LatLng latlng) {
    try {
      currentCenter = latlng;
      markersInit.add(
        Marker(
          width: 150.0,
          height: 150.0,
          point: currentCenter,
          builder: (ctx) => const Icon(
            Icons.location_on,
            color: Colors.greenAccent,
            size: 35.0,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  void removeMarkerFinal() {
    try {
      markersFinal.clear();
    } catch (e) {
      print(e);
    }
  }

  void addMarkerFinal(LatLng latlng) {
    try {
      currentCenter = latlng;
      markersFinal.add(
        Marker(
          width: 150.0,
          height: 150.0,
          point: currentCenter,
          builder: (ctx) => const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 35.0,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  void removeMarkerTracker() {
    try {
      markersTracker.clear();
    } catch (e) {
      print(e);
    }
  }

  void addMarkerTracker(LatLng latlng) {
    try {
      currentCenter = latlng;
      markersTracker.add(
        Marker(
          width: 150.0,
          height: 150.0,
          point: currentCenter,
          builder: (ctx) => const Icon(
            Icons.circle,
            color: Colors.blueAccent,
            size: 30.0,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  void _zoomOut() {
    var bounds = mapController.bounds;
    var centerZoom = mapController.center;
    var zoom = mapController.zoom - 1;
    if (zoom < 3) {
      zoom = 3;
    }
    mapController.move(centerZoom, zoom);
  }

  void _zoomIn() {
    var bounds = mapController.bounds;
    var centerZoom = mapController.center;
    var zoom = mapController.zoom + 1;
    if (zoom < 3) {
      zoom = 3;
    }
    mapController.move(centerZoom, zoom);
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

  Future<void> atualyPosition() async {
    double? lat = 0.0;
    double? long = 0.0;

    try {
      if (!rastreio.value) {
        _locationSubscription =
            location.onLocationChanged.handleError((dynamic err) {
          if (err is PlatformException) {
            setState(() {
              _error = err.code;
            });
          }
          _locationSubscription?.cancel();
          setState(() {
            _locationSubscription = null;
          });
        }).listen((LocationData currentLocation) {
          setState(() {
            _error = null;
            removeMarkerTracker();

            _locationData = currentLocation;
            lat = _locationData!.latitude;
            long = _locationData!.longitude;
            LatLng latlong = LatLng(lat!, long!);
            currentCenter = latlong;
            mapController.move(currentCenter, 16);
            addMarkerTracker(currentCenter);
            print('${_locationData!.latitude}, ${_locationData!.latitude}');
          });
        });
        setState(() {});
      } else {
        _locationSubscription?.cancel();
        setState(() {
          removeMarkerTracker();
          _locationSubscription = null;
        });
      }
      rastreio.value = !rastreio.value;
    } catch (e) {
      print(e);
    }
  }

  Future<void> adicionaMarcador(double lat, double long) async {
    try {
      currentCenter = LatLng(lat, long);
      removeMarkerFinal();
      addMarkerFinal(currentCenter);
      mapController.move(currentCenter, 16);
    } catch (e) {
      print(e);
    }
  }
}
