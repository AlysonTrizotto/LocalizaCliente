import 'dart:math' show sin, cos, sqrt, atan2;
import 'package:vector_math/vector_math.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Position? _currentPosition;
double earthRadius = 6371000;

Geolocator geoLocator = new Geolocator();

pegaDistanciaDOisPontos(double pInit, double pFin) async {
  _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  print(_currentPosition);
  var distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude, _currentPosition!.longitude, pInit, pFin);
  //print(distanceInMeters);
  return distanceInMeters.toDouble();
}

pegaLocalizacao() async {
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

pegaDistancia(double pLat, double pLong, double fLat, double fLong) async {
  double distanceInMeters =
      Geolocator.distanceBetween(pLat, pLong, fLat, fLong);
  return distanceInMeters;
}

direcao_geo() {
  return _currentPosition?.heading ?? 0.0;
}
