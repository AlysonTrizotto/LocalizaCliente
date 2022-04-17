import 'package:routing_client_dart/routing_client_dart.dart';

Future<double> calculoRota(
    double latIni, double longIni, double latFinal, double lngFinal) async {
  List<LngLat> waypoints = [
    LngLat(lat: latFinal, lng: lngFinal),
    LngLat(lat: latIni, lng: longIni),
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
