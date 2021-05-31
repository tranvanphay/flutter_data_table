/// Flutter code sample for DataTable

// This sample shows how to display a [DataTable] with alternate colors per
// row, and a custom color for when the row is selected.

import 'dart:convert';
import 'dart:ffi';

import 'package:demo_data_table/model/product.dart';
import 'package:demo_data_table/widget/small_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DataTableDemo extends StatelessWidget {
  List<Product> _listProduct = [];
  static const String _title = 'Flutter Code Sample';

  Future<List<Product>> _loadJson() async {
    String data = await rootBundle.loadString('assets/list_product.json');
    final jsonResult = json.decode(data);
    print(jsonResult);
    return productListFromJson(jsonResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(_title)),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: BouncingScrollPhysics(),
        child: Center(
          child: FutureBuilder(
              future: _loadJson(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Product>> snapshot) {
                if (snapshot.hasData) {
                  _listProduct = snapshot.data!;
                  return DataTableDemoWidget(products: _listProduct);
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ),
      ),
    );
  }
}

class DataTableDemoWidget extends StatefulWidget {
  List<Product> products;

  DataTableDemoWidget({required this.products});

  @override
  State<DataTableDemoWidget> createState() =>
      _DataTableDemoState(products: products);
}

class _DataTableDemoState extends State<DataTableDemoWidget> {
  List<Product> products;
  _DataTableDemoState({required this.products});
  List<Product> selectedProduct = [];
  final columns = [
    "Product Code",
    "Product Image",
    "Product Name",
    "Product Prices"
  ];

  @override
  void initState() {
    super.initState();
    // selected = List<Product>.generate(
    //     products.isEmpty ? products.length : 0, (int index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        columns: getColumns(columns),
        rows: getRows(products),
      ),
    );
  }

  List<DataRow> getRows(List<Product> products) => products
      .map((Product product) => DataRow(
              selected: selectedProduct.contains(product),
              onSelectChanged: (isSelected) => setState(() {
                    final isAdding = isSelected != null && isSelected;
                    isAdding
                        ? selectedProduct.add(product)
                        : selectedProduct.remove(product);
                  }),
              cells: [
                DataCell(Text(product.productCode)),
                DataCell(SmallImg(url: product.productImage)),
                DataCell(Text(product.productName)),
                DataCell(Text(product.productPrices)),
              ]))
      .toList();

  List<DataColumn> getColumns(List<String> columns) =>
      columns.map((String column) => DataColumn(label: Text(column))).toList();
}
