import '../models/table_column_config.dart';

typedef ListViewConfigUpdatedCallback = void Function(TableColumnConfig, bool);
typedef ListViewSortCallback = void Function(int columnIndex, bool ascending);
