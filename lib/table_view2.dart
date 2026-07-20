import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tableview2/dialog.dart';
import 'package:tableview2/listview_settings.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import 'core/models/listview_config_model.dart';
import 'core/models/table_column_config.dart';
import 'core/typedefs/type_defs.dart';
import 'data_table_view.dart';
import 'fix_aware_horizontal_scrollbar.dart';
import 'fix_aware_vertical_scrollbar.dart';
import 'listview_empty_data.dart';
import 'table_cell.dart';

class TableView2 extends StatefulWidget {
  const TableView2({
    super.key,
    this.empty,
    this.emptyMessage,
    required this.rows,
    this.onSelectAll,
    required this.dataRowHeight,
    required this.headingRowHeight,
    required this.listViewConfig,
    required this.onConfigUpdated,
    this.onSort,
    this.sortColumnIndex,
    this.sortAscending,
    this.fixedRowCount = 1,
    this.tableHeaderColor = Colors.blueAccent,
    this.isUseMaxWidth = false,
    this.hoveredIndexNotifier,
    this.sortIconColor = Colors.white,
  });
  final Widget? empty;
  final String? emptyMessage;
  final List<DataRowTableView> rows;
  final ValueSetter<bool?>? onSelectAll;
  final double dataRowHeight;
  final double headingRowHeight;
  final ListViewConfigModel listViewConfig;
  final ListViewConfigUpdatedCallback onConfigUpdated;
  final void Function(int, bool)? onSort;
  final int? sortColumnIndex;
  final bool? sortAscending;
  final int fixedRowCount;
  final Color tableHeaderColor;
  final ValueNotifier<int>? hoveredIndexNotifier;
  final bool isUseMaxWidth;
  final Color sortIconColor;

  @override
  State<TableView2> createState() => _TableView2State();
  static CheckboxThemeData checkboxTheme(BuildContext context) =>
      Theme.of(context).checkboxTheme.copyWith(
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const BorderSide(color: Colors.blueAccent, width: .05);
          }
          if (states.contains(WidgetState.focused)) {
            return const BorderSide(color: Colors.white, width: 1);
          }
          return const BorderSide(color: Colors.grey, width: 1);
        }),
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.blueAccent; // Bright blue
          }
          return Colors.transparent; // No fill when unchecked
        }),
      );
  static CheckboxThemeData headingCheckboxThemeTwoDimensional(
    BuildContext context,
    bool isSelectedAll,
  ) => Theme.of(context).checkboxTheme.copyWith(
    side: WidgetStateBorderSide.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return BorderSide(
          color: isSelectedAll ? Colors.transparent : Colors.white,
          width: 0.5,
        );
      }
      if (states.contains(WidgetState.focused)) {
        return const BorderSide(color: Colors.white, width: 0.5);
      }
      return const BorderSide(color: Colors.white, width: 0.5);
    }),
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return isSelectedAll ? Colors.blueAccent : Colors.transparent;
      }
      return Colors.transparent;
    }),
  );
  static String getSortIcon(
    int sortColumnIndex,
    int currentIndex,
    bool sortAscending,
  ) {
    if (sortColumnIndex == currentIndex && sortAscending) {
      return 'assets/actions/ico_listview_sort_up.svg';
    } else if (sortColumnIndex == currentIndex && !sortAscending) {
      return 'assets/actions/ico_listview_sort_down.svg';
    } else {
      return 'assets/actions/ico_listview_sort_none.svg';
    }
  }

  static Color getSortIconColor(
    int sortColumnIndex,
    int currentIndex,
    bool sortAscending,
    Color sortIconColor,
  ) {
    if (sortColumnIndex == currentIndex && sortAscending) {
      return Colors.orange;
    } else if (sortColumnIndex == currentIndex && !sortAscending) {
      return Colors.orange;
    } else {
      return sortIconColor;
    }
  }
}

