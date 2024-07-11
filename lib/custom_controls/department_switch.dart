import 'package:flutter/material.dart';
import 'package:tawasol/theme/theme_provider.dart';

class DepartmentSwitch extends StatefulWidget {
  DepartmentSwitch({super.key, required this.isCurrentDepartment,required this.isCurrentDepartSelected});

  final Function isCurrentDepartSelected;
  bool isCurrentDepartment = false;

  @override
  State<DepartmentSwitch> createState() => _DepartmentSwitchState();
}

class _DepartmentSwitchState extends State<DepartmentSwitch> {
  @override
  Widget build(BuildContext context) {
    return Switch(
        value: widget.isCurrentDepartment,
        activeColor: ThemeProvider.primaryColor,
        onChanged: (val) {

          setState(() {
            widget.isCurrentDepartSelected(val);
            widget.isCurrentDepartment = val;
          });
        });
  }
}
