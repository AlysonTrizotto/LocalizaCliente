import 'dart:math' show sin, cos, sqrt, atan2;
import 'package:vector_math/vector_math.dart';
import 'package:geolocator/geolocator.dart';

Position? _currentPosition;
double earthRadius = 6371000;

Geolocator geoLocator = new Geolocator();

pegaDistanciaDOisPontos(double pInit, double pFin) async {
  _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  
  double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude, _currentPosition!.longitude, pInit, pFin);
  
  return distanceInMeters;
}

pegaDistancia(double pLat, double pLong, double fLat, double fLong) async {
    double distanceInMeters = Geolocator.distanceBetween(
      pLat, pLong, fLat, fLong);
  
  return distanceInMeters;
}


/*
//Calculating the distance between two points without Geolocator plugin
getDistance(double pLat, double pLng) {
  var dLat = radians(pLat - _currentPosition!.latitude);
  var dLng = radians(pLng - _currentPosition!.longitude);
  var a = sin(dLat / 2) * sin(dLat / 2) +
      cos(radians(_currentPosition!.latitude)) *
          cos(radians(pLat)) *
          sin(dLng / 2) *
          sin(dLng / 2);
  var c = 2 * atan2(sqrt(a), sqrt(1 - a));
  var d = earthRadius * c;
  print(d); //d is the distance in meters
}

//Calculating the distance between two points with Geolocator plugin
getDistanceTwoPoint(double? pLat, double? pLng, double fLat, double fLng) {
  if (pLat == 0.0) {
    getUserLocation();
    pLat = _currentPosition!.latitude;
    pLng = _currentPosition!.longitude;
  }
  final double distance = Geolocator.distanceBetween(pLat!, pLng!, fLat, fLng);
  print(distance);
}
*/
