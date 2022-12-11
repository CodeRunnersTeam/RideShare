import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/material.dart';

class DRIVER {

  late List<PointLatLng> directions;
  late int driverId;
  late List<LatLng> points;
  late Polyline polyline; 
  late LatLng end_point;

  DRIVER ( this.directions, this.driverId){
    final polylineIdVal = 'polyline_$driverId';
    this.points = directions.map((point) => LatLng(point.latitude, point.longitude)).toList();
    polyline = Polyline(polylineId: PolylineId(polylineIdVal), width: 2, points: this.points);
    //print((points).toString());
    ///debugPrint('$points');
  }

}