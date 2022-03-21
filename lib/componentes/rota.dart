import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geocoder2/geocoder2.dart';

import 'package:latlong2/latlong.dart';
import 'package:localiza_favoritos/componentes/Calculo_de_rota.dart';
import 'package:localiza_favoritos/database/DAO/categoria_dao.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_categoria.dart';
import 'package:localiza_favoritos/models/pesquisa_cliente.dart';
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
  final LatLng latLng;
  RotaState(this.latLng);
  double lat_final = 0.0;
  double lng_final = 0.0;

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
  List<Marker> markerDb = [];
  List<Marker> markersTracker = [];
  List<redistro_favoritos> banco = [];
  List<registro_categoria> bancoCategoria = [];

  String? _error;
  /**************************************************/

  /*****************Notifier*************************/
  ValueNotifier<bool> rastreio = ValueNotifier(false);
  ValueNotifier<bool> btnNavegar = ValueNotifier(false);
  ValueNotifier<bool> containerRota = ValueNotifier(true);
  ValueNotifier<String> distanciaRota = ValueNotifier('0 KM');
  ValueNotifier<String> tempoRota = ValueNotifier('00:00');

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
          child: Stack(
            children: [
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
                                  Icons.turn_left,
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
              ),
              Positioned(
                top: 130.0,
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
                                        pesquisa =
                                            controladorCampoPesquisa.text;
                                        if (pesquisa.length > 3) {
                                          print(pesquisa);
                                          estadoBtnNavegarFalse();
                                        }
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
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
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
                                                  lat_final = lat;
                                                  lng_final = long;
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
            ],
          ),
        ),
      ),
    );
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

    atualyPosition();

    List<LngLat> waypoints = [
      LngLat(lat: lat_final, lng: lng_final),
      LngLat(lat: latLng.latitude, lng: latLng.longitude),
    ];

    print(
        'lat: ${lat_final}, lng: ${lng_final} - lat: ${latLng.latitude}, lng: ${latLng.longitude}');

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

    print(road.instructions.toString());

    String distanciaString = '';
    double distanciaKm = 0.0;
    double distancia_convertida = 0.0;
    if (road.distance >= 1) {
      distanciaKm = road.distance;
      distancia_convertida = double.parse(distanciaKm.toStringAsFixed(2));
      distanciaString = ' ${distancia_convertida.toDouble()} KM';
    } else {
      num distancia_convertida =
          num.parse(road.distance.toStringAsPrecision(1));
      distanciaString = '${road.distance.toInt()} Metros';
    }
    distanciaRota.value = distanciaString;
    tempoRota.value = getStringToTime(road.duration);

    List<RoadInstruction> listaDirecao = road.instructions;

    for (int d = 0; d < listaDirecao.length; d++) {
      print(listaDirecao[d].location);
      if(listaDirecao[d].location.lat != currentCenter.latitude){

      }
      print(listaDirecao[d].instruction);
      print(listaDirecao[d].distance);
    }
    List resultado = decodePolyline(road.polylineEncoded.toString());

    setState(() {
      for (int x = 0; x < resultado.length; x++) {
        List passagem = resultado[x];
        points.add(LatLng(passagem[0], passagem[1]));
      }
    });
  }

  String getStringToTime(double valor) {
    if (valor < 0) return 'Tempo inválido';

    valor = valor / 60;

    int flooredValue = valor.floor();
    double decimalValor = valor - flooredValue;
    String hourValor = getHourString(flooredValue);
    String minuteString = getMinuteString(decimalValor);

    print('${hourValor}:${minuteString} min');

    return '${hourValor}:${minuteString} min';
  }

  String getMinuteString(double decimalValue) {
    return '${(decimalValue / 60).toInt()}'.padLeft(2, '0');
  }

  String getHourString(int flooredValue) {
    return '${flooredValue % 24}'.padLeft(2, '0');
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
            double? rotacao = currentLocation.heading;
            mapController.move(currentCenter, 10);
            print(rotacao);
            addMarkerTracker(currentCenter);
            removeMarkerDb();
            addMarkerDbTracker();
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

        String distanciaString = '';
        double distanciaKm = 0.0;
        double distancia_convertida = 0.0;

        LatLng LatLngBanco =
            LatLng(double.parse(banco[i].Lat), double.parse(banco[i].Long));

        List<LngLat> waypoints = [
          LngLat(
              lat: double.parse(banco[i].Lat),
              lng: double.parse(banco[i].Long)),
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

        if (road.distance >= 1) {
          distanciaKm = road.distance;
          distancia_convertida = double.parse(distanciaKm.toStringAsFixed(2));
          distanciaString = ' ${distancia_convertida.toDouble()} KM';
        } else {
          num distancia_convertida =
              num.parse(road.distance.toStringAsPrecision(1));
          distanciaString = '${road.distance.toInt()} Metros';
        }

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
                        child: Text(
                          distanciaString,
                          style: TextStyle(fontSize: 20),
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                        ),
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
                        String xe =
                            'Latitude: ${banco[i].Lat} , Longitude: ${banco[i].Long}';
                        lat_final = double.parse(banco[i].Lat);
                        lng_final = double.parse(banco[i].Long);
                        print(xe);
                        if (rastreio.value == true) {
                          {
                            _locationSubscription?.cancel();
                            setState(() {
                              removeMarkerTracker();
                              _locationSubscription = null;
                              estadoBtnNavegarTrue();
                            });
                          }
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
    Future<List<redistro_favoritos>> Lista_dao = _dao.findAll_favoritos();
    return Lista_dao;
  }

  PesquisaCategoria() async {
    final categoriaDao _dao = categoriaDao();
    Future<List<registro_categoria>> Lista_dao = _dao.findAll_categoria();

    return Lista_dao;
  }
}
