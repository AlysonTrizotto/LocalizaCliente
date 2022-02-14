import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:localiza_favoritos/componentes/edit_text_geral.dart';

//Declarando o MapCOntroler
class Mapas extends StatelessWidget with OSMMixinObserver {
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
  late GlobalKey<ScaffoldState> scaffoldKey;
  ValueNotifier<GeoPoint?> lastGeoPoint = ValueNotifier(null);
  late GeoPoint lastMarkPosition =
      GeoPoint(latitude: 47.4358055, longitude: 8.4737384);
  ValueNotifier<bool> rastreio = ValueNotifier(false);
  ValueNotifier<IconData> IconeRastreio = ValueNotifier(Icons.my_location);
  Timer? timer;

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
            image: AssetImage("asset/pin.png"),
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
    ;
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Color(0xFF101427),
          onPressed: () async {
            mapController.zoomIn();
          },
          mini: true,
        ),
        FloatingActionButton(
          child: Icon(Icons.remove),
          backgroundColor: Color(0xFF101427),
          onPressed: () async {
            mapController.zoomOut();
          },
          mini: true,
        ),
        FloatingActionButton(
          backgroundColor: Color(0xFF101427),
          onPressed: () async {
            atualyPosition();
          },
          child: ValueListenableBuilder<bool>(
            valueListenable: rastreio,
            builder: (ctx, isTracking, _) {
              if (isTracking) {
                return Icon(Icons.my_location, color: Colors.white,);
                
              }
              return Icon(Icons.gps_off_sharp, color: Colors.deepOrangeAccent);
            },
          ),
        ),
        
      ]),
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
                  Icons.send,
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
         ]),
      ),
    );
  }

 
  Future<List> Address(String endereco)async{
    List<SearchInfo> suggestions = await addressSuggestion(endereco);
    return suggestions.toList();
  }

  Future<void> locationChabge() async {
    await mapController
        .goToLocation(GeoPoint(latitude: 47.35387, longitude: 8.43609));
  }

  Future<void> getCenterMap() async {
    GeoPoint centerMap = await mapController.centerMap;
  }

  Future<void> atualyPosition() async {
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

  Future<void> geoPoint() async {}
}
