library data_table_2;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

double _smRatio = 0.67;
double _lmRatio = 1.2;

enum ColumnSize { S, M, L }

double get smRatio => _smRatio;

double get lmRatio => _lmRatio;

void setColumnSizeRatios(double sm, double lm) {
  _smRatio = sm;
  _lmRatio = lm;
}

@immutable
class DataColumn2 extends DataColumn {
  const DataColumn2(
      {required Widget label,
      String? tooltip,
      bool numeric = false,
      Function(int, bool)? onSort,
      this.size = ColumnSize.M})
      : super(label: label, tooltip: tooltip, numeric: numeric, onSort: onSort);

  final ColumnSize size;
}

@immutable
class DataRow2 extends DataRow {
  const DataRow2(
      {LocalKey? key,
      bool selected = false,
      ValueChanged<bool?>? onSelectChanged,
      MaterialStateProperty<Color?>? color,
      required List<DataCell> cells,
      this.onTap,
      this.onSecondaryTap,
      this.onSecondaryTapDown})
      : super(
            key: key,
            selected: selected,
            onSelectChanged: onSelectChanged,
            color: color,
            cells: cells);

  DataRow2.byIndex(
      {int? index,
      bool selected = false,
      ValueChanged<bool?>? onSelectChanged,
      MaterialStateProperty<Color?>? color,
      required List<DataCell> cells,
      this.onTap,
      this.onSecondaryTap,
      this.onSecondaryTapDown})
      : super.byIndex(
            index: index,
            selected: selected,
            onSelectChanged: onSelectChanged,
            color: color,
            cells: cells);

  final VoidCallback? onTap;

  final VoidCallback? onSecondaryTap;

  final GestureTapDownCallback? onSecondaryTapDown;
}

class DataTable2 extends DataTable {
  DataTable2({
    Key? key,
    required List<DataColumn> columns,
    int? sortColumnIndex,
    bool sortAscending = true,
    ValueSetter<bool?>? onSelectAll,
    Decoration? decoration,
    MaterialStateProperty<Color?>? dataRowColor,
    double? dataRowHeight,
    TextStyle? dataTextStyle,
    MaterialStateProperty<Color?>? headingRowColor,
    double? headingRowHeight,
    TextStyle? headingTextStyle,
    double? horizontalMargin,
    this.bottomMargin,
    double? columnSpacing,
    bool showCheckboxColumn = true,
    bool showBottomBorder = false,
    double? dividerThickness,
    this.minWidth,
    this.scrollController,
    required List<DataRow> rows,
    this.onRowTapped,
  }) : super(
            key: key,
            columns: columns,
            sortColumnIndex: sortColumnIndex,
            sortAscending: sortAscending,
            onSelectAll: onSelectAll,
            decoration: decoration,
            dataRowColor: dataRowColor,
            dataRowHeight: dataRowHeight,
            dataTextStyle: dataTextStyle,
            headingRowColor: headingRowColor,
            headingRowHeight: headingRowHeight,
            headingTextStyle: headingTextStyle,
            horizontalMargin: horizontalMargin,
            columnSpacing: columnSpacing,
            showCheckboxColumn: showCheckboxColumn,
            showBottomBorder: showBottomBorder,
            dividerThickness: dividerThickness,
            rows: rows);

  static final LocalKey _headingRowKey = UniqueKey();

  void _handleSelectAll(bool? checked, bool someChecked) {
    final bool effectiveChecked = someChecked || (checked ?? false);
    if (onSelectAll != null) {
      onSelectAll!(effectiveChecked);
    } else {
      for (final DataRow row in rows) {
        if (row.onSelectChanged != null && row.selected != effectiveChecked)
          row.onSelectChanged!(effectiveChecked);
      }
    }
  }

  static const double _headingRowHeight = 56.0;

  static const double _horizontalMargin = 24.0;

  static const double _columnSpacing = 56.0;

  static const double _sortArrowPadding = 2.0;

  static const double _dividerThickness = 1.0;

  static const Duration _sortArrowAnimationDuration =
      Duration(milliseconds: 150);

  final double? minWidth;

  final double? bottomMargin;
  ValueSetter<String>? onRowTapped;
  final ScrollController? scrollController;

