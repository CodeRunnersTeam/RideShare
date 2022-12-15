// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'package:maps_demo/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_demo/routes/driver_routes.dart';   //// ASTEA LE 
import 'package:maps_demo/users/driver_card.dart';
import 'dart:math' as math;
import 'package:maps_demo/users/profile.dart';

void main() => runApp(const MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    ));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Set<Marker> _markers = Set<Marker>();

  Set<Marker> driverMarkers = Set<Marker>();
  Set<Marker> passengerMarkers = Set<Marker>();

  late bool currst = false;
  late String current = currst ? 'driver' : 'passenger';
  var icoana = Icons.car_crash;

  final Completer<GoogleMapController> _controller = Completer();

  TextEditingController _originController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();

  int polylineCounter = 0;
  List<List<LatLng>> drivers = [];
  List<List<LatLng>> passengers = [];
  Set<Polyline> polylinesDriver = Set<Polyline>();
  Set<Polyline> polylinesPassenger = Set<Polyline>();
  
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(46.78276966997471, 23.607699572370617),
    zoom: 17.4746,
  );

  @override
  void initState() {
    super.initState();
  }

  void _setMarker(LatLng point, String loc) {
    setState(() {
      if ((loc == 'o')) {
        _markers.add(Marker(
            markerId: MarkerId(loc),
            position: point,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen)));
      } else {
        _markers.add(Marker(
            markerId: MarkerId(loc),
            position: point,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed)));
      }
    });
  }

  void _setPolyline(List<PointLatLng> points, bool currState) {
    final String polylineIdVal = 'polyline_$polylineCounter';
    polylineCounter++;
    if(currState){
      polylinesDriver.add(Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList(),
      ));
      drivers.add(points.map((point) => LatLng(point.latitude, point.longitude)).toList());
    }else{
        polylinesPassenger.add(Polyline(
          polylineId: PolylineId(polylineIdVal),
          width: 2,
          color: Colors.blue,
          points: points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList(),
        ));
        passengers.add(points.map((point) => LatLng(point.latitude, point.longitude)).toList());
    }
  }

  Set<Polyline> shownPolylines(bool currState){

      if(passengers.length < 1 && drivers.length < 1) return {};
      Set<Polyline> _polylines = Set<Polyline>();
      if(!currState && passengers.length > 0){
        _polylines.add(Polyline(
                  polylineId: PolylineId('PassangerLine'),
                  width: 2,
                  color: Colors.green,
                  points: passengers[passengers.length-1],
                ));
        double lat  = passengers[passengers.length-1][0].latitude;
        double lng  = passengers[passengers.length-1][0].longitude;
        double end_lat  = passengers[passengers.length-1][passengers[passengers.length-1].length-1].latitude;
        double end_lng  = passengers[passengers.length-1][passengers[passengers.length-1].length-1].longitude;

        bool start = false, end = false;

        for(int i=0;i<drivers.length;i++){
            int dist = degreeToM(
                      lat,
                      lng,
                      drivers[i][0].latitude,
                      drivers[i][0].longitude,
             );
             int dist2 = degreeToM(
                      end_lat,
                      end_lng,
                      drivers[i][drivers[i].length-1].latitude,
                      drivers[i][drivers[i].length-1].longitude,
             );
             if(dist < 750 && dist2 < 750){
                _polylines.add(Polyline(
                  polylineId: PolylineId('Driver_$i'),
                  width: 2,
                  color: Colors.blue,
                  points: drivers[i],
                ));
             }
        }
      }else{
        if(drivers.length > 0){
          _polylines.add(Polyline(
          polylineId: PolylineId('DriverLine'),
          width: 2,
          color: Colors.blue,
          points: drivers[drivers.length-1],
        ));
      }
        }
      return _polylines;
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        style: const TextStyle(fontSize: 20),
                        textCapitalization: TextCapitalization.words,
                        controller: _originController,
                        decoration: const InputDecoration(
                          hintText: ' Origin',
                          hintStyle: TextStyle(fontSize: 20.0),
                          filled: true, //<-- SEE HERE
                          fillColor: Colors.amber,
                        ),
                      ),
                      TextFormField(
                        style: const TextStyle(fontSize: 20),
                        controller: _destinationController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: ' Destination',
                          hintStyle: TextStyle(fontSize: 20.0),
                          filled: true, //<-- SEE HERE
                          fillColor: Colors.transparent,
                        ),
                      )
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      var directions = await LocationService().getDirections(
                          _originController.text, _destinationController.text);
                      _goToPlace(
                        directions['start_location']['lat'],
                        directions['start_location']['lng'],
                        directions['bounds_ne'],
                        directions['bounds_sw'],
                      );
                      
                      _setPolyline(directions['polyline_decoded'], currst);
                      _setMarker(
                          LatLng(
                            directions['end_location']['lat'],
                            directions['end_location']['lng'],
                          ),
                          'd');
                    },
                    color: Colors.amber,
                    icon: const Icon(Icons.search), iconSize: 30,),
                    
              ],
            ),
            Expanded(
              child: GoogleMap(
                mapType: MapType.normal,
                markers: _markers,
                initialCameraPosition: _kGooglePlex,
                polylines: shownPolylines(currst),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          color: Colors.grey[200],
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _markers = {};
                    currst = !currst;
                    current = currst ? '     Driver    ' : 'Passenger';
                    icoana = currst ? Icons.directions_car : Icons.people;
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.amber, // Background color
                ),
                icon: Icon(icoana, size: 24.0),
                label: Text(current),
              ),
              FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          currst ? DRoutes() : DriversList(title: "Drivers")));
                },
                backgroundColor: Colors.amber,
                child: const Icon(Icons.add),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Profile()));
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.amber, // Background color
                ),
                icon: Icon(Icons.person, size: 24.0),
                label: Text('    Profile     '),
              ),
            ],
          )),
    );
  }

  Future<void> _goToPlace(
    double lat,
    double lng,
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
  ) async {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12)));
    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng'])),
        25));
    _setMarker(LatLng(lat, lng), 'o');
  }
}

int degreeToM(lat1, lon1, lat2, lon2){  // generally used geo measurement function
    var R = 6378.137;
    var pi = math.pi; // Radius of earth in KM
    var dLat = lat2 * pi / 180 - lat1 * pi / 180;
    var dLon = lon2 * pi / 180 - lon1 * pi / 180;
    var a = math.sin(dLat/2) * math.sin(dLat/2) +
    math.cos(lat1 * pi / 180) * math.cos(lat2 * pi / 180) *
    math.sin(dLon/2) * math.sin(dLon/2);
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a));
    var d = R * c;
    return (d * 1000).toInt(); // meters
}