class _TableView2State extends State<TableView2> {
  late final ScrollController _horizontalScrollController;
  late final ScrollController _verticalScrollController;
  late final ValueNotifier<ScrollMetrics?> _horizontalMetricsNotifier;
  late final ValueNotifier<ScrollMetrics?> _verticalMetricsNotifier;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
    _verticalScrollController = ScrollController();
    _horizontalMetricsNotifier = ValueNotifier<ScrollMetrics?>(null);
    _verticalMetricsNotifier = ValueNotifier<ScrollMetrics?>(null);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncInitialMetrics());
  }

  @override
  void didUpdateWidget(covariant TableView2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncInitialMetrics());
  }

  void _syncInitialMetrics() {
    if (!mounted) return;
    if (_horizontalScrollController.hasClients) {
      _horizontalMetricsNotifier.value = _horizontalScrollController.position;
    }
    if (_verticalScrollController.hasClients) {
      _verticalMetricsNotifier.value = _verticalScrollController.position;
    }
  }

  void _applyScrollMetricsForScrollbar(ScrollMetrics metrics) {
    void apply() {
      if (!mounted) return;
      if (metrics.axis == Axis.horizontal) {
        _horizontalMetricsNotifier.value = metrics;
      } else if (metrics.axis == Axis.vertical) {
        _verticalMetricsNotifier.value = metrics;
      }
    }

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => apply());
    } else {
      apply();
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _horizontalMetricsNotifier.dispose();
    _verticalMetricsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty) {
      return _buildDefaultEmptyState();
    }
    return _buildTableView();
  }

  Widget _buildDefaultEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildTableView()),
        Expanded(
          child:
              widget.empty ??
              ListviewEmptyData(
                alignment: Alignment.topCenter,
                size: const Size(double.infinity, double.infinity),
                message: widget.emptyMessage ?? 'Không có dữ liệu',
              ),
        ),
      ],
    );
  }

  Widget _buildTableView() {
    final totalColumns =
        _getTotalColumnsCount() +
        (widget.listViewConfig.isHaveCheckBox ? 1 : 0);
    final rowCount = widget.fixedRowCount + widget.rows.length;
    final headerHeight = widget.headingRowHeight * widget.fixedRowCount;
    final table = Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _applyScrollMetricsForScrollbar(notification.metrics);
          return false;
        },
        child: TableView.builder(
          horizontalDetails: ScrollableDetails.horizontal(
            controller: _horizontalScrollController,
          ).copyWith(physics: const ClampingScrollPhysics()),
          verticalDetails: ScrollableDetails.vertical(
            controller: _verticalScrollController,
          ).copyWith(physics: const ClampingScrollPhysics()),
          rowCount: rowCount,
          columnCount: totalColumns,
          pinnedRowCount: widget.fixedRowCount,
          cellBuilder: (context, vicinity) => _buildCell(context, vicinity),
          pinnedColumnCount: widget.listViewConfig.fixedLeftColumns,
          columnBuilder: (int index) => TableSpan(
            extent: FixedTableSpanExtent(_getColumnWidth(index)),
            foregroundDecoration: TableSpanDecoration(
              border: TableSpanBorder(
                leading: index == 0
                    ? const BorderSide(color: Colors.grey, width: 0.4)
                    : BorderSide.none,
                trailing: const BorderSide(color: Colors.grey, width: 0.4),
              ),
            ),
          ),
          rowBuilder: (int index) => TableSpan(
            extent: FixedTableSpanExtent(
              index < widget.fixedRowCount
                  ? widget.headingRowHeight
                  : widget.dataRowHeight,
            ),
            foregroundDecoration: const TableSpanDecoration(
              border: TableSpanBorder(
                trailing: BorderSide(color: Colors.grey, width: 0.4),
              ),
            ),
          ),
        ),
      ),
    );
    if (widget.rows.isEmpty) {
      return table;
    }
    return Stack(
      children: [
        table,
        Positioned(
          right: 0,
          top: headerHeight,
          bottom: 16,
          width: 12,
          child: FixedAwareVerticalScrollbar(
            controller: _verticalScrollController,
            metricsListenable: _verticalMetricsNotifier,
          ),
        ),
        Positioned(
          left: _pinnedColumnsWidth(),
          right: 0,
          bottom: 0,
          height: 16,
          child: FixedAwareHorizontalScrollbar(
            controller: _horizontalScrollController,
            metricsListenable: _horizontalMetricsNotifier,
          ),
        ),
      ],
    );
  }

  TableViewCell _buildCell(BuildContext context, TableVicinity vicinity) {
    // Handle checkbox column
    if (widget.listViewConfig.isHaveCheckBox && vicinity.column == 0) {
      return _buildCheckboxCell(context, vicinity);
    }

    final adjustedColumnIndex = widget.listViewConfig.isHaveCheckBox
        ? vicinity.column - 1
        : vicinity.column;
    if (adjustedColumnIndex >= _columnList.length) {
      return const TableViewCell(child: ColoredBox(color: Colors.white));
    }

    final columnConfig = _columnList[adjustedColumnIndex];
    final bool isAlignCenter = columnConfig.isCenter;

    if (vicinity.row == 0) {
      final groupColumn = _getGroupColumn(adjustedColumnIndex);

      if (groupColumn != null) {
        final adjustedStart =
            groupColumn.range!.start +
            (widget.listViewConfig.isHaveCheckBox ? 1 : 0);

        if (vicinity.column == adjustedStart) {
          return TableViewCell(
            columnMergeStart: adjustedStart,
            columnMergeSpan: groupColumn.range!.length,
            child: _headerCell(
              groupColumn.range!.groupTitle,
              context: context,
              columnConfig: groupColumn,
              index: vicinity.column,
              sortIconColor: widget.sortIconColor,
            ),
          );
        } else {
          //empty cell
          return TableViewCell(
            child: ColoredBox(color: widget.tableHeaderColor),
          );
        }
      } else {
        // single Column
        return TableViewCell(
          rowMergeStart: 0,
          rowMergeSpan: widget.fixedRowCount,
          child: _headerCell(
            columnConfig.title,
            context: context,
            columnConfig: columnConfig,
            index: vicinity.column,
            sortIconColor: widget.sortIconColor,
          ),
        );
      }
    }
    TableViewCell cell = const TableViewCell(
      child: ColoredBox(color: Colors.white),
    );
    final int dataRow = vicinity.row - widget.fixedRowCount;
    if (dataRow >= 0 && dataRow < widget.rows.length) {
      final row = widget.rows[dataRow];
      cell = TableViewCell(
        child: InkWell(
          onTap: () => row.onTap?.call(),
          onSecondaryTapDown: (details) =>
              row.onSecondaryTapDown?.call(details),
          onDoubleTap: () {
            if (row.onDoubleTap != null) {
              row.onDoubleTap!.call();
            } else {
              row.onSelectChanged?.call(!row.isChecked);
            }
          },
          onLongPress: () => row.onLongPress?.call(),
          child: ValueListenableBuilder<int>(
            valueListenable:
                widget.hoveredIndexNotifier ?? ValueNotifier<int>(-1),
            builder: (context, hoveredIndex, child) {
              return MouseRegion(
                onEnter: (_) =>
                    widget.hoveredIndexNotifier?.value = row.index ?? 1,
                onExit: (_) => widget.hoveredIndexNotifier?.value = -1,
                child: Container(
                  color: hoveredIndex == row.index
                      ? Colors.grey.shade100
                      : (row.selected
                            ? Colors.blueAccent.withValues(alpha: 0.1)
                            : Colors.transparent),
                  alignment: isAlignCenter
                      ? Alignment.center
                      : Alignment.centerLeft,
                  child: TableCellWrapper(
                    isCenter: isAlignCenter,
                    child: row.cells[adjustedColumnIndex],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    // HEADER ROW 2 (sub-headers)
    if (vicinity.row == 1) {
      final isGrouped = _isGroupedColumn(adjustedColumnIndex);

      if (isGrouped) {
        // Đây là sub-header của grouped column
        return TableViewCell(
          child: _headerCell(
            columnConfig.title,
            context: context,
            columnConfig: columnConfig,
            index: vicinity.column,
            sortIconColor: widget.sortIconColor,
          ),
        );
      } else {
        return cell;
      }
    }
    // Fallback
    return cell;
  }

  TableViewCell _buildCheckboxCell(
    BuildContext context,
    TableVicinity vicinity,
  ) {
    if (vicinity.row == 0) {
      return _buildHeaderCheckboxCell(context);
    }

    final int dataRow = vicinity.row - widget.fixedRowCount;
    if (dataRow >= 0 && dataRow < widget.rows.length) {
      return _buildDataCheckboxCell(context, widget.rows[dataRow]);
    }

    return const TableViewCell(child: ColoredBox(color: Colors.white));
  }

  TableViewCell _buildHeaderCheckboxCell(BuildContext context) {
    final allSelected = _areAllSelected();

    return TableViewCell(
      rowMergeStart: 0,
      rowMergeSpan: widget.fixedRowCount,
      child: Container(
        color: widget.tableHeaderColor,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        child: CheckboxTheme(
          data: TableView2.headingCheckboxThemeTwoDimensional(
            context,
            allSelected ?? false,
          ),
          child: Checkbox(
            value: allSelected,
            tristate: true,
            onChanged: (value) {
              widget.onSelectAll?.call(value ?? false);
            },
          ),
        ),
      ),
    );
  }

  TableViewCell _buildDataCheckboxCell(
    BuildContext context,
    DataRowTableView row,
  ) {
    return TableViewCell(
      child: Container(
        color: row.selected
            ? Colors.blueAccent.withValues(alpha: 0.1)
            : Colors.white,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        child: CheckboxTheme(
          data: row.enableCheckbox
              ? TableView2.checkboxTheme(context)
              : TableView2.checkboxTheme(context).copyWith(
                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.grey;
                    }
                    return Colors.transparent;
                  }),
                  checkColor: const WidgetStatePropertyAll(Colors.white),
                  side: WidgetStateBorderSide.resolveWith((states) {
                    return const BorderSide(color: Colors.grey, width: 1);
                  }),
                ),
          child: Checkbox(
            value: row.enableCheckbox ? row.isChecked : true,
            onChanged: row.enableCheckbox
                ? (value) {
                    row.onSelectChanged?.call(value ?? false);
                  }
                : null,
          ),
        ),
      ),
    );
  }

  bool? _areAllSelected() {
    if (widget.rows.isEmpty) return false;

    final selectedCount = widget.rows.where((item) => item.isChecked).length;
    if (selectedCount == 0) return false;
    if (selectedCount == widget.rows.length) return true;
    return null; // Indeterminate state
  }

  Widget _headerCell(
    String text, {
    required int index,
    required BuildContext context,
    required TableColumnConfig columnConfig,
    bool enableSettings = true,
    required Color sortIconColor,
  }) {
    final shouldCenter = columnConfig.isCenter;
    final isSortable = columnConfig.isSortable;
    return InkWell(
      onLongPress: enableSettings
          ? () {
              IDialog.showCommonAnimationDialog(
                context: context,
                content: ListViewSettings(
                  listViewConfig: widget.listViewConfig,
                  columnConfig: columnConfig,
                  onUpdate: (newConfig, isFixed) {
                    widget.onConfigUpdated(newConfig, isFixed);
                  },
                ),
              );
            }
          : null,
      child: Container(
        color: widget.tableHeaderColor,
        padding: const EdgeInsets.all(4),
        alignment: shouldCenter ? Alignment.center : Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: isSortable == true
              ? MainAxisAlignment.spaceBetween
              : shouldCenter
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.visible,
                textAlign: shouldCenter ? TextAlign.center : TextAlign.left,
              ),
            ),
            if (isSortable)
              InkWell(
                onTap: () =>
                    widget.onSort?.call(index, widget.sortAscending ?? true),
                child: SvgPicture.asset(
                  TableView2.getSortIcon(
                    widget.sortColumnIndex ?? 0,
                    index,
                    widget.sortAscending ?? true,
                  ),
                  package: 'tableview2',
                  width: 12,
                  height: 12,
                  colorFilter: ColorFilter.mode(
                    TableView2.getSortIconColor(
                      widget.sortColumnIndex ?? 0,
                      index,
                      widget.sortAscending ?? true,
                      sortIconColor,
                    ),
                    BlendMode.srcIn,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Tính tổng số cột thực tế (bao gồm các sub-columns trong grouped columns)
  int _getTotalColumnsCount() {
    int total = 0;
    for (final column in widget.listViewConfig.columns) {
      if (column.range != null && column.range!.columns.isNotEmpty) {
        total += column.range!.columns.length;
      } else {
        total += 1; // singleColumn
      }
    }
    return total;
  }

  TableColumnConfig? _getGroupColumn(int actualColumnIndex) {
    for (final column in widget.listViewConfig.columns) {
      if (column.range != null && column.range!.columns.isNotEmpty) {
        if (actualColumnIndex >= column.range!.start &&
            actualColumnIndex <= column.range!.end) {
          return column;
        }
      }
    }
    return null;
  }

  List<TableColumnConfig> get _columnList {
    final columnList = <TableColumnConfig>[];

    for (final column in widget.listViewConfig.columns) {
      if (column.range != null && column.range!.columns.isNotEmpty) {
        // Grouped column
        for (int i = 0; i < column.range!.columns.length; i++) {
          columnList.add(column.range!.columns[i]);
        }
      } else {
        columnList.add(column);
      }
    }

    return columnList;
  }

  bool _isGroupedColumn(int actualColumnIndex) {
    for (final column in widget.listViewConfig.columns) {
      if (column.range != null && column.range!.columns.isNotEmpty) {
        if (actualColumnIndex >= column.range!.start &&
            actualColumnIndex <= column.range!.end) {
          return true;
        }
      }
    }
    return false;
  }

  double _getColumnWidth(int actualColumnIndex) {
    // Handle checkbox column
    if (widget.listViewConfig.isHaveCheckBox && actualColumnIndex == 0) {
      return 60.0; // Fixed width for checkbox column
    }

    // Adjust column index if checkbox column exists
    final adjustedColumnIndex = widget.listViewConfig.isHaveCheckBox
        ? actualColumnIndex - 1
        : actualColumnIndex;
    if (adjustedColumnIndex >= _columnList.length) {
      return 100.0; // Default width
    }

    final columnConfig = _columnList[adjustedColumnIndex];
    if (widget.isUseMaxWidth && columnConfig.maxWidth != 1000.0) {
      return columnConfig.maxWidth.clamp(
        columnConfig.minWidth,
        columnConfig.maxWidth,
      );
    }
    return columnConfig.width;
  }

  double _pinnedColumnsWidth() {
    double width = 0;
    final pinnedCount = widget.listViewConfig.fixedLeftColumns;
    for (int i = 0; i < pinnedCount; i++) {
      width += _getColumnWidth(i);
    }
    return width;
  }
}