  Widget _buildCheckbox({
    required BuildContext context,
    required bool? checked,
    required VoidCallback? onRowTap,
    required ValueChanged<bool?>? onCheckboxChanged,
    required MaterialStateProperty<Color?>? overlayColor,
    required bool tristate,
  }) {
    final ThemeData themeData = Theme.of(context);
    final double effectiveHorizontalMargin = horizontalMargin ??
        themeData.dataTableTheme.horizontalMargin ??
        _horizontalMargin;
    Widget contents = Semantics(
      container: true,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: effectiveHorizontalMargin,
          end: effectiveHorizontalMargin / 2.0,
        ),
        child: Center(
          child: Checkbox(
            activeColor: themeData.colorScheme.primary,
            checkColor: themeData.colorScheme.onPrimary,
            value: checked,
            onChanged: onCheckboxChanged,
            tristate: tristate,
          ),
        ),
      ),
    );
    if (onRowTap != null) {
      contents = TableRowInkWell(
        onTap: onRowTap,
        child: contents,
        overlayColor: overlayColor,
      );
    }
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.fill,
      child: contents,
    );
  }

  Widget _buildHeadingCell({
    required BuildContext context,
    required EdgeInsetsGeometry padding,
    required Widget label,
    required String? tooltip,
    required bool numeric,
    required VoidCallback? onSort,
    required bool sorted,
    required bool ascending,
    required MaterialStateProperty<Color?>? overlayColor,
  }) {
    final ThemeData themeData = Theme.of(context);
    label = Row(
      textDirection: numeric ? TextDirection.rtl : null,
      children: <Widget>[
        Flexible(child: label),
        if (onSort != null) ...<Widget>[
          _SortArrow(
            visible: sorted,
            up: sorted ? ascending : null,
            duration: _sortArrowAnimationDuration,
          ),
          const SizedBox(width: _sortArrowPadding),
        ],
      ],
    );

    final TextStyle effectiveHeadingTextStyle = headingTextStyle ??
        themeData.dataTableTheme.headingTextStyle ??
        themeData.textTheme.subtitle2!;
    final double effectiveHeadingRowHeight = headingRowHeight ??
        themeData.dataTableTheme.headingRowHeight ??
        _headingRowHeight;
    label = Container(
      padding: padding,
      height: effectiveHeadingRowHeight,
      alignment:
          numeric ? Alignment.centerRight : AlignmentDirectional.centerStart,
      child: AnimatedDefaultTextStyle(
        style: effectiveHeadingTextStyle,
        softWrap: false,
        duration: _sortArrowAnimationDuration,
        child: label,
      ),
    );
    if (tooltip != null) {
      label = Tooltip(
        message: tooltip,
        child: label,
      );
    }

    label = InkWell(
      onTap: onSort,
      overlayColor: overlayColor,
      child: label,
    );
    return label;
  }

  Widget _buildDataCell({
    required BuildContext context,
    required EdgeInsetsGeometry padding,
    required Widget label,
    required bool numeric,
    required bool placeholder,
    required bool showEditIcon,
    required VoidCallback? onTap,
    required VoidCallback? onRowTap,
    required VoidCallback? onRowSecondaryTap,
    required GestureTapDownCallback? onRowSecondaryTapDown,
    required VoidCallback? onSelectChanged,
    required MaterialStateProperty<Color?>? overlayColor,
  }) {
    final ThemeData themeData = Theme.of(context);
    if (showEditIcon) {
      const Widget icon = Icon(Icons.edit, size: 18.0);
      label = Expanded(child: label);
      label = Row(
        textDirection: numeric ? TextDirection.rtl : null,
        children: <Widget>[label, icon],
      );
    }

    final TextStyle effectiveDataTextStyle = dataTextStyle ??
        themeData.dataTableTheme.dataTextStyle ??
        themeData.textTheme.bodyText2!;
    final double effectiveDataRowHeight = dataRowHeight ??
        themeData.dataTableTheme.dataRowHeight ??
        kMinInteractiveDimension;
    label = Container(
      padding: padding,
      height: effectiveDataRowHeight,
      alignment:
          numeric ? Alignment.centerRight : AlignmentDirectional.centerStart,
      child: DefaultTextStyle(
        style: effectiveDataTextStyle.copyWith(
          color: placeholder
              ? effectiveDataTextStyle.color!.withOpacity(0.6)
              : null,
        ),
        child: DropdownButtonHideUnderline(child: label),
      ),
    );
    if (onTap != null) {
      label = InkWell(
        onTap: onTap,
        child: label,
        overlayColor: overlayColor,
      );
    } else if (onSelectChanged != null) {
      label = GestureDetector(
        child: TableRowInkWell(
            child: label,
            overlayColor: overlayColor,
            onTap: onRowTap == null
                ? onSelectChanged
                : () {
                    onRowTap();
                    onSelectChanged();
                  }),
        onSecondaryTap: onRowSecondaryTap,
        onSecondaryTapDown: onRowSecondaryTapDown,
      );
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    var sw = Stopwatch();
    sw.start();
    assert(debugCheckHasMaterial(context));

    final ThemeData theme = Theme.of(context);
    final MaterialStateProperty<Color?>? effectiveHeadingRowColor =
        headingRowColor ?? theme.dataTableTheme.headingRowColor;
    final MaterialStateProperty<Color?>? effectiveDataRowColor =
        dataRowColor ?? theme.dataTableTheme.dataRowColor;
    final MaterialStateProperty<Color?> defaultRowColor =
        MaterialStateProperty.resolveWith(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected))
          return theme.colorScheme.primary.withOpacity(0.08);
        return null;
      },
    );
    final bool anyRowSelectable =
        rows.any((DataRow row) => row.onSelectChanged != null);
    final bool displayCheckboxColumn = showCheckboxColumn && anyRowSelectable;
    final Iterable<DataRow> rowsWithCheckbox = displayCheckboxColumn
        ? rows.where((DataRow row) => row.onSelectChanged != null)
        : <DataRow2>[];
    final Iterable<DataRow> rowsChecked =
        rowsWithCheckbox.where((DataRow row) => row.selected);
    final bool allChecked =
        displayCheckboxColumn && rowsChecked.length == rowsWithCheckbox.length;
    final bool anyChecked = displayCheckboxColumn && rowsChecked.isNotEmpty;
    final bool someChecked = anyChecked && !allChecked;
    final double effectiveHorizontalMargin = horizontalMargin ??
        theme.dataTableTheme.horizontalMargin ??
        _horizontalMargin;
    final double effectiveColumnSpacing =
        columnSpacing ?? theme.dataTableTheme.columnSpacing ?? _columnSpacing;

    final List<TableColumnWidth> tableColumns = List<TableColumnWidth>.filled(
        columns.length + (displayCheckboxColumn ? 1 : 0),
        const _NullTableColumnWidth());

    var headingRow = TableRow(
      key: _headingRowKey,
      decoration: BoxDecoration(
        border: showBottomBorder
            ? Border(
                bottom: Divider.createBorderSide(
                context,
                width: dividerThickness ??
                    theme.dataTableTheme.dividerThickness ??
                    _dividerThickness,
              ))
            : null,
        color: effectiveHeadingRowColor?.resolve(<MaterialState>{}),
      ),
      children: List<Widget>.filled(tableColumns.length, const _NullWidget()),
    );

    final List<TableRow> tableRows = List<TableRow>.generate(
      rows.length,
      (int index) {
        final bool isSelected = rows[index].selected;
        final bool isDisabled =
            anyRowSelectable && rows[index].onSelectChanged == null;
        final Set<MaterialState> states = <MaterialState>{
          if (isSelected) MaterialState.selected,
          if (isDisabled) MaterialState.disabled,
        };
        final Color? resolvedDataRowColor =
            (rows[index].color ?? effectiveDataRowColor)?.resolve(states);
        final Color? rowColor = resolvedDataRowColor;
        final BorderSide borderSide = Divider.createBorderSide(
          context,
          width: dividerThickness ??
              theme.dataTableTheme.dividerThickness ??
              _dividerThickness,
        );
        final Border? border = showBottomBorder
            ? Border(bottom: borderSide)
            : Border(top: borderSide);
        return TableRow(
          key: rows[index].key,
          decoration: BoxDecoration(
            border: border,
            color: rowColor ?? defaultRowColor.resolve(states),
          ),
          children:
              List<Widget>.filled(tableColumns.length, const _NullWidget()),
        );
      },
    );

    var builder = LayoutBuilder(builder: (context, constraints) {
      int rowIndex;

      int displayColumnIndex = 0;
      double checkBoxWidth = 0;
      if (displayCheckboxColumn) {
        checkBoxWidth = effectiveHorizontalMargin +
            Checkbox.width +
            effectiveHorizontalMargin / 2.0;
        tableColumns[0] = FixedColumnWidth(checkBoxWidth);
        headingRow.children![0] = _buildCheckbox(
          context: context,
          checked: someChecked ? null : allChecked,
          onRowTap: null,
          onCheckboxChanged: (bool? checked) {
            print("On check box change");
            onRowTapped!("hello");
            _handleSelectAll(checked, someChecked);
          },
          overlayColor: null,
          tristate: true,
        );
        rowIndex = 0;
        for (final DataRow row in rows) {
          tableRows[rowIndex].children![0] = _buildCheckbox(
            context: context,
            checked: row.selected,
            onRowTap: () => row.onSelectChanged != null
                ? row.onSelectChanged!(!row.selected)
                : null,
            onCheckboxChanged: row.onSelectChanged,
            overlayColor: row.color ?? effectiveDataRowColor,
            tristate: false,
          );
          rowIndex += 1;
        }
        displayColumnIndex += 1;
      }

      var availableWidth = constraints.maxWidth;
      if (minWidth != null && availableWidth < minWidth!) {
        availableWidth = minWidth!;
      }

      availableWidth -= checkBoxWidth;
      var totalColWidth = availableWidth -
          effectiveHorizontalMargin -
          (displayCheckboxColumn
              ? effectiveHorizontalMargin / 2
              : effectiveHorizontalMargin);

      var columnWidth = totalColWidth / columns.length;
      var totalWidth = 0.0;

      var widths = List<double>.generate(columns.length, (i) {
        var w = columnWidth;
        var column = columns[i];
        if (column is DataColumn2) {
          if (column.size == ColumnSize.S) {
            w *= _smRatio;
          } else if (column.size == ColumnSize.L) {
            w *= _lmRatio;
          }
        }
        totalWidth += w;
        return w;
      });

      var ratio = totalColWidth / totalWidth;

      for (var i = 0; i < widths.length; i++) {
        widths[i] *= ratio;
      }

      if (widths.length == 1) {
        widths[0] = math.max(
            0,
            widths[0] +
                effectiveHorizontalMargin +
                (displayCheckboxColumn
                    ? effectiveHorizontalMargin / 2
                    : effectiveHorizontalMargin));
      } else if (widths.length > 1) {
        widths[0] = math.max(
            0,
            widths[0] +
                (displayCheckboxColumn
                    ? effectiveHorizontalMargin / 2
                    : effectiveHorizontalMargin));
        widths[widths.length - 1] =
            math.max(0, widths[widths.length - 1] + effectiveHorizontalMargin);
      }

      for (int dataColumnIndex = 0;
          dataColumnIndex < columns.length;
          dataColumnIndex++) {
        final DataColumn column = columns[dataColumnIndex];

        final double paddingStart;
        if (dataColumnIndex == 0 && displayCheckboxColumn) {
          paddingStart = effectiveHorizontalMargin / 2.0;
        } else if (dataColumnIndex == 0 && !displayCheckboxColumn) {
          paddingStart = effectiveHorizontalMargin;
        } else {
          paddingStart = effectiveColumnSpacing / 2.0;
        }

        final double paddingEnd;
        if (dataColumnIndex == columns.length - 1) {
          paddingEnd = effectiveHorizontalMargin;
        } else {
          paddingEnd = effectiveColumnSpacing / 2.0;
        }

        final EdgeInsetsDirectional padding = EdgeInsetsDirectional.only(
          start: paddingStart,
          end: paddingEnd,
        );

        tableColumns[displayColumnIndex] =
            FixedColumnWidth(widths[dataColumnIndex]);

        headingRow.children![displayColumnIndex] = _buildHeadingCell(
          context: context,
          padding: padding,
          label: column.label,
          tooltip: column.tooltip,
          numeric: column.numeric,
          onSort: column.onSort != null
              ? () => column.onSort!(dataColumnIndex,
                  sortColumnIndex != dataColumnIndex || !sortAscending)
              : null,
          sorted: dataColumnIndex == sortColumnIndex,
          ascending: sortAscending,
          overlayColor: effectiveHeadingRowColor,
        );

        rowIndex = 0;
        for (final DataRow row in rows) {
          final DataCell cell = row.cells[dataColumnIndex];
          tableRows[rowIndex].children![displayColumnIndex] = _buildDataCell(
            context: context,
            padding: padding,
            label: cell.child,
            numeric: column.numeric,
            placeholder: cell.placeholder,
            showEditIcon: cell.showEditIcon,
            onTap: cell.onTap,
            onRowTap: row is DataRow2 ? row.onTap : null,
            onRowSecondaryTap: row is DataRow2 ? row.onSecondaryTap : null,
            onRowSecondaryTapDown:
                row is DataRow2 ? row.onSecondaryTapDown : null,
            onSelectChanged: () {
              _removeSelectedBefore(rows);
              if (row.onSelectChanged != null) {
                row.onSelectChanged!(!row.selected);
                print("Change selected");
                onRowTapped!("Tapped");
              }
            },
            overlayColor: row.color ?? effectiveDataRowColor,
          );
          rowIndex += 1;
        }
        displayColumnIndex += 1;
      }

      var widthsAsMap = tableColumns.asMap();

      var marginedT = bottomMargin != null && bottomMargin! > 0
          ? Column(mainAxisSize: MainAxisSize.min, children: [
              Table(
                columnWidths: widthsAsMap,
                children: tableRows,
              ),
              SizedBox(height: bottomMargin!)
            ])
          : Table(
              columnWidths: widthsAsMap,
              children: tableRows,
            );

      var t = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Table(
            columnWidths: widthsAsMap,
            children: [headingRow],
          ),
          Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                  child: marginedT, controller: scrollController))
        ],
      );

      var w = Container(
          decoration: decoration ?? theme.dataTableTheme.decoration,
          child: Material(
              type: MaterialType.transparency,
              child: availableWidth > constraints.maxWidth
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal, child: t)
                  : t));

      return w;
    });

    sw.stop();
    if (!kReleaseMode) print('DataTable2 built: ${sw.elapsedMilliseconds}ms');
    return builder;
  }

  void _removeSelectedBefore(List<DataRow> rows) {
    for (DataRow row in rows) {
      row.onSelectChanged!(false);
    }
  }
}

