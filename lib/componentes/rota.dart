import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';

import 'package:flutter_map/plugin_api.dart';

import 'package:latlong2/latlong.dart';
import 'package:localiza_favoritos/componentes/Calculo_de_rota.dart';
import 'package:localiza_favoritos/componentes/convert_metros_km.dart';
import 'package:localiza_favoritos/componentes/mensagem.dart';
import 'package:localiza_favoritos/database/DAO/categoria_dao.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_categoria.dart';
import 'package:localiza_favoritos/models/pesquisa_cliente.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
//import 'package:flutter_map/flutter_map.dart';

import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:localiza_favoritos/componentes/search.dart';

class Rota extends StatefulWidget {
  LatLng latLng;

  Rota(
    this.latLng, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RotaState(latLng);
  }
}

class RotaState extends State<Rota> with TickerProviderStateMixin {
  final LatLng latLng;
  RotaState(this.latLng);
  double lat_final = 0.0;
  double lng_final = 0.0;

  //********************variveis********************/
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
  List<Marker> markerDb = [];
  List<Marker> markersTracker = [];
  List<redistro_favoritos> banco = [];
  List<registro_categoria> bancoCategoria = [];
  List<RoadInstruction> listaDirecao = [];
  String? _error;
  int contadorReinicioRota = 0;
  /**************************************************/

  /*****************Notifier*************************/
  ValueNotifier<bool> rastreio = ValueNotifier(false);
  ValueNotifier<bool> btnNavegar = ValueNotifier(false);
  ValueNotifier<bool> containerRota = ValueNotifier(true);
  ValueNotifier<bool> containerDirecao = ValueNotifier(false);
  ValueNotifier<bool> containerPesquisa = ValueNotifier(true);
  ValueNotifier<String> distanciaRota = ValueNotifier('0 KM');
  ValueNotifier<String> tempoRota = ValueNotifier('00:00');
  ValueNotifier<IconData> iconeDirecao =
      ValueNotifier(Icons.gpp_maybe_outlined);
  ValueNotifier<double> direcaoGraus = ValueNotifier(0);
  ValueNotifier<double> direcao_compass = ValueNotifier(0.0);
  bool _isVisible = false;
  bool _isVisibleContainerRota = true;
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

    lat_final = latLng.latitude;
    lng_final = latLng.longitude;

    points = <LatLng>[
      LatLng(51.5, -0.09),
      LatLng(53.3498, -6.2603),
      LatLng(48.8566, 2.3522),
    ];
    getCurrentLocation();
    addMarkerDbTracker();

