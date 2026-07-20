import 'package:flutter/material.dart';
import 'package:tableview2/tableview2.dart';

void main() {
  runApp(const TableView2ExampleApp());
}

class TableView2ExampleApp extends StatelessWidget {
  const TableView2ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TableView2 Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TableView2DemoPage(),
    );
  }
}

class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.salary,
    required this.status,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String department;
  final int salary;
  final String status;
}

class TableView2DemoPage extends StatefulWidget {
  const TableView2DemoPage({super.key});

  @override
  State<TableView2DemoPage> createState() => _TableView2DemoPageState();
}

class _TableView2DemoPageState extends State<TableView2DemoPage> {
  static const _headingRowHeight = 40.0;
  static const _dataRowHeight = 44.0;

  late List<Employee> _employees;
  late ListViewConfigModel _listViewConfig;
  final ValueNotifier<int> _hoveredIndexNotifier = ValueNotifier<int>(-1);

  int? _sortColumnIndex;
  bool _sortAscending = true;
  bool _showEmptyState = false;

  @override
  void initState() {
    super.initState();
    _employees = _sampleEmployees();
    _listViewConfig = _defaultConfig();
  }

  @override
  void dispose() {
    _hoveredIndexNotifier.dispose();
    super.dispose();
  }

  List<Employee> _sampleEmployees() => const [
    Employee(
      id: 'NV001',
      name: 'Nguyễn Văn An',
      email: 'an.nguyen@example.com',
      phone: '0901234567',
      department: 'Kỹ thuật',
      salary: 25000000,
      status: 'Đang làm',
    ),
    Employee(
      id: 'NV002',
      name: 'Trần Thị Bình',
      email: 'binh.tran@example.com',
      phone: '0912345678',
      department: 'Nhân sự',
      salary: 18000000,
      status: 'Đang làm',
    ),
    Employee(
      id: 'NV003',
      name: 'Lê Minh Cường',
      email: 'cuong.le@example.com',
      phone: '0923456789',
      department: 'Kinh doanh',
      salary: 22000000,
      status: 'Nghỉ phép',
    ),
    Employee(
      id: 'NV004',
      name: 'Phạm Thu Dung',
      email: 'dung.pham@example.com',
      phone: '0934567890',
      department: 'Kế toán',
      salary: 20000000,
      status: 'Đang làm',
    ),
    Employee(
      id: 'NV005',
      name: 'Hoàng Văn Em',
      email: 'em.hoang@example.com',
      phone: '0945678901',
      department: 'Marketing',
      salary: 19500000,
      status: 'Đang làm',
    ),
    Employee(
      id: 'NV006',
      name: 'Vũ Thị Phương',
      email: 'phuong.vu@example.com',
      phone: '0956789012',
      department: 'Kỹ thuật',
      salary: 28000000,
      status: 'Đang làm',
    ),
    Employee(
      id: 'NV007',
      name: 'Đỗ Quang Huy',
      email: 'huy.do@example.com',
      phone: '0967890123',
      department: 'Kinh doanh',
      salary: 21000000,
      status: 'Nghỉ việc',
    ),
    Employee(
      id: 'NV008',
      name: 'Bùi Lan Hương',
      email: 'huong.bui@example.com',
      phone: '0978901234',
      department: 'Nhân sự',
      salary: 17500000,
      status: 'Đang làm',
    ),
    Employee(
      id: 'NV009',
      name: 'Ngô Đức Kiên',
      email: 'kien.ngo@example.com',
      phone: '0989012345',
      department: 'Kỹ thuật',
      salary: 32000000,
      status: 'Đang làm',
    ),
    Employee(
      id: 'NV010',
      name: 'Đặng Thảo Linh',
      email: 'linh.dang@example.com',
      phone: '0990123456',
      department: 'Marketing',
      salary: 18800000,
      status: 'Đang làm',
    ),
  ];

  ListViewConfigModel _defaultConfig() {
    return ListViewConfigModel(
      name: 'employees',
      fixedLeftColumns: 2,
      isHaveCheckBox: true,
      columns: [
        const TableColumnConfig(
          title: 'Mã NV',
          key: 'id',
          width: 100,
          isSortable: true,
          isCenter: false,
        ),
        const TableColumnConfig(
          title: 'Họ tên',
          key: 'name',
          width: 180,
          isSortable: true,
          isCenter: false,
        ),
        TableColumnConfig(
          title: 'Liên hệ',
          key: 'contact',
          width: 300,
          range: RangeData(
            start: 2,
            end: 3,
            groupTitle: 'Thông tin liên hệ',
            columns: const [
              TableColumnConfig(
                title: 'Email',
                key: 'email',
                width: 180,
                isSortable: true,
                isCenter: false,
              ),
              TableColumnConfig(
                title: 'SĐT',
                key: 'phone',
                width: 120,
                isCenter: false,
              ),
            ],
          ),
        ),
        const TableColumnConfig(
          title: 'Phòng ban',
          key: 'department',
          width: 140,
          isSortable: true,
          isCenter: false,
        ),
        const TableColumnConfig(
          title: 'Lương',
          key: 'salary',
          width: 120,
          isSortable: true,
          isCenter: true,
        ),
        const TableColumnConfig(
          title: 'Trạng thái',
          key: 'status',
          width: 120,
          isCenter: true,
        ),
        const TableColumnConfig(
          title: 'Ghi chú',
          key: 'note',
          width: 200,
          isCenter: false,
        ),
      ],
    );
  }

