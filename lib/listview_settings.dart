import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tableview2/button_tableview.dart';
import 'package:tableview2/dialog_table_view.dart';
import 'package:tableview2/tableview2.dart';

import 'scaled_checkbox.dart';

class ListViewSettings extends StatefulWidget {
  const ListViewSettings({
    super.key,
    required this.columnConfig,
    required this.onUpdate,
    required this.listViewConfig,
  });

  final TableColumnConfig columnConfig;
  final void Function(TableColumnConfig newConfig, bool isFixed) onUpdate;
  final ListViewConfigModel listViewConfig;

  @override
  State<ListViewSettings> createState() => _ListViewSettingsState();
}

class _ListViewSettingsState extends State<ListViewSettings> {
  late TextEditingController _widthController;
  late bool _isFixed, _isCenter;

  @override
  void initState() {
    super.initState();
    _widthController = TextEditingController(
      text: widget.columnConfig.width.toString(),
    );
    _isFixed = widget.listViewConfig.isFixedColumn(widget.columnConfig);
    _isCenter = widget.columnConfig.isCenter;
  }

  @override
  void dispose() {
    _widthController.dispose();
    super.dispose();
  }

  // Validate width and show error if invalid. Returns null if invalid, or the parsed width if valid.
  double? _validateWidth(String value) {
    final width = double.tryParse(value);
    if (width == null) {
      _showError('Chiều rộng cột không hợp lệ');
      return null;
    }
    if (width < widget.columnConfig.minWidth) {
      _showError('Chiều rộng cột phải lớn hơn ${widget.columnConfig.minWidth}');
      return null;
    }
    if (width > widget.columnConfig.maxWidth) {
      _showError('Chiều rộng cột phải nhỏ hơn ${widget.columnConfig.maxWidth}');
      return null;
    }
    return width;
  }

  void _showError(String message) {
    IDialogTableView.showErrorMessage(context: context, message: message);
  }

  void _submitWidth([String? value]) {
    final width = _validateWidth(value ?? _widthController.text);
    if (width == null) return;
    if (_isFixed) {
      final sumOfColumnsWidthToColumn = widget.listViewConfig
          .sumOfColumnsWidthToColumn(widget.columnConfig);
      final view = View.of(context);
      double widthOfScreen = view.physicalSize.width / view.devicePixelRatio;
      if ((sumOfColumnsWidthToColumn + width) > widthOfScreen) {
        _showError('Tổng chiều rộng cột cố định vượt quá chiều rộng của bảng');
        return;
      }
      widget.onUpdate(
        widget.columnConfig.copyWith(width: width, isCenter: _isCenter),
        _isFixed,
      );
    } else {
      widget.onUpdate(
        widget.columnConfig.copyWith(width: width, isCenter: _isCenter),
        _isFixed,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _buildListViewSettings(MediaQuery.sizeOf(context).width / 3);
  }

  Widget _buildListViewSettings(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.0,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.0,
            children: [
              SvgPicture.asset(
                'assets/actions/ico_column.svg',
                package: 'tableview2',
                width: 16,
                height: 16,
              ),
              const Text(
                'Setup Column',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Text(
            widget.columnConfig.title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          TextField(
            controller: _widthController,
            decoration: const InputDecoration(
              labelText: 'Độ rộng cột',
              hintText: 'Nhập độ rộng cột...',
            ),
            keyboardType: TextInputType.number,
            onSubmitted: _submitWidth,
          ),
          Text(
            'Giới hạn: Min = ${widget.columnConfig.minWidth} & Max = ${widget.columnConfig.maxWidth}',
            style: TextStyle(
              color: Color(0xFF324F6A),
              fontFamily: 'Montserrat',
              fontSize: 12,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              ScaledCheckboxTableView(
                value: _isFixed,
                enabled: widget.columnConfig.isCanFreezed,
                activeColor: Colors.blueAccent,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _isFixed = value;
                    });
                  }
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'Freeze Column',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: [
              ScaledCheckboxTableView(
                value: _isCenter,
                activeColor: Colors.blueAccent,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _isCenter = value;
                    });
                  }
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'Center Column',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8.0,
            children: [
              ButtonTableView(
                leading: SvgPicture.asset(
                  'assets/actions/ico_cancel.svg',
                  package: 'tableview2',
                ),
                title: 'Hủy',
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                onPressed: () => Navigator.pop(context),
              ),
              ButtonTableView(
                leading: SvgPicture.asset(
                  'assets/actions/ico_action_return.svg',
                  package: 'tableview2',
                ),
                title: 'Cập Nhật',
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                onPressed: () => _submitWidth(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
