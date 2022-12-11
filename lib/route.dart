import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class ROUTE {

  late var directions;
  late LatLng start_location, end_location, bounds_ne, bounds_sw; 

  late Set<Polyline> polylines = Set<Polyline>();

  int polylineIdCounter = 1;

  ROUTE ( var this.directions ) {
    _setPolylines(directions['polyline_decoded']);
    this.start_location = LatLng(this.directions['start_location']['lat'], this.directions['start_location']['lng']);
    this.end_location = LatLng(this.directions['end_location']['lat'], this.directions['end_location']['lng']);
    this.bounds_ne = LatLng(this.directions['bounds_ne']['lat'], this.directions['bounds_ne']['lng']);
    this.bounds_sw = LatLng(this.directions['bounds_sw']['lat'], this.directions['bounds_sw']['lng']);
  }

  void _setPolylines(List<PointLatLng> points){
    final polylineIdVal = 'polyline_$polylineIdCounter';
    polylineIdCounter ++;

    polylines.add(
      Polyline(polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points.map((point) => LatLng(point.latitude, point.longitude)).toList(),
      ),
    );
  }

}