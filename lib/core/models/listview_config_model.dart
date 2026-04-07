import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'table_column_config.dart';

part 'listview_config_model.g.dart';

@JsonSerializable()
class ListViewConfigModel extends Equatable {
  final List<TableColumnConfig> columns;
  final String name;
  final int fixedLeftColumns;
  final bool isHaveCheckBox;
  const ListViewConfigModel({
    required this.columns,
    required this.name,
    required this.fixedLeftColumns,
    this.isHaveCheckBox = false,
  });

  ListViewConfigModel copyWith({
    List<TableColumnConfig>? columns,
    String? name,
    int? fixedLeftColumns,
    bool? isHaveCheckBox,
  }) => ListViewConfigModel(
    isHaveCheckBox: isHaveCheckBox ?? this.isHaveCheckBox,
    columns: columns ?? this.columns,
    name: name ?? this.name,
    fixedLeftColumns: fixedLeftColumns ?? this.fixedLeftColumns,
  );
  double sumOfFixedColumnsWidth() {
    return columns.fold(double.infinity, (sum, column) => sum + column.width);
  }

  double sumOfColumnsWidthToColumn(TableColumnConfig column) {
    List<TableColumnConfig> allColumns = [];
    for (int i = 0; i < columns.length; i++) {
      final col = columns[i];
      if (col.range != null && col.range!.columns.isNotEmpty) {
        allColumns.addAll(col.range!.columns);
      } else {
        allColumns.add(col);
      }
    }

    final idx = allColumns.indexWhere((col) => col.key == column.key);
    if (idx == -1) {
      return 0;
    }

    return allColumns.take(idx + 1).fold(0.0, (sum, col) => sum + col.width);
  }

  int calculateFixedLeftColumnsForColumn(String columnKey) {
    int totalFixedColumns = isHaveCheckBox ? 1 : 0;
    String actualColumnKey = columnKey;
    for (final col in columns) {
      if (col.key == columnKey &&
          col.range != null &&
          col.range!.columns.isNotEmpty) {
        actualColumnKey = col.range!.columns.last.key;
        break;
      }
    }

    List<TableColumnConfig> allColumns = [];
    for (int i = 0; i < columns.length; i++) {
      final col = columns[i];

      if (col.range != null && col.range!.columns.isNotEmpty) {
        allColumns.addAll(col.range!.columns);
      } else {
        allColumns.add(col);
      }
    }
    final columnIndex = allColumns.indexWhere(
      (col) => col.key == actualColumnKey,
    );

    if (columnIndex != -1) {
      totalFixedColumns += columnIndex + 1;
    }
    return totalFixedColumns;
  }

  TableColumnConfig updateColumnInList(
    TableColumnConfig column,
    TableColumnConfig newConfig,
  ) {
    if (column.key == newConfig.key) {
      return newConfig;
    }

    if (column.range != null && column.range!.columns.isNotEmpty) {
      final subColumnIndex = column.range!.columns.indexWhere(
        (subCol) => subCol.key == newConfig.key,
      );
      if (subColumnIndex != -1) {
        final updatedSubColumns = List<TableColumnConfig>.from(
          column.range!.columns,
        );
        updatedSubColumns[subColumnIndex] = newConfig;
        return column.copyWith(
          range: column.range!.copyWith(columns: updatedSubColumns),
        );
      }
    }

    return column;
  }

  ({List<TableColumnConfig> columns, int fixedLeftColumns})
  updateColumnAndCalculateFixed(
    TableColumnConfig newConfig, {
    bool isFixed = false,
  }) {
    final updatedColumns = <TableColumnConfig>[];
    int newFixedLeftColumns = isHaveCheckBox ? 1 : 0;
    int targetColumnIndex = -1;
    int currentFlatIndex = 0;

    for (int i = 0; i < columns.length; i++) {
      final col = columns[i];
      TableColumnConfig updatedCol = col;

      if (col.key == newConfig.key) {
        updatedCol = newConfig;
        if (isFixed) targetColumnIndex = currentFlatIndex;
      } else if (col.range != null && col.range!.columns.isNotEmpty) {
        final subColumnIndex = col.range!.columns.indexWhere(
          (subCol) => subCol.key == newConfig.key,
        );
        if (subColumnIndex != -1) {
          final updatedSubColumns = List<TableColumnConfig>.from(
            col.range!.columns,
          );
          updatedSubColumns[subColumnIndex] = newConfig;
          updatedCol = col.copyWith(
            range: col.range!.copyWith(columns: updatedSubColumns),
          );
          if (isFixed) targetColumnIndex = currentFlatIndex + subColumnIndex;
        }
      }

      updatedColumns.add(updatedCol);

      if (updatedCol.range != null && updatedCol.range!.columns.isNotEmpty) {
        currentFlatIndex += updatedCol.range!.columns.length;
      } else {
        currentFlatIndex += 1;
      }
    }

    if (isFixed && targetColumnIndex != -1) {
      newFixedLeftColumns = calculateFixedLeftColumnsForColumn(newConfig.key);
    } else {
      newFixedLeftColumns = fixedLeftColumns;
    }

    return (columns: updatedColumns, fixedLeftColumns: newFixedLeftColumns);
  }

  /// Update column titles from a list of updates containing key and value
  ListViewConfigModel updateColumnTitles(List<ColumnTitleInfo> updates) {
    if (updates.isEmpty) return this;
    final updatedColumns = columns
        .map((col) => col.updateTitleFromList(updates))
        .toList();
    return copyWith(columns: updatedColumns);
  }

  bool isFixedColumn(TableColumnConfig column) {
    // Handle group columns - check if any sub-column is fixed
    if (column.range != null && column.range!.columns.isNotEmpty) {
      final lastSubColumn = column.range!.columns.last;
      return isFixedColumn(lastSubColumn);
    }

    List<TableColumnConfig> allColumns = [];
    for (final column in columns) {
      if (column.range != null) {
        allColumns.addAll(column.range!.columns);
      } else {
        allColumns.add(column);
      }
    }
    final columnIndex = allColumns.indexOf(column);
    if (columnIndex == -1) return false;

    final actualIndex = columnIndex + (isHaveCheckBox ? 2 : 1);

    return actualIndex == fixedLeftColumns;
  }

  ListViewConfigModel adjustLastColumnWidth(Size logicalSize) {
    if (columns.isEmpty) {
      return this;
    }

    // Calculate sum of all columns width
    final totalColumnsWidth = columns.fold(
      0.0,
      (sum, column) => sum + column.width,
    );

    // If total width is smaller than logical size width, adjust the last column
    if (totalColumnsWidth < logicalSize.width) {
      // Calculate sum of all columns except the last one
      final sumExceptLastColumn = columns
          .take(columns.length - 1)
          .fold(0.0, (sum, column) => sum + column.width);

      // Calculate new width for the last column
      final newLastColumnWidth = logicalSize.width - sumExceptLastColumn;

      // Create new list of columns with adjusted last column
      final newColumns = List<TableColumnConfig>.from(columns);
      newColumns[columns.length - 1] = newColumns.last.copyWith(
        width: newLastColumnWidth,
      );

      return copyWith(columns: newColumns);
    }

    return this;
  }

  factory ListViewConfigModel.fromJson(Map<String, dynamic> json) =>
      _$ListViewConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$ListViewConfigModelToJson(this);
  @override
  List<Object?> get props => [columns, name, fixedLeftColumns];
}
