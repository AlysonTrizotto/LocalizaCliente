import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:intl/intl.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

import 'package:localiza_favoritos/componentes/search.dart';
import 'package:localiza_favoritos/componentes/nethort_help.dart';
import 'package:localiza_favoritos/componentes/rota.dart';
import 'package:localiza_favoritos/database/DAO/favoritos_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_cliente.dart';
import 'package:localiza_favoritos/screens/cadastro/formulario_favoritos.dart';

class mapa extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MapaState();
  }
}

class MapaState extends State<mapa> {
  /********************variveis********************/
  double long = 106.816666;
  double lat = -6.200000;
  double zoom = 15.0;
  double rotation = 0.0;
  late double zoomAtual = 5.0;
  LatLng currentCenter = LatLng(51.5, -0.09);
  LatLng point = LatLng(-6.200000, 106.816666);
  final FitBoundsOptions options =
      const FitBoundsOptions(padding: EdgeInsets.all(12.0));
  late String pesquisa = '';
  List<Marker> markers = [];
  List<Marker> markerDb = [];
  List<Marker> markersTracker = [];
  List<redistro_favoritos> banco = [];
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

  /**************************************************/

  @override
  void initState() {
    super.initState();
    getCurrentLocation();

    addMarkerDb();
  }

  late int quantidade = 0;

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

    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa'),
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
                  onTap: (k, latlng) {
                    removeMarker();
                    setState(() {
                      addMarker(latlng);
                    });
                  },
                  plugins: []),
              layers: [
                TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c']),
                MarkerLayerOptions(markers: [
                  for (int i = 0; i < markers.length; i++) markers[i]
                ]),
                MarkerLayerOptions(markers: [
                  for (int i = 0; i < markerDb.length; i++) markerDb[i]
                ]),
                MarkerLayerOptions(markers: [
                  for (int i = 0; i < markersTracker.length; i++)
                    markersTracker[i],
                ]),
              ]),
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => rota(currentCenter),
                      ));
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
            bottom: 30.0,
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

  void erroServidor(String err) {
    print('Servidor temporáriamente indisponível');
  }

  void removeMarker() {
    try {
      markers.clear();
    } catch (e) {
      print("************************\n");
      print(e);
      print("\n************************");
    }
  }

  void addMarker(LatLng latlng) {
    try {
      currentCenter = latlng;
      markers.add(
        Marker(
          width: 150.0,
          height: 150.0,
          point: currentCenter,
          builder: (ctx) => GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return FormularioCadastro(
                    currentCenter.latitude, currentCenter.longitude);
              })).then((value) => addMarkerDb());
            },
            child: Icon(
              Icons.location_on,
              color: Colors.red,
              size: 35.0,
            ),
          ),
        ),
      );
    } catch (e) {
      print('*******************');
      print(e);
      print('*******************');
    }
  }

  void removeMarkerTracker() {
    try {
      markersTracker.clear();
    } catch (e) {
      print("************************\n");
      print(e);
      print("\n************************");
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
      print('*******************');
      print(e);
      print('*******************');
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

  void addMarkerDb() async {
    try {
      banco = await PesquisaIcone();
      for (int i = 0; i < banco.length; i++) {
        String distanciaString = '';
        double distanciaKm = 0.0;
        double distancia_convertida = 0.0;

        LatLng LatLngBanco =
            LatLng(double.parse(banco[i].Lat), double.parse(banco[i].Long));

        double distanciaMetros = await pegaDistanciaDOisPontos(
            double.parse(banco[i].Lat), double.parse(banco[i].Long));

        if (distanciaMetros >= 1000) {
          distanciaKm = distanciaMetros / 1000;
          distancia_convertida = double.parse(distanciaKm.toStringAsFixed(2));
          distanciaString = 'Distância: ${distancia_convertida.toDouble()} KM';

          print('++++++++distancia+++++++');
          print(distanciaString);
        } else {
          num distancia_convertida =
              num.parse(distanciaMetros.toStringAsPrecision(1));
          distanciaString = 'Distância: ${distanciaMetros.toInt()} Metros';
          print('++++++++distancia+++++++');
          print(distanciaMetros);
        }

        markerDb.add(Marker(
          width: 150.0,
          height: 150.0,
          point: LatLngBanco,
          builder: (ctx) => GestureDetector(
            onTap: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                  title: Text('Ponto: ' + banco[i].Nome),
                  content:
                      Text(distanciaString, style: TextStyle(fontSize: 20)),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Fechar'),
                      child: const Text('Fechar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'IR'),
                      child: const Text('IR'),
                    ),
                  ]),
            ),
            child: Icon(
              Icons.location_on,
              color: Colors.teal,
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
      print('Passou pelo setState');
    }
  }

  void addMarkerDbTracker() async {
    try {
      banco = await PesquisaIcone();
      for (int i = 0; i < banco.length; i++) {
        String distanciaString = '';
        double distanciaKm = 0.0;
        double distancia_convertida = 0.0;

        LatLng LatLngBanco =
            LatLng(double.parse(banco[i].Lat), double.parse(banco[i].Long));

        double distanciaMetros = await pegaDistancia(
            currentCenter.latitude,
            currentCenter.longitude,
            double.parse(banco[i].Lat),
            double.parse(banco[i].Long));

        if (distanciaMetros >= 1000) {
          distanciaKm = distanciaMetros / 1000;
          distancia_convertida = double.parse(distanciaKm.toStringAsFixed(2));
          distanciaString = 'Distância: ${distancia_convertida.toDouble()} KM';

          print('++++++++distancia+++++++');
          print(distanciaString);
        } else {
          num distancia_convertida =
              num.parse(distanciaMetros.toStringAsPrecision(1));
          distanciaString = 'Distância: ${distanciaMetros.toInt()} Metros';
          print('++++++++distancia+++++++');
          print(distanciaMetros);
        }

        markerDb.add(Marker(
          width: 150.0,
          height: 150.0,
          point: LatLngBanco,
          builder: (ctx) => GestureDetector(
            onTap: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                  title: Text('Ponto: ' + banco[i].Nome),
                  content:
                      Text(distanciaString, style: TextStyle(fontSize: 20)),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Fechar'),
                      child: const Text('Fechar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'IR'),
                      child: const Text('IR'),
                    ),
                  ]),
            ),
            child: Icon(
              Icons.location_on,
              color: Colors.teal,
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
      print('Passou pelo setState');
    }
  }

  void _zoomOut() {
    try {
      var bounds = mapController.bounds;
      var centerZoom = mapController.center;
      var zoom = mapController.zoom - 0.5;
      if (zoom < 3) {
        zoom = 3;
      }
      mapController.move(centerZoom, zoom);
    } catch (e) {
      print('************');
      print(e);
      print('************');
    }
  }

  void _zoomIn() {
    try {
      var bounds = mapController.bounds;
      var centerZoom = mapController.center;
      var zoom = mapController.zoom + 0.5;
      if (zoom < 3) {
        zoom = 3;
      }
      mapController.move(centerZoom, zoom);
    } catch (e) {
      print('**************');
      print(e);
      print('**************');
    }
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
            mapController.move(currentCenter, 17);
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
      print("************************\n");
      print(e);
      print("\n************************");
    }
  }

  Future<void> adicionaMarcador(double lat, double long) async {
    try {
      currentCenter = LatLng(lat, long);
      removeMarker();
      addMarker(currentCenter);
      mapController.move(currentCenter, 16);
    } catch (e) {
      print("*******Movendo mapa*******\n");
      print(e);
      print(
          "\n***lat: ${lat.toString()}********long: ${long.toString()}*************");
    }
  }

  PesquisaIcone() async {
    final favoritosDao _dao = favoritosDao();
    Future<List<redistro_favoritos>> Lista_dao = _dao.findAll_favoritos();
    return Lista_dao;
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