  final Set<String> _selectedIds = {};

  void _onSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.addAll(_employees.map((e) => e.id));
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _onRowSelectChanged(String id, bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = ascending;
      }

      final sortKey = _sortKeyForColumn(columnIndex);
      if (sortKey == null) return;

      _employees.sort((a, b) {
        final comparison = _compareByKey(a, b, sortKey);
        return _sortAscending ? comparison : -comparison;
      });
    });
  }

  String? _sortKeyForColumn(int columnIndex) {
    if (_listViewConfig.isHaveCheckBox) {
      columnIndex -= 1;
    }
    if (columnIndex < 0) return null;

    final flatColumns = <TableColumnConfig>[];
    for (final column in _listViewConfig.columns) {
      if (column.range != null && column.range!.columns.isNotEmpty) {
        flatColumns.addAll(column.range!.columns);
      } else {
        flatColumns.add(column);
      }
    }

    if (columnIndex >= flatColumns.length) return null;
    return flatColumns[columnIndex].key;
  }

  int _compareByKey(Employee a, Employee b, String key) {
    switch (key) {
      case 'id':
        return a.id.compareTo(b.id);
      case 'name':
        return a.name.compareTo(b.name);
      case 'email':
        return a.email.compareTo(b.email);
      case 'phone':
        return a.phone.compareTo(b.phone);
      case 'department':
        return a.department.compareTo(b.department);
      case 'salary':
        return a.salary.compareTo(b.salary);
      case 'status':
        return a.status.compareTo(b.status);
      default:
        return 0;
    }
  }

  List<DataRowTableView> _buildRows() {
    return List.generate(_employees.length, (index) {
      final employee = _employees[index];
      final isChecked = _selectedIds.contains(employee.id);

      return DataRowTableView(
        index: index,
        isChecked: isChecked,
        selected: isChecked,
        onSelectChanged: (value) => _onRowSelectChanged(employee.id, value),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Đã chọn: ${employee.name}')));
        },
        cells: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(employee.id),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(employee.name, overflow: TextOverflow.ellipsis),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(employee.email, overflow: TextOverflow.ellipsis),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(employee.phone),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(employee.department),
          ),
          Text(_formatSalary(employee.salary)),
          _StatusChip(status: employee.status),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('—'),
          ),
        ],
      );
    });
  }

  String _formatSalary(int salary) {
    final text = salary.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final positionFromEnd = text.length - i;
      buffer.write(text[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()} đ';
  }

  @override
  Widget build(BuildContext context) {
    final rows = _showEmptyState ? <DataRowTableView>[] : _buildRows();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TableView2 Example'),
        actions: [
          IconButton(
            tooltip: _showEmptyState ? 'Hiện dữ liệu' : 'Ẩn dữ liệu',
            onPressed: () => setState(() => _showEmptyState = !_showEmptyState),
            icon: Icon(_showEmptyState ? Icons.table_rows : Icons.table_chart),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đã chọn: ${_selectedIds.length}/${_employees.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Cuộn ngang/dọc, ghim cột trái, sắp xếp, chọn nhiều dòng',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TableView2(
                    rows: rows,
                    dataRowHeight: _dataRowHeight,
                    headingRowHeight: _headingRowHeight,
                    fixedRowCount: 2,
                    listViewConfig: _listViewConfig,
                    onConfigUpdated: (column, isFixed) {
                      final result = _listViewConfig
                          .updateColumnAndCalculateFixed(
                            column,
                            isFixed: isFixed,
                          );
                      setState(() {
                        _listViewConfig = _listViewConfig.copyWith(
                          columns: result.columns,
                          fixedLeftColumns: result.fixedLeftColumns,
                        );
                      });
                    },
                    onSelectAll: _onSelectAll,
                    onSort: _onSort,
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    hoveredIndexNotifier: _hoveredIndexNotifier,
                    emptyMessage: 'Không có nhân viên nào',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Đang làm' => Colors.green,
      'Nghỉ phép' => Colors.orange,
      'Nghỉ việc' => Colors.red,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
