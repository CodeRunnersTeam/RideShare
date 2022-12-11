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

// ignore_for_file: prefer_const_literals_to_create_immutables
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:maps_demo/location_service.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:maps_demo/driver.dart';
// import 'dart:math' as math;

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Google Maps Demo',
//       home: MapSample(),
//     );
//   }
// }

// class MapSample extends StatefulWidget {
//   @override
//   State<MapSample> createState() => MapSampleState();
// }

// class MapSampleState extends State<MapSample>{
//   Completer<GoogleMapController> _controller = Completer();
//   TextEditingController _originController = TextEditingController();
//   TextEditingController _destinationController = TextEditingController();

//   Set<Marker> markers = Set<Marker>();
//   Set<Polyline> polylines = Set<Polyline>();

//   int polylineIdCounter = 5;

//   List<DRIVER> drivers = [];

//   void SetDrivers() async {
//       var directions = await LocationService().getDirections('ClujMehedinti2', 'ClujStradaAugustinPrescan');
//       DRIVER a = DRIVER(directions['polyline_decoded'], 1);
//       for(int i=0;i<a.points.length;i++){
//         print((a.points[i]).toString());
//       }
//       //directions = await LocationService().getDirections('ClujMehedinti2', 'ClujBaisoara4');
//       // DRIVER b = DRIVER(directions['polyline_decoded'], 2);
//       // directions = await LocationService().getDirections('ClujPiataMarastiM3', 'ClujRosiori9');
//       // DRIVER c = DRIVER(directions['polyline_decoded'], 3);
//       // directions = await LocationService().getDirections('ClujCaleaFloresti83', 'ClujStrAurelVlaicu140');
//       // DRIVER d = DRIVER(directions['polyline_decoded'], 4);
//     print(a.points);
//     setState(() {
//       polylines.add(a.polyline);
//       // polylines.add(b.polyline);
//       // polylines.add(c.polyline);
//       // polylines.add(d.polyline);
//       drivers.add(a);
//       // drivers.add(b);
//       // drivers.add(c);
//       // drivers.add(d);
//     });
//   }

//   static final CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(46.78276966997471, 23.607699572370617),
//     zoom: 17.4746,
//   );

//   @override
//   void initState(){
//     super.initState();
//     try{
//       SetDrivers();
//     }catch(e){
//       print(e);
//     }
//     _setMarker(LatLng(46.78276966997471, 23.607699572370617), '1');

    
//   }

//   void _setMarker(LatLng point, String suffix){
//     setState(() {
//       markers.add(
//         Marker(markerId: MarkerId('marker_$suffix'), position: point),
//       );
//     });
//   }


//   void _setPolylines(List<PointLatLng> points){
//     final polylineIdVal = 'polyline_$polylineIdCounter';
//     polylineIdCounter ++;

//     polylines.add(
//       Polyline(polylineId: PolylineId(polylineIdVal),
//         width: 2,
//         color: Colors.blue,
//         points: points.map((point) => LatLng(point.latitude, point.longitude)).toList(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ignore: unnecessary_new
//     return new Scaffold(
//       appBar: AppBar(title: Text('Google Maps Demo')),
//       body: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: _originController,
//                       textCapitalization: TextCapitalization.words,
//                       decoration: InputDecoration(hintText: ' Origin'),
//                     ),
//                     TextFormField(
//                       controller: _destinationController,
//                       textCapitalization: TextCapitalization.words,
//                       decoration: InputDecoration(hintText: ' Destination'),
//                     )
//                   ],
//                 ),
//               ),
//               IconButton(
//                 onPressed: () async {
//                   var directions = await LocationService().getDirections(_originController.text, _destinationController.text);
//                   // var place = await LocationService().getPlace(_searchController.text);
//                   _goToPlace(
//                     directions['start_location'], 
//                     directions['end_location'],
//                     directions['bounds_ne'],
//                     directions['bounds_sw']
//                   );

//                   _setPolylines(directions['polyline_decoded']);

//                   // for(int i=0;i<drivers.length;i++){
//                   //   bool start = false, end = false;
//                   //   for(int j=0;j<drivers[i].points.length;j++){
//                   //       int dist1 = degreeToM(
//                   //           drivers[i].points[j].latitude,
//                   //           drivers[i].points[j].longitude,
//                   //           directions['start_location']['lat'],
//                   //           directions['start_location']['lng']
//                   //       );
//                   //       int dist2 = degreeToM(
//                   //           drivers[i].points[j].latitude,
//                   //           drivers[i].points[j].longitude,
//                   //           directions['end_location']['lat'],
//                   //           directions['end_location']['lng']
//                   //       );
//                   //       if(dist1<501){
//                   //          start = true;
//                   //       }
//                   //       if(dist2<501){
//                   //           end = true;
//                   //       }
//                   //       if(start == true && end==true){
//                   //         print("Driver $i is gangsta");
//                   //         break;
//                   //        }
//                   //     }
//                   //   }
//                 }, 
//                 icon: Icon(Icons.search)
//               ),
//             ],
//           ),
//           Expanded(
//             child: GoogleMap(
//               markers: markers,
//               polylines: polylines,
//               initialCameraPosition: _kGooglePlex,
//               onMapCreated: (GoogleMapController controller) {
//                 _controller.complete(controller);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _goToPlace(Map<String, dynamic> origin, Map<String, dynamic> destination, Map<String, dynamic> boundsNE, Map<String, dynamic> boundsSW) async {
//     // final double lat = place['geometry']['location']['lat'];
//     // final double lng = place['geometry']['location']['lng'];
//     final GoogleMapController controller = await _controller.future;
//     controller.animateCamera(CameraUpdate.newCameraPosition(
//       CameraPosition(target: LatLng(destination['lat'], destination['lng']), zoom: 15),
//     ));

