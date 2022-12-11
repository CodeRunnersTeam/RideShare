import 'package:flutter/material.dart';
import 'package:maps_demo/users/profile.dart';
void main() => runApp(MaterialApp(
      home: DRoutes(),
    ));

class DRoutes extends StatefulWidget {
  @override
  State<DRoutes> createState() => _DRoutesState();
}

class _DRoutesState extends State<DRoutes> {
  late bool currst = false;
  late String current;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Test'),
          centerTitle: true,
          backgroundColor: Colors.amber[600]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }
}