class _SortArrow extends StatefulWidget {
  const _SortArrow({
    Key? key,
    required this.visible,
    required this.up,
    required this.duration,
  }) : super(key: key);

  final bool visible;

  final bool? up;

  final Duration duration;

  @override
  _SortArrowState createState() => _SortArrowState();
}

class _SortArrowState extends State<_SortArrow> with TickerProviderStateMixin {
  late AnimationController _opacityController;
  late Animation<double> _opacityAnimation;

  late AnimationController _orientationController;
  late Animation<double> _orientationAnimation;
  double _orientationOffset = 0.0;

  bool? _up;

  static final Animatable<double> _turnTween =
      Tween<double>(begin: 0.0, end: math.pi)
          .chain(CurveTween(curve: Curves.easeIn));

  @override
  void initState() {
    super.initState();
    _opacityAnimation = CurvedAnimation(
      parent: _opacityController = AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
      curve: Curves.fastOutSlowIn,
    )..addListener(_rebuild);
    _opacityController.value = widget.visible ? 1.0 : 0.0;
    _orientationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _orientationAnimation = _orientationController.drive(_turnTween)
      ..addListener(_rebuild)
      ..addStatusListener(_resetOrientationAnimation);
    if (widget.visible) _orientationOffset = widget.up! ? 0.0 : math.pi;
  }

