import 'dart:math' as math;

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'data_table_2.dart';

class PaginatedDataTable2 extends StatefulWidget {
  PaginatedDataTable2(
      {Key? key,
      this.header,
      this.actions,
      required this.columns,
      this.sortColumnIndex,
      this.sortAscending = true,
      this.onSelectAll,
      this.dataRowHeight = kMinInteractiveDimension,
      this.headingRowHeight = 56.0,
      this.horizontalMargin = 24.0,
      this.columnSpacing = 56.0,
      required this.showCheckboxColumn,
      this.showFirstLastButtons = false,
      this.initialFirstRowIndex = 0,
      this.onPageChanged,
      this.rowsPerPage = defaultRowsPerPage,
      this.availableRowsPerPage = const <int>[
        defaultRowsPerPage,
        defaultRowsPerPage * 2,
        defaultRowsPerPage * 5,
        defaultRowsPerPage * 10
      ],
      this.onRowsPerPageChanged,
      this.dragStartBehavior = DragStartBehavior.start,
      required this.source,
      this.checkboxHorizontalMargin,
      this.wrapInCard = true,
      this.minWidth,
      this.fit = FlexFit.loose,
      this.scrollController,
      required this.onRowTapped})
      : assert(actions == null || (header != null)),
        assert(columns.isNotEmpty),
        assert(sortColumnIndex == null ||
            (sortColumnIndex >= 0 && sortColumnIndex < columns.length)),
        assert(rowsPerPage > 0),
        assert(() {
          if (onRowsPerPageChanged != null)
            assert(availableRowsPerPage.contains(rowsPerPage));
          return true;
        }()),
        super(key: key);

  final bool wrapInCard;

  ValueSetter<String> onRowTapped;

  final Widget? header;

  final List<Widget>? actions;

  final List<DataColumn> columns;

  final int? sortColumnIndex;

  final bool sortAscending;

  final ValueSetter<bool?>? onSelectAll;

  final double dataRowHeight;

  final double headingRowHeight;

  final double horizontalMargin;

  final double columnSpacing;

  final bool showCheckboxColumn;

  final bool showFirstLastButtons;

  final int? initialFirstRowIndex;

  final ValueChanged<int>? onPageChanged;

  final int rowsPerPage;

  static const int defaultRowsPerPage = 10;

  final List<int> availableRowsPerPage;

  final ValueChanged<int?>? onRowsPerPageChanged;

  final DataTableSource source;

  final DragStartBehavior dragStartBehavior;

  final double? checkboxHorizontalMargin;

  final double? minWidth;

  final FlexFit fit;

  final ScrollController? scrollController;

  @override
  PaginatedDataTable2State createState() => PaginatedDataTable2State();
}

class PaginatedDataTable2State extends State<PaginatedDataTable2> {
  late int _firstRowIndex;
  late int _rowCount;
  late bool _rowCountApproximate;
  int _selectedRowCount = 0;
  int _previousAvailablePage = 1;
  TextEditingController _controllerCurrentPage = new TextEditingController();
  final Map<int, DataRow?> _rows = <int, DataRow?>{};

  @override
  void initState() {
    super.initState();
    _firstRowIndex = PageStorage.of(context)?.readState(context) as int? ??
        widget.initialFirstRowIndex ??
        0;
    widget.source.addListener(_handleDataSourceChanged);
    _handleDataSourceChanged();
    _controllerCurrentPage.text = "1";
  }

