import 'package:flutter/material.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';

import '../app_models/app_view_models/department.dart';

class DepartmentList extends StatelessWidget {
  DepartmentList({super.key});

  final List<DepartmentModel> userDepartments =
      AppHelper.currentUserSession.userDepartments;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: userDepartments.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          DepartmentModel currentDepartment = userDepartments[index];
          return ListTile(
            leading: const Icon(Icons.account_balance_outlined),
            title: Text(
                '${currentDepartment.ouName} ${currentDepartment.hasRegistry == false ? ' - ${currentDepartment.regOuName}' : ''}'),
          );
        });
  }
}