  void _rebuild() {
    setState(() {});
  }

  void _resetOrientationAnimation(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      assert(_orientationAnimation.value == math.pi);
      _orientationOffset += math.pi;
      _orientationController.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(_SortArrow oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool skipArrow = false;
    final bool? newUp = widget.up ?? _up;
    if (oldWidget.visible != widget.visible) {
      if (widget.visible &&
          (_opacityController.status == AnimationStatus.dismissed)) {
        _orientationController.stop();
        _orientationController.value = 0.0;
        _orientationOffset = newUp! ? 0.0 : math.pi;
        skipArrow = true;
      }
      if (widget.visible) {
        _opacityController.forward();
      } else {
        _opacityController.reverse();
      }
    }
    if ((_up != newUp) && !skipArrow) {
      if (_orientationController.status == AnimationStatus.dismissed) {
        _orientationController.forward();
      } else {
        _orientationController.reverse();
      }
    }
    _up = newUp;
  }

  @override
  void dispose() {
    _opacityController.dispose();
    _orientationController.dispose();
    super.dispose();
  }

  static const double _arrowIconBaselineOffset = -1.5;
  static const double _arrowIconSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _opacityAnimation.value,
      child: Transform(
        transform:
            Matrix4.rotationZ(_orientationOffset + _orientationAnimation.value)
              ..setTranslationRaw(0.0, _arrowIconBaselineOffset, 0.0),
        alignment: Alignment.center,
        child: const Icon(
          Icons.arrow_upward,
          size: _arrowIconSize,
        ),
      ),
    );
  }
}

class _NullTableColumnWidth extends TableColumnWidth {
  const _NullTableColumnWidth();

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      throw UnimplementedError();

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      throw UnimplementedError();
}

class _NullWidget extends Widget {
  const _NullWidget();

  @override
  Element createElement() => throw UnimplementedError();
}
