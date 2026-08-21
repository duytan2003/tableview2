// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_column_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RangeData _$RangeDataFromJson(Map<String, dynamic> json) => RangeData(
  start: (json['start'] as num).toInt(),
  end: (json['end'] as num).toInt(),
  groupTitle: json['groupTitle'] as String,
  columns: (json['columns'] as List<dynamic>)
      .map((e) => TableColumnConfig.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RangeDataToJson(RangeData instance) => <String, dynamic>{
  'start': instance.start,
  'end': instance.end,
  'groupTitle': instance.groupTitle,
  'columns': instance.columns,
};

TableColumnConfig _$TableColumnConfigFromJson(Map<String, dynamic> json) =>
    TableColumnConfig(
      title: json['title'] as String,
      width: (json['width'] as num).toDouble(),
      key: json['key'] as String,
      isCenter: json['isCenter'] as bool? ?? true,
      isFilter: json['isFilter'] as bool? ?? false,
      minWidth: (json['minWidth'] as num?)?.toDouble() ?? 70.0,
      maxWidth: (json['maxWidth'] as num?)?.toDouble() ?? 1000.0,
      isCanFreezed: json['isCanFreezed'] as bool? ?? true,
      isShow: json['isShow'] as bool? ?? true,
      isActiveFilter: json['isActiveFilter'] as bool? ?? false,
      range: json['range'] == null
          ? null
          : RangeData.fromJson(json['range'] as Map<String, dynamic>),
      isFlexible: json['isFlexible'] as bool? ?? false,
    );

Map<String, dynamic> _$TableColumnConfigToJson(TableColumnConfig instance) =>
    <String, dynamic>{
      'title': instance.title,
      'key': instance.key,
      'isCenter': instance.isCenter,
      'isFilter': instance.isFilter,
      'isShow': instance.isShow,
      'minWidth': instance.minWidth,
      'maxWidth': instance.maxWidth,
      'isCanFreezed': instance.isCanFreezed,
      'isActiveFilter': instance.isActiveFilter,
      'range': instance.range,
      'isFlexible': instance.isFlexible,
      'width': instance.width,
    };
