import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

//Declarando o MapCOntroler
class Mapas extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return 
       //Criando o básico para o mapa
          OSMFlutter(
        controller: mapController,
        trackMyPosition: false,
        initZoom: 12,
        minZoomLevel: 5,
        maxZoomLevel: 14,
        stepZoom: 1.0,
        userLocationMarker: UserLocationMaker(
          personMarker: MarkerIcon(
            icon: Icon(
              Icons.location_history_rounded,
              color: Colors.red,
              size: 48,
            ),
          ),
          directionArrowMarker: MarkerIcon(
            icon: Icon(
              Icons.double_arrow,
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
        )
      ),      
    );
  }

  void dispenca() {
    mapController.dispose();
  }

  Future<void> zoomIn() async {
    await mapController.setZoom(stepZoom: 2);
    await mapController.zoomIn();
  }

  Future<void> zoomOut() async {
    await mapController.setZoom(stepZoom: -2);
    await mapController.zoomOut();
  }

  Future<void> setZoom() async {
    await mapController.setZoom(zoomLevel: 5);
  }

  Future<void> getZoom() async {
    await mapController.getZoom();
  }
  
  Future<void> getPostitionNow() async {
    await mapController.enableTracking();
  }
  
  Future<void> disablePosition() async {
    await mapController.disabledTracking();
  }
 



}
