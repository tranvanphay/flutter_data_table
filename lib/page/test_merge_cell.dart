import 'package:flutter/material.dart';

class TestMergeCell extends StatefulWidget {
  @override
  _TestMergeCellState createState() => _TestMergeCellState();
}

class _TestMergeCellState extends State<TestMergeCell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("demo merge cell"),
      ),
      body: Row(
        children: <Widget>[
          Container(
            width: 100.0,
            color: Colors.cyan,
            child: Table(
              children: [
                TableRow(children: [
                  Container(
                    color: Colors.green,
                    width: 50.0,
                    height: 50.0,
                    child: Text("1111111111111111111111111111111111111111111"),
                  ),
                  Container(
                    color: Colors.red,
                    width: 50.0,
                    height: 50.0,
                    child: Text("2"),
                  ),
                ]),
                TableRow(children: [
                  Container(
                    color: Colors.deepPurple,
                    width: 50.0,
                    height: 50.0,
                    child: Text("5"),
                  ),
                  Container(
                    color: Colors.cyan,
                    width: 50.0,
                    height: 50.0,
                    child: Text("6"),
                  ),
                ]),
                TableRow(children: [
                  Container(
                    color: Colors.amberAccent,
                    width: 50.0,
                    height: 50.0,
                    child: Text("7"),
                  ),
                  Container(
                    color: Colors.blueAccent,
                    width: 50.0,
                    height: 50.0,
                    child: Text("8"),
                  ),
                ]),
              ],
            ),
          ),
          Container(
            width: 100.0,
            color: Colors.cyan,
            child: Table(
              columnWidths: {
                1: FractionColumnWidth(.3),
              },
              children: [
                TableRow(children: [
                  Container(
                    color: Colors.green,
                    width: 50.0,
                    height: 50.0,
                    child: Text("1111111111111111111111111111111111111111111"),
                  ),
                  Container(
                    color: Colors.red,
                    width: 50.0,
                    height: 50.0,
                    child: Text("2"),
                  ),
                ]),
                TableRow(children: [
                  Container(
                    color: Colors.deepPurple,
                    width: 50.0,
                    height: 100.0,
                    child: Text("5"),
                  ),
                  Container(
                    color: Colors.cyan,
                    width: 50.0,
                    height: 100.0,
                    child: Text("6"),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
