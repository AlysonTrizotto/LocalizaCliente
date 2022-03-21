import 'package:routing_client_dart/routing_client_dart.dart';

Future<double> calculoRota(
    double lat_ini, double long_ini, double lat_final, double lng_final) async {
  List<LngLat> waypoints = [
    LngLat(lat: lat_final, lng: lng_final),
    LngLat(lat: lat_ini, lng: long_ini),
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
  return road.distance;

}