    print('Latitude: ${latLng.latitude} , Longitude: ${latLng.longitude}');
  }

  @override
  void dispose() {
    if (rastreio.value == true) {
      _locationSubscription?.cancel();
    }

    _locationSubscription = null;

    super.dispose();
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

    getLocation.changeSettings(
      accuracy: LocationAccuracy.navigation,
      interval: 10,
      distanceFilter: 0,
    );

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

    var _needLoadingError = true;
    addMarker(latLng);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Navegação'),
          backgroundColor: Color(0xFF101427),
        ),
        body: Center(
          child: Stack(
            children: [
              FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    maxZoom: 18,
                    minZoom: 4,
                    center: currentCenter,
                    zoom: zoomAtual,
                    plugins: [],
                    slideOnBoundaries: true,
                    screenSize: MediaQuery.of(context).size,
                  ),
                  layers: [
                    TileLayerOptions(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                        updateInterval: 1,
                        errorTileCallback: (Tile tile, error) {
                          if (_needLoadingError) {
                            WidgetsBinding.instance!.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                duration: Duration(seconds: 1),
                                content: Text(
                                  error.toString(),
                                  style: TextStyle(color: Colors.black),
                                ),
                                backgroundColor: Colors.deepOrange,
                              ));
                            });

                            _needLoadingError = false;
                          }
                          throw Exception('Unknown error, description: $error');
                        }),
                    PolylineLayerOptions(
                      polylines: [
                        Polyline(
                            points: points,
                            strokeWidth: 8.0,
                            color: Colors.indigoAccent),
                      ],
                    ),
                    MarkerLayerOptions(markers: [
                      for (int i = 0; i < markersInit.length; i++)
                        markersInit[i]
                    ]),
                    MarkerLayerOptions(markers: [
                      for (int i = 0; i < markersFinal.length; i++)
                        markersFinal[i]
                    ]),
                    MarkerLayerOptions(markers: [
                      for (int i = 0; i < markersTracker.length; i++)
                        markersTracker[i],
                    ]),
                    MarkerLayerOptions(markers: [
                      for (int i = 0; i < markerDb.length; i++) markerDb[i]
                    ]),
                  ]),
              compass(),
              Visibility(
                visible: true,
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: 80,
                      width: double.maxFinite,
                      child: Card(
                        child: Row(
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  iconeDirecao.value,
                                  color: Colors.grey,
                                  size: 45.0,
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  distanciaRota.value,
                                  style: TextStyle(fontSize: 30),
                                ),
                              ],
                            ),
                            SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  tempoRota.value,
                                  style: TextStyle(fontSize: 30),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: _isVisible,
                child: Positioned(
                  bottom: 130.0,
                  left: 20.0,
                  child: FloatingActionButton.extended(
                      heroTag: 'rota',
                      elevation: 50,
                      backgroundColor: Colors.deepOrangeAccent,
                      icon: Icon(Icons.directions_car_filled_outlined),
                      label: const Text('IR'),
                      onPressed: () {
                        setState(() {
                          if (rastreio.value != true) {
                            atualyPosition();
                          }
                          routeHelper();
                        });
                      }),
                ),
              ),
              Positioned(
                top: 90.0,
                right: 20.0,
                child:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  FloatingActionButton(
                    heroTag: 'zoomIn',
                    elevation: 50,
                    child: const Icon(Icons.add),
                    backgroundColor: const Color(0xFF101427),
                    onPressed: () async => _zoomIn(),
                    mini: true,
                  ),
                  FloatingActionButton(
                    heroTag: 'zoomOut',
                    elevation: 50,
                    child: const Icon(Icons.remove),
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
                  backgroundColor: const Color(0xFF101427),
                  onPressed: () async {
                    atualyPosition();
                  },
                  child: ValueListenableBuilder<bool>(
                    valueListenable: rastreio,
                    builder: (ctx, isTracking, _) {
                      if (isTracking) {
                        return const Icon(
                          Icons.my_location,
                          color: Color.fromARGB(255, 226, 215, 215),
                        );
                      }
                      return const Icon(Icons.gps_off_sharp,
                          color: Colors.deepOrangeAccent);
                    },
                  ),
                ),
              ),
              Visibility(
                visible: containerPesquisa.value,
                child: SlidingUpPanel(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0)),
                  minHeight: 110.0,
                  panel: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                    child: Stack(
                      children: <Widget>[
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
                                    onSubmitted: (value) {
                                      if (controladorCampoPesquisa
                                              .text.length >=
                                          3) {
                                        setState(() {
                                          pesquisa =
                                              controladorCampoPesquisa.text;
                                          estadoBtnNavegarFalse();
                                        });
                                      } else {
                                        mensgemScreen(context,
                                            'Para realizar uma pesquisa digite mais que 3 caracteres');
                                      }
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.black,
                                      ),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            pesquisa =
                                                controladorCampoPesquisa.text;
                                            if (pesquisa.length >= 3) {
                                              estadoBtnNavegarFalse();
                                            }
                                          });
                                        },
                                        child: const Icon(
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
                                    future: Future.delayed(Duration()).then(
                                        (value) =>
                                            SugestionAdd(context, pesquisa)),
                                    builder: (context, AsyncSnapshot snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        final List _retorno = snapshot.data;
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: _retorno.length,
                                          itemBuilder: (context, indice) {
                                            final String _endereco =
                                                _retorno[indice]
                                                    .address
                                                    .toString();
                                            final double lat = _retorno[indice]
                                                .point!
                                                .latitude;
                                            final double long = _retorno[indice]
                                                .point!
                                                .longitude;
                                            return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  GestureDetector(
                                                    onTap: () {
                                                      lat_final = lat;
                                                      lng_final = long;
                                                      setState(() {
                                                        adicionaMarcador(
                                                            lat, long);
                                                      });
                                                    },
                                                    child: Card(
                                                      elevation: 50,
                                                      child: ListTile(
                                                        leading: const Icon(Icons
                                                            .location_on_outlined),
                                                        title: Text(_endereco),
                                                        subtitle: Text(
                                                            'Latitude: ' +
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
                                            children: const [
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
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: containerDirecao.value,
                child: SlidingUpPanel(
                  borderRadius: const BorderRadius.only(
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
                            const SizedBox(
                              child: Card(
                                elevation: 50,
                                color: Colors.white,
                                child: Text('Direção',
                                    style: TextStyle(fontSize: 20)),
                              ),
                            ),
                            Container(
                              child: FutureBuilder(
                                  future: Future.delayed(Duration())
                                      .then((value) => direcao(currentCenter)),
                                  builder: (context, AsyncSnapshot snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data != null) {
                                      final List<RoadInstruction> _retorno =
                                          snapshot.data;

                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: _retorno.length,
                                        itemBuilder: (context, indice) {
                                          ValueNotifier<IconData> endereco =
                                              ValueNotifier(
                                                  Icons.gpp_maybe_outlined);
                                          endereco.value = direcaoSeta(
                                              _retorno[indice].instruction);

                                          ValueNotifier<String> distancia =
                                              ValueNotifier('0.0 Km');
                                          distancia.value = convertMetrosKm(
                                              _retorno[indice].distance, 1000);

                                          return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Card(
                                                  elevation: 50,
                                                  child: ListTile(
                                                    leading:
                                                        Icon(endereco.value),
                                                    title: Text(_retorno[indice]
                                                        .instruction
                                                        .replaceAll(
                                                            ' %s',
                                                            ' ' +
                                                                distancia
                                                                    .value)),
                                                    subtitle: const Text(''),
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
                                          children: const [
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget compass() {
    return StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error reading heading: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          double? direction = snapshot.data!.headingForCameraMode;

          if (direction == null) {
            return const Center(
              child: Text("Dispositivo sem sensor de direção!"),
            );
          } else {
            //direcao.value = direction * (math.pi / 180) * -1;
            direcaoGraus.value = (direction * -1) - 20;
          }

          return Positioned(
            top: 90.0,
            left: 20.0,
            child: Container(
              child: Transform.rotate(
                angle: (direction * -1) - 20,
                child: Card(
                  color: Color(0xFF101427),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(90.0)),
                  child: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          );
        });
  }

  void estadoBtnNavegarFalse() {
    if (btnNavegar.value == false) {
      setState(() {
        _isVisible = true;
        btnNavegar.value = true;
      });
    }
  }

  void estadoBtnNavegarTrue() {
    if (btnNavegar.value == true) {
      setState(() {
        _isVisible = false;
        btnNavegar.value = false;
      });
    }
  }

  void estadoContainerRotaFalse() {
    if (containerRota.value == false) {
      setState(() {
        _isVisibleContainerRota = true;
        containerRota.value = true;
      });
    }
  }

  void estadoContainerRotaTrue() {
    if (containerRota.value == true) {
      setState(() {
        _isVisibleContainerRota = false;
        containerRota.value = false;
      });
    }
  }

  Future<void> routeHelper() async {
    late List<LatLng> ponto = [];
    points.clear();
    listaDirecao.clear();

    List<LngLat> waypoints = [
      LngLat(lat: latLng.latitude, lng: latLng.longitude),
      LngLat(lat: lat_final, lng: lng_final),
    ];

    final manager = OSRMManager();
    final road = await manager.getTrip(
      waypoints: waypoints,
      roundTrip: false,
      destination: DestinationGeoPointOption.last,
      source: SourceGeoPointOption.first,
      geometry: Geometries.polyline,
      steps: true,
      languageCode: "en",
    );

    distanciaRota.value = convertMetrosKm(road.distance, 1);
    tempoRota.value = getStringToTime(road.duration.toInt());
    listaDirecao = road.instructions;

    listaDirecao.removeWhere((element) => element.instruction == '');

    List resultado = decodePolyline(road.polylineEncoded.toString());

    setState(() {
      for (int x = 0; x < resultado.length; x++) {
        List passagem = resultado[x];
        points.add(LatLng(passagem[0], passagem[1]));
      }
    });

    containerPesquisa.value = false;
    containerDirecao.value = true;

    //atualyPosition();
  }

  String getStringToTime(int valor) {
    if (valor < 0) return 'Tempo inválido';

    var seconds = valor;
    final days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;
    final hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;
    final minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;

    final List<String> tokens = [];
    if (days != 0) {
      tokens.add('${days}d');
    }
    if (tokens.isNotEmpty || hours != 0) {
      tokens.add('${hours}h');
    }
    if (tokens.isNotEmpty || minutes != 0) {
      tokens.add('${minutes}m');
    }
    tokens.add('${seconds}s');

    return tokens.join(':');
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
          if (mounted == true) {
            setState(() {
              _error = null;
              removeMarkerTracker();

              _locationData = currentLocation;
              lat = _locationData!.latitude;
              long = _locationData!.longitude;
              LatLng latlong = LatLng(lat!, long!);
              currentCenter = latlong;
              //mapController.move(currentCenter, 17);
              _animatedMapMove(currentCenter, 17);
              //mapController.rotate(direcaoGraus.value);
              _animatedMapRotate(direcaoGraus.value);
              addMarkerTracker(currentCenter);
              removeMarkerDb();
              addMarkerDbTracker();
              direcao(currentCenter);

              String finalPonto = 'You have reached a waypoint of your trip';
              for (int i = 0; i < listaDirecao.length; i++) {
                if (listaDirecao[i].instruction.contains(finalPonto)) {
                  iconeDirecao.value =
                      direcaoSeta(listaDirecao[i + 1].instruction);
                }
                if (listaDirecao[i].location == currentCenter) {
                  iconeDirecao.value = direcaoSeta(listaDirecao[i].instruction);
                }

                if (listaDirecao[i].location != currentCenter) {
                  latLng.latitude = currentCenter.latitude;
                  latLng.longitude = currentCenter.longitude;
                  contadorReinicioRota++;
                  if (contadorReinicioRota == 50) {
                    contadorReinicioRota = 0;
                    routeHelper();
                  }
                  //Future.delayed(Duration(seconds: 60));
                }
              }
            });
          }
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

  void _animatedMapRotate(double rotacao) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.rotate(rotacao);
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  List<RoadInstruction> direcao(LatLng localizcaoAtual) {
    String finalPonto = 'You have reached a waypoint of your trip';
    for (int i = 0; i < listaDirecao.length; i++) {
      if (listaDirecao[i].instruction.contains(finalPonto)) {
        iconeDirecao.value = direcaoSeta(listaDirecao[i + 1].instruction);
      }
      if (listaDirecao[i].location == localizcaoAtual) {
        iconeDirecao.value = direcaoSeta(listaDirecao[i].instruction);
      }

      if (listaDirecao[i].location != currentCenter) {
        latLng.latitude = currentCenter.latitude;
        latLng.longitude = currentCenter.longitude;
        contadorReinicioRota++;
        if (contadorReinicioRota == 50) {
          contadorReinicioRota = 0;
          routeHelper();
        }
        //Future.delayed(Duration(seconds: 60));
      }
    }

    return listaDirecao;
  }

  IconData direcaoSeta(String directions) {
    IconData icone = Icons.gpp_maybe_outlined;
    if (directions.contains('left')) {
      icone = Icons.turn_left;
    } else if (directions.contains('Continue')) {
      icone = Icons.arrow_upward;
    } else if (directions.contains('right')) {
      icone = Icons.turn_right;
    } else if (directions.contains('Go on')) {
      icone = Icons.arrow_upward;
    }

    return icone;
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

  void removeMarkerDb() {
    try {
      banco.clear();
    } catch (e) {
      print("************************\n");
      print(e);
      print("\n************************");
    }
  }

  void addMarkerDbTracker() async {
    try {
      bancoCategoria = await PesquisaCategoria();
      banco = await PesquisaIcone();
      for (int i = 0; i < banco.length; i++) {
        Color _color = Colors.black;
        String cor = '';
        for (int x = 0; x < bancoCategoria.length; x++) {
          if (bancoCategoria[x].id_categoria == banco[i].id_categoria) {
            cor = bancoCategoria[x].cor_categoria;
          }
        }

        switch (cor) {
          case 'amberAccent':
            {
              _color = Colors.amberAccent;
            }
            break;
          case 'amber':
            {
              _color = Colors.amber;
            }
            break;
          case 'orangeAccent':
            {
              _color = Colors.orangeAccent;
            }
            break;
          case 'orange':
            {
              _color = Colors.orange;
            }
            break;
          case 'redAccent':
            {
              _color = Colors.redAccent;
            }
            break;
          case 'red':
            {
              _color = Colors.red;
            }
            break;
          case 'purple':
            {
              _color = Colors.purple;
            }
            break;
          case 'blueAccent':
            {
              _color = Colors.blueAccent;
            }
            break;
          case 'blue':
            {
              _color = Colors.blue;
            }
            break;
          case 'green':
            {
              _color = Colors.green;
            }
            break;
          case 'greenAccent':
            {
              _color = Colors.greenAccent;
            }
            break;
          default:
            {
              _color = Colors.grey;
            }
        }

        LatLng LatLngBanco =
            LatLng(double.parse(banco[i].Lat), double.parse(banco[i].Long));

        markerDb.add(Marker(
          width: 150.0,
          height: 150.0,
          point: LatLngBanco,
          builder: (ctx) => GestureDetector(
            onTap: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                  title: Row(
                    children: <Widget>[
                      Icon(Icons.location_on_rounded),
                      Flexible(
                        child: Text(
                          banco[i].Nome,
                        ),
                      ),
                    ],
                  ),
                  content: Row(
                    children: <Widget>[
                      Icon(Icons.route_rounded),
                      Flexible(
                        child: FutureBuilder(
                            future: Future.delayed(Duration(seconds: 1)).then(
                                (value) => calculoRota(
                                    double.parse(banco[i].Lat),
                                    double.parse(banco[i].Long),
                                    lat_final,
                                    lng_final)),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                final double distance = snapshot.data;

                                String distanciaString = '';
                                double distanciaKm = 0.0;
                                double distanciaConvertida = 0.0;

                                if (distance >= 1) {
                                  distanciaKm = distance;
                                  distanciaConvertida = double.parse(
                                      distanciaKm.toStringAsFixed(2));
                                  distanciaString =
                                      ' ${distanciaConvertida.toDouble()} KM';
                                } else {
                                  num distanciaConvertida = num.parse(
                                      distance.toStringAsPrecision(1));
                                  distanciaString =
                                      '${distance.toInt()} Metros';
                                }

                                return Text(
                                  distanciaString,
                                  style: TextStyle(fontSize: 20),
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                  softWrap: false,
                                );
                              } else {
                                return SizedBox(
                                  height: 80,
                                  width: 300,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      Text('Calculando distância'),
                                    ],
                                  ),
                                );
                              }
                            }),
                      )
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Fechar'),
                      child: const Text('Fechar'),
                    ),
                    TextButton(
                      onPressed: () {
                        lat_final = double.parse(banco[i].Lat);
                        lng_final = double.parse(banco[i].Long);
                        if (rastreio.value != true) {
                          atualyPosition();
                        }
                        routeHelper();
                        Navigator.pop(context, 'Fechar');
                      },
                      child: const Text('IR'),
                    ),
                  ]),
            ),
            child: Icon(
              Icons.location_on,
              color: _color,
              size: 30.0,
            ),
          ),
        ));
      }
    } catch (e) {
      print('*******************');
      print(e);
      print('*******************');
    } finally {
      setState(() {});
    }
  }

  PesquisaIcone() async {
    final favoritosDao _dao = favoritosDao();
    Future<List<redistro_favoritos>> ListaDao = _dao.findAll_favoritos();
    return ListaDao;
  }

  PesquisaCategoria() async {
    final categoriaDao _dao = categoriaDao();
    Future<List<registro_categoria>> ListaDao = _dao.findAll_categoria();

    return ListaDao;
  }
}
