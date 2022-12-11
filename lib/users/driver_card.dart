import 'package:flutter/material.dart';

class Driver {
  int id;
  String name;
  Driver(this.id, this.name);
}

class DriversList extends StatefulWidget {
  const DriversList({super.key, required this.title});
  final String title;
  @override
  _DriversList createState() => _DriversList();
}

class _DriversList extends State<DriversList> {
  final List<Driver> drivers = [
    Driver(1, "Rares"),
    Driver(2, "Mester"),
    Driver(3, "Tudor"),
    Driver(4, "Vlad"),
    Driver(5, "Dorin"),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.amber,
      ),
      body: ListView(
        children: drivers.map((st) {
          return Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: GestureDetector(
                    onTap: () {
                      print("container touch ${st.id}");
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        st.name,
                        style: TextStyle(fontSize: 40),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}