  @override
  void didUpdateWidget(PaginatedDataTable2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      oldWidget.source.removeListener(_handleDataSourceChanged);
      widget.source.addListener(_handleDataSourceChanged);
      _handleDataSourceChanged();
    }
  }

  @override
  void dispose() {
    widget.source.removeListener(_handleDataSourceChanged);
    super.dispose();
  }

  void _handleDataSourceChanged() {
    setState(() {
      _rowCount = widget.source.rowCount;
      _rowCountApproximate = widget.source.isRowCountApproximate;
      _selectedRowCount = widget.source.selectedRowCount;
      _rows.clear();
    });
  }

  void pageTo(int rowIndex, int currentPage) {
    final int oldFirstRowIndex = _firstRowIndex;
    _previousAvailablePage = currentPage;
    setState(() {
      _controllerCurrentPage.text = currentPage.toString();
      final int rowsPerPage = widget.rowsPerPage;
      _firstRowIndex = (rowIndex ~/ rowsPerPage) * rowsPerPage;
    });

    if ((widget.onPageChanged != null) && (oldFirstRowIndex != _firstRowIndex))
      widget.onPageChanged!(_firstRowIndex);
  }

  DataRow _getBlankRowFor(int index) {
    return DataRow.byIndex(
      index: index,
      cells: widget.columns
          .map<DataCell>((DataColumn column) => DataCell.empty)
          .toList(),
    );
  }

  DataRow _getProgressIndicatorRowFor(int index) {
    bool haveProgressIndicator = false;
    final List<DataCell> cells =
        widget.columns.map<DataCell>((DataColumn column) {
      if (!column.numeric) {
        haveProgressIndicator = true;
        return const DataCell(CircularProgressIndicator());
      }
      return DataCell.empty;
    }).toList();
    if (!haveProgressIndicator) {
      haveProgressIndicator = true;
      cells[0] = const DataCell(CircularProgressIndicator());
    }
    return DataRow.byIndex(
      index: index,
      cells: cells,
    );
  }

  List<DataRow> _getRows(int firstRowIndex, int rowsPerPage) {
    final List<DataRow> result = <DataRow>[];
    final int nextPageFirstRowIndex = firstRowIndex + rowsPerPage;
    bool haveProgressIndicator = false;
    for (int index = firstRowIndex; index < nextPageFirstRowIndex; index += 1) {
      DataRow? row;
      if (index < _rowCount || _rowCountApproximate) {
        row = _rows.putIfAbsent(index, () => widget.source.getRow(index));
        if (row == null && !haveProgressIndicator) {
          row ??= _getProgressIndicatorRowFor(index);
          haveProgressIndicator = true;
        }
      }
      row ??= _getBlankRowFor(index);
      result.add(row);
    }
    return result;
  }

  void _handleFirst() {
    pageTo(0, 1);
  }

  void _handlePrevious() {
    pageTo(math.max(_firstRowIndex - widget.rowsPerPage, 0),
        int.parse(_controllerCurrentPage.text) - 1);
  }

  void _handleNext() {
    pageTo(_firstRowIndex + widget.rowsPerPage,
        int.parse(_controllerCurrentPage.text) + 1);
  }

  void _handleLast() {
    pageTo(((_rowCount - 1) / widget.rowsPerPage).floor() * widget.rowsPerPage,
        ((_rowCount - 1) / widget.rowsPerPage).floor() + 1);
  }

  bool _isNextPageUnavailable() =>
      !_rowCountApproximate &&
      (_firstRowIndex + widget.rowsPerPage >= _rowCount);

  final GlobalKey _tableKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final List<Widget> headerWidgets = <Widget>[];
    double startPadding = widget.horizontalMargin;
    if (_selectedRowCount == 0 && widget.header != null) {
      headerWidgets.add(Expanded(child: widget.header!));
      if (widget.header is ButtonBar) {
        startPadding = 12.0;
      }
    }
    /*else if (widget.header != null) { // Selected row count
      headerWidgets.add(Expanded(
        child: Text(localizations.selectedRowCountTitle(_selectedRowCount)),
      ));
    }*/
    if (widget.actions != null) {
      headerWidgets.addAll(widget.actions!.map<Widget>((Widget action) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 24.0 - 8.0 * 2.0),
          child: action,
        );
      }).toList());
    }

    final TextStyle? footerTextStyle = themeData.textTheme.caption;
    final List<Widget> footerWidgets = <Widget>[];
    if (widget.onRowsPerPageChanged != null) {
      final List<Widget> availableRowsPerPage = widget.availableRowsPerPage
          .where(
              (int value) => value <= _rowCount || value == widget.rowsPerPage)
          .map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text('$value'),
        );
      }).toList();
      footerWidgets.addAll([
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Container(width: 14.0),
              Text("Show "),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 64.0),
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Align(
                    alignment: AlignmentDirectional.center,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        items:
                            availableRowsPerPage.cast<DropdownMenuItem<int>>(),
                        value: widget.rowsPerPage,
                        onChanged: widget.onRowsPerPageChanged,
                        style: footerTextStyle,
                        icon: Icon(
                          Icons.arrow_drop_down_outlined,
                          color: Colors.blue,
                        ),
                        iconSize: 24.0,
                      ),
                    ),
                  ),
                ),
              ),
              Text(" entries")
            ],
          ),
        ),
      ]);
    }
    footerWidgets.addAll(<Widget>[
      Expanded(
          flex: 1,
          child: Row(
            children: [
              Container(width: 32.0),
              Text(
                localizations.pageRowsInfoTitle(
                      _firstRowIndex + 1,
                      _firstRowIndex + widget.rowsPerPage,
                      _rowCount,
                      _rowCountApproximate,
                    ) +
                    " items",
              ),
            ],
          ))
    ]);
    footerWidgets.addAll(<Widget>[
      Expanded(
        flex: 1,
        child: Row(
          children: [
            Container(width: 32.0),
            IconButton(
              icon: const Icon(Icons.skip_previous),
              padding: EdgeInsets.zero,
              onPressed: _firstRowIndex <= 0 ? null : _handleFirst,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              padding: EdgeInsets.zero,
              tooltip: localizations.previousPageTooltip,
              onPressed: _firstRowIndex <= 0 ? null : _handlePrevious,
            ),
            Container(width: 12.0),
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.blueAccent)),
              height: 30,
              width: 40,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(border: InputBorder.none),
                  maxLines: 1,
                  controller: _controllerCurrentPage,
                  textInputAction: TextInputAction.go,
                  keyboardType: TextInputType.number,
                  onSubmitted: (value) {
                    if (int.parse(value) >
                            ((_rowCount - 1) / widget.rowsPerPage).floor() +
                                1 ||
                        int.parse(value) < 1) {
                      print("This page not available");
                      _controllerCurrentPage.text =
                          _previousAvailablePage.toString();
                    } else {
                      print("Go to page $value");
                      _controllerCurrentPage.text = value;
                      pageTo(
                          (widget.rowsPerPage * int.parse(value) -
                              widget.rowsPerPage),
                          int.parse(value));
                    }
                  },
                ),
              ),
            ),
            Container(width: 12.0),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              padding: EdgeInsets.zero,
              tooltip: localizations.nextPageTooltip,
              onPressed: _isNextPageUnavailable() ? null : _handleNext,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              padding: EdgeInsets.zero,
              onPressed: _isNextPageUnavailable() ? null : _handleLast,
            ),
            Container(width: 14.0),
          ],
        ),
      ),
    ]);

    // CARD
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Widget t = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (headerWidgets.isNotEmpty)
              Semantics(
                container: true,
                child: DefaultTextStyle(
                  style: _selectedRowCount > 0
                      ? themeData.textTheme.subtitle1!
                          .copyWith(color: themeData.accentColor)
                      : themeData.textTheme.headline6!
                          .copyWith(fontWeight: FontWeight.w400),
                  child: IconTheme.merge(
                    data: const IconThemeData(opacity: 0.54),
                    child: Ink(
                      height: 64.0,
                      color: _selectedRowCount > 0
                          ? themeData.secondaryHeaderColor
                          : null,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                            start: startPadding, end: 14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: headerWidgets,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Flexible(
              fit: widget.fit,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.minWidth),
                child: DataTable2(
                  key: _tableKey,
                  columns: widget.columns,
                  sortColumnIndex: widget.sortColumnIndex,
                  sortAscending: widget.sortAscending,
                  onSelectAll: widget.onSelectAll,
                  decoration: const BoxDecoration(),
                  dataRowHeight: widget.dataRowHeight,
                  headingRowHeight: widget.headingRowHeight,
                  horizontalMargin: widget.horizontalMargin,
                  columnSpacing: widget.columnSpacing,
                  showCheckboxColumn: widget.showCheckboxColumn,
                  showBottomBorder: true,
                  rows: _getRows(_firstRowIndex, widget.rowsPerPage),
                  minWidth: widget.minWidth,
                  scrollController: widget.scrollController,
                  onRowTapped: (value) => widget.onRowTapped(value),
                ),
              ),
            ),
            Row(
              children: footerWidgets,
            )
            // DefaultTextStyle(
            //   style: footerTextStyle!,
            //   child: IconTheme.merge(
            //     data: const IconThemeData(opacity: 0.54),
            //     child: SizedBox(
            //       height: 56.0,
            //       child: SingleChildScrollView(
            //         dragStartBehavior: widget.dragStartBehavior,
            //         scrollDirection: Axis.horizontal,
            //         reverse: true,
            //         child: Row(
            //           children: footerWidgets,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        );

        if (widget.wrapInCard) t = Card(semanticContainer: false, child: t);

        return t;
      },
    );
  }
}
