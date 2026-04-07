import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'table_column_config.g.dart';

class ColumnTitleInfo extends Equatable {
  final String key;
  final String value;

  const ColumnTitleInfo({required this.key, required this.value});

  @override
  List<Object?> get props => [key, value];
}

/// Represents a range of columns that should be merged in header
@JsonSerializable()
class RangeData extends Equatable {
  final int start;
  final int end;
  final String groupTitle;
  final List<TableColumnConfig> columns;

  const RangeData({
    required this.start,
    required this.end,
    required this.groupTitle,
    required this.columns,
  });

  int get length => end - start + 1;

  bool contains(int index) => index >= start && index <= end;

  RangeData copyWith({
    int? start,
    int? end,
    String? groupTitle,
    List<TableColumnConfig>? columns,
  }) => RangeData(
    start: start ?? this.start,
    end: end ?? this.end,
    groupTitle: groupTitle ?? this.groupTitle,
    columns: columns ?? this.columns,
  );

  factory RangeData.fromJson(Map<String, dynamic> json) =>
      _$RangeDataFromJson(json);
  Map<String, dynamic> toJson() => _$RangeDataToJson(this);

  @override
  List<Object?> get props => [start, end, groupTitle, columns];
}

@JsonSerializable()
class TableColumnConfig extends Equatable {
  final String title;
  @JsonKey(name: 'width')
  final double _width;
  final String key;
  final bool isCenter;
  final bool isSortable;
  final double minWidth;
  final double maxWidth;
  final bool isCanFreezed;
  final RangeData? range;

  const TableColumnConfig({
    required this.title,
    required double width,
    required this.key,
    this.isCenter = true,
    this.isSortable = false,
    this.minWidth = 50.0,
    this.maxWidth = 1000.0,
    this.isCanFreezed = true,
    this.range,
  }) : _width = width;

  factory TableColumnConfig.fromJson(Map<String, dynamic> json) =>
      _$TableColumnConfigFromJson(json);

  Map<String, dynamic> toJson() => _$TableColumnConfigToJson(this);

  TableColumnConfig copyWith({
    String? title,
    double? width,
    String? key,
    bool? isCenter,
    bool? isSortable,
    double? minWidth,
    double? maxWidth,
    bool? isCanFreezed,
    RangeData? range,
  }) => TableColumnConfig(
    title: title ?? this.title,
    width: width ?? _width,
    key: key ?? this.key,
    isCenter: isCenter ?? this.isCenter,
    isSortable: isSortable ?? this.isSortable,
    minWidth: minWidth ?? this.minWidth,
    maxWidth: maxWidth ?? this.maxWidth,
    isCanFreezed: isCanFreezed ?? this.isCanFreezed,
    range: range ?? this.range,
  );
  double get width => range != null
      ? range!.columns.map((e) => e.width).reduce((a, b) => a + b)
      : _width;

  /// Check if this column is part of a merged group
  bool get isMerged => range != null;

  /// Check if this column is the start of a merged group
  bool get isMergeStart => range != null && range!.start == range!.end;

  @override
  List<Object?> get props => [
    title,
    _width,
    key,
    isCenter,
    isSortable,
    minWidth,
    maxWidth,
    range,
  ];

  TableColumnConfig updateTitleFromList(List<ColumnTitleInfo> updates) {
    TableColumnConfig updated = this;
    for (final update in updates) {
      if (update.key == key) {
        updated = updated.copyWith(title: '$title \n${update.value}');
        break;
      }
    }

    if (updated.range != null) {
      final updatedSubColumns = updated.range!.columns
          .map((sub) => sub.updateTitleFromList(updates))
          .toList();
      updated = updated.copyWith(
        range: updated.range!.copyWith(columns: updatedSubColumns),
      );
    }
    return updated;
  }
}
