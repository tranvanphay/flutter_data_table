import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:demo_data_table/model/product.dart';
import 'package:demo_data_table/widget/small_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Example without datasource
class DataTable2SimpleDemo extends StatefulWidget {
  @override
  _DataTable2SimpleDemoState createState() => _DataTable2SimpleDemoState();
}

class _DataTable2SimpleDemoState extends State<DataTable2SimpleDemo> {
  List<Product> selectedProduct = [];
  List<Product> _listProduct = [];

  final columns = [
    "Product Code",
    "Product Image",
    "Product Name",
    "Product Prices"
  ];

  Future<List<Product>> _loadJson() async {
    String data = await rootBundle.loadString('assets/list_product.json');
    final jsonResult = json.decode(data);
    print(jsonResult);
    return productListFromJson(jsonResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data table 2")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder(
          future: _loadJson(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
            if (snapshot.hasData) {
              _listProduct = snapshot.data!;
              return DataTable2(
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 600,
                  columns: getColumns(columns),
                  rows: getRows(_listProduct));
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  List<DataRow> getRows(List<Product> products) => products
      .map((Product product) => DataRow(cells: [
            DataCell(Text(product.productCode)),
            DataCell(SmallImg(url: product.productImage)),
            DataCell(Text(product.productName)),
            DataCell(Text(product.productPrices)),
          ]))
      .toList();

  List<DataColumn> getColumns(List<String> columns) =>
      columns.map((String column) => DataColumn(label: Text(column))).toList();
}
