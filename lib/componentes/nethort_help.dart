import 'dart:math' show sin, cos, sqrt, atan2;
import 'package:geolocator/geolocator.dart';

Position? _currentPosition;
double earthRadius = 6371000;

Geolocator geoLocator = Geolocator();

pegaDistanciaDOisPontos(double pInit, double pFin) async {
  _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  
  var distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude, _currentPosition!.longitude, pInit, pFin);
  
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

direcaoGeo() {
  return _currentPosition?.heading ?? 0.0;
}
