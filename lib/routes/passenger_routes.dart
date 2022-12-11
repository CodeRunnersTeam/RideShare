import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      home: PRoutes(),
    ));

class PRoutes extends StatefulWidget {
  @override
  State<PRoutes> createState() => _PRoutesState();
}

class _PRoutesState extends State<PRoutes> {
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