//     controller.animateCamera(
//       CameraUpdate.newLatLngBounds(
//         LatLngBounds(
//           southwest: LatLng(boundsSW['lat'], boundsSW['lng']), 
//           northeast: LatLng(boundsNE['lat'], boundsNE['lng']),
//           ),
//           25),
//     );
//     print(degreeToM(destination['lat'], destination['lng'], origin['lat'], origin['lng']));
//     print(LatLng(destination['lat'], destination['lng']));
//     print(LatLng(origin['lat'], origin['lng']));
//     _setMarker(LatLng(destination['lat'], destination['lng']), 'D');
//     _setMarker(LatLng(origin['lat'], origin['lng']), 'O');
//   }

// }

// int degreeToM(lat1, lon1, lat2, lon2){  // generally used geo measurement function
//     var R = 6378.137;
//     var pi = math.pi; // Radius of earth in KM
//     var dLat = lat2 * pi / 180 - lat1 * pi / 180;
//     var dLon = lon2 * pi / 180 - lon1 * pi / 180;
//     var a = math.sin(dLat/2) * math.sin(dLat/2) +
//     math.cos(lat1 * pi / 180) * math.cos(lat2 * pi / 180) *
//     math.sin(dLon/2) * math.sin(dLon/2);
//     var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a));
//     var d = R * c;
//     return (d * 1000).toInt(); // meters
// }



















// Row(children: [
          //   Expanded(child: TextFormField(
          //     controller: _searchController,
          //     textCapitalization: TextCapitalization.words,
          //     decoration: InputDecoration(hintText: 'Search location'),
          //     onChanged: (value) {
          //       print(value);
          //     },
          //   )),
          //   IconButton(
          //     onPressed: () async {
          //       var place = await LocationService().getPlace(_searchController.text);
          //       _goToPlace(place);
          //     }, 
          //     icon: Icon(Icons.search)
          //   ),
          // ],),


// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   late GoogleMapController mapController;

//   final LatLng _center = const LatLng(46.78276966997471, 23.607699572370617);

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Maps Sample App'),
//           backgroundColor: Colors.green[700],
//         ),
//         body: GoogleMap(
//           onMapCreated: _onMapCreated,
//           initialCameraPosition: CameraPosition(
//             target: _center,
//             zoom: 17.0,
//           ),
//         ),
//       ),
//     );
//   }
// }

////////////////////////////////////
///
///
// /void SetDrivers() async {
//       var directions = await LocationService().getDirections('ClujMehedinti2', 'ClujStradaAugustinPrescan');
//       DRIVER a = DRIVER(directions['polyline_decoded'], 1);
//       directions = await LocationService().getDirections('ClujMehedinti2', 'ClujBaisoara4');
//       DRIVER b = DRIVER(directions['polyline_decoded'], 2);
//       directions = await LocationService().getDirections('ClujPiataMarastiM3', 'ClujRosiori9');
//       DRIVER c = DRIVER(directions['polyline_decoded'], 3);
//       directions = await LocationService().getDirections('ClujCaleaFloresti83', 'ClujStrAurelVlaicu140');
//       DRIVER d = DRIVER(directions['polyline_decoded'], 4);
//       directions = await LocationService().getDirections('ClujStrGrapei4', 'ClujAleeaBorsec3');
//       DRIVER e = DRIVER(directions['polyline_decoded'], 5);
//       directions = await LocationService().getDirections('ClujStrTransilvaniei225', 'ClujStrMunteniei');
//       DRIVER f = DRIVER(directions['polyline_decoded'], 6);
//       directions = await LocationService().getDirections('ClujStrCampina31', 'ClujBulevardulMuncii241');
//       DRIVER g = DRIVER(directions['polyline_decoded'], 7);
//       directions = await LocationService().getDirections('ClujStrFabriciidechibrituri5', 'ClujCaleaTurzii48');
//       DRIVER h = DRIVER(directions['polyline_decoded'], 8);
//       directions = await LocationService().getDirections('ClujStrDonath166', 'ClujStrLunii1');
//       DRIVER i = DRIVER(directions['polyline_decoded'], 9);
//       directions = await LocationService().getDirections('Bucuresti', 'Oradea');
//       DRIVER j = DRIVER(directions['polyline_decoded'], 10);

//     setState(() async {
//       polylines.add(a.polyline);
//       polylines.add(b.polyline);
//       polylines.add(c.polyline);
//       polylines.add(d.polyline);
//       polylines.add(e.polyline);
//       polylines.add(f.polyline);
//       polylines.add(g.polyline);
//       polylines.add(h.polyline);
//       polylines.add(i.polyline);
//       polylines.add(j.polyline);
//       drivers.add(a);
//       drivers.add(b);
//       drivers.add(c);
//       drivers.add(d);
//       drivers.add(e);
//       drivers.add(f);
//       drivers.add(g);
//       drivers.add(h);
//       drivers.add(i);
//       drivers.add(j);
//     });
//   }