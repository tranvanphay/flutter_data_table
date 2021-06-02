import 'package:demo_data_table/page/data_table.dart';
import 'package:demo_data_table/page/data_table_2.dart';
import 'package:demo_data_table/page/horizontal_data_table_demo.dart';
import 'package:demo_data_table/page/paging_data_table.dart';
import 'package:demo_data_table/page/paging_data_table_2.dart';
import 'package:demo_data_table/page/test_merge_cell.dart';
import 'package:demo_data_table/widget/base_button.dart';
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              BaseButton(
                  textButton: "Data table",
                  buttonColor: Colors.blueAccent,
                  textColor: Colors.white,
                  onPressed: (isPressed) {
                    if (isPressed) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DataTableDemo()));
                    }
                  }),
              Padding(padding: const EdgeInsets.only(top: 15)),
              BaseButton(
                  textButton: "Data table 2",
                  buttonColor: Colors.blue,
                  textColor: Colors.white,
                  onPressed: (isPressed) {
                    if (isPressed) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DataTable2SimpleDemo()));
                    }
                  }),
              Padding(padding: const EdgeInsets.only(top: 15)),
              BaseButton(
                  textButton: "Paging data table 2",
                  buttonColor: Colors.red,
                  textColor: Colors.white,
                  onPressed: (isPressed) {
                    if (isPressed) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (contextt) =>
                                  PaginatedDataTable2Demo()));
                    }
                  }),
              Padding(padding: const EdgeInsets.only(top: 10)),
              BaseButton(
                  textButton: "Paging data table",
                  buttonColor: Colors.redAccent,
                  textColor: Colors.white,
                  onPressed: (isPressed) {
                    if (isPressed) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PaginatedDataTableDemo()));
                    }
                  }),
              Padding(padding: const EdgeInsets.only(top: 10)),
              BaseButton(
                  textButton: "Horizontal data table",
                  buttonColor: Colors.yellow,
                  textColor: Colors.white,
                  onPressed: (isPressed) {
                    if (isPressed) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HorizontalDataTableDemo(
                                  title: "HorizontalDataTableDemo")));
                    }
                  }),
              Padding(padding: const EdgeInsets.only(top: 10)),
              BaseButton(
                  textButton: "Wrap Column",
                  buttonColor: Colors.yellow,
                  textColor: Colors.white,
                  onPressed: (isPressed) {
                    if (isPressed) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TestMergeCell()));
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
