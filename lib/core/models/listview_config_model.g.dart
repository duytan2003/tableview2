// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listview_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListViewConfigModel _$ListViewConfigModelFromJson(Map<String, dynamic> json) =>
    ListViewConfigModel(
      columns: (json['columns'] as List<dynamic>)
          .map((e) => TableColumnConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String,
      fixedLeftColumns: (json['fixedLeftColumns'] as num).toInt(),
      isHaveCheckBox: json['isHaveCheckBox'] as bool? ?? false,
    );

Map<String, dynamic> _$ListViewConfigModelToJson(
  ListViewConfigModel instance,
) => <String, dynamic>{
  'columns': instance.columns,
  'name': instance.name,
  'fixedLeftColumns': instance.fixedLeftColumns,
  'isHaveCheckBox': instance.isHaveCheckBox,
};
