import 'dart:async';
import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/Calculo_de_rota.dart';
import 'package:localiza_favoritos/componentes/cacche_disco.dart';
import 'package:localiza_favoritos/database/DAO/categoria_dao.dart';
import 'package:localiza_favoritos/models/pesquisa_categoria.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
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
  List<registro_categoria> bancoCategoria = [];
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
    var _needLoadingError = true;

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
                plugins: [],
                slideOnBoundaries: true,
                screenSize: MediaQuery.of(context).size,
              ),
              layers: [
                TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                    //tileProvider:  CachedNetworkTileProvider(),
                     updateInterval: 1,
                    errorTileCallback: (Tile tile, error) {
                      if (_needLoadingError) {
                        WidgetsBinding.instance!.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                    }),
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
            child: FloatingActionButton.extended(
              heroTag: 'rota',
              elevation: 50,
              backgroundColor: Colors.deepOrangeAccent,
              onPressed: () {
                String xe =
                    'Latitude: ${currentCenter.latitude} , Longitude: ${currentCenter.longitude}';
                print(xe);

                if (rastreio.value == true) {
                  atualyPosition();
                }

                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => rota(currentCenter),
                    ));
              },
              icon: Transform.rotate(
                angle: 150 * pi / 100,
                child: Icon(Icons.send_outlined),
              ),
              label: Text('Navegar'),
            ),
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

        double distanciaMetros = await pegaDistanciaDOisPontos(
            double.parse(banco[i].Lat), double.parse(banco[i].Long));

        if (distanciaMetros >= 1000) {
          distanciaKm = distanciaMetros / 1000;
          distancia_convertida = double.parse(distanciaKm.toStringAsFixed(2));
          distanciaString = ' ${distancia_convertida.toDouble()} KM';
        } else {
          num distancia_convertida =
              num.parse(distanciaMetros.toStringAsPrecision(1));
          distanciaString = '${distanciaMetros.toInt()} Metros';
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
                        child: FutureBuilder(
                            future: Future.delayed(Duration(seconds: 1)).then(
                                (value) => calculoRota(
                                    double.parse(banco[i].Lat),
                                    double.parse(banco[i].Long),
                                    currentCenter.latitude,
                                    currentCenter.longitude)),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                final double distance = snapshot.data;

                                String distanciaString = '';
                                double distanciaKm = 0.0;
                                double distancia_convertida = 0.0;

                                if (distance >= 1) {
                                  distanciaKm = distance;
                                  distancia_convertida = double.parse(
                                      distanciaKm.toStringAsFixed(2));
                                  distanciaString =
                                      ' ${distancia_convertida.toDouble()} KM';
                                } else {
                                  num distancia_convertida = num.parse(
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
                        String xe =
                            'Latitude: ${banco[i].Lat} , Longitude: ${banco[i].Long}';
                        print(xe);
                        if (rastreio.value == true) {
                          atualyPosition();
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => rota(LatLng(
                                  double.parse(banco[i].Lat),
                                  double.parse(banco[i].Long))),
                            ));
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

  void addMarkerDbTracker() async {
    try {
      bancoCategoria = await PesquisaCategoria();
      banco = await PesquisaIcone();

      for (int i = 0; i < banco.length; i++) {
        late Color _color = Colors.black;
        late String cor = '';
        for (int x = 0; x < bancoCategoria.length; x++) {
          if (bancoCategoria[x].id_categoria == banco[i].id_categoria) {
            cor = bancoCategoria[x].cor_categoria;
          }
        }
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
          distanciaString = '${distancia_convertida.toDouble()} KM';
        } else {
          num distancia_convertida =
              num.parse(distanciaMetros.toStringAsPrecision(1));
          distanciaString = '${distanciaMetros.toInt()} Metros';
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

        markerDb.add(Marker(
          width: 150.0,
          height: 150.0,
          point: LatLngBanco,
          builder: (ctx) => GestureDetector(
            onTap: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                  title: Row(children: [
                    Icon(Icons.location_on_rounded),
                    Text(banco[i].Nome)
                  ]),
                  content: Row(
                    children: [
                      Icon(Icons.earbuds_outlined),
                      Text(distanciaString, style: TextStyle(fontSize: 20)),
                    ],
                  ),
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

  PesquisaCategoria() async {
    final categoriaDao _dao = categoriaDao();
    Future<List<registro_categoria>> Lista_dao = _dao.findAll_categoria();

    return Lista_dao;
  }
}
