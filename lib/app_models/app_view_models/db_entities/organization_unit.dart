import 'package:tawasol/app_models/app_utilities/app_helper.dart';

class OrganizationUnit {
  late int ouID;
  late String enOuName;
  late String arOuName;
  late bool hasRegistry;
  late bool status;
  late int? securityLevelId;
  late int? relationId;
  late int? parentOUID;
  late int? regOuID;

  OrganizationUnit(
    this.ouID,
    this.arOuName,
    this.enOuName,
    this.hasRegistry,
    this.status,
    this.relationId,
    this.parentOUID,
    this.regOuID,
  );

  String get ouName => AppHelper.isCurrentArabic ? arOuName : enOuName;
  String get dropdownText => ouName;

  OrganizationUnit.forEmpty(dynamic item) {
    ouID = item['id'];
    arOuName = item['arName'];
    enOuName = item['enName'];
    hasRegistry = item['hasRegistry'];
    status = item['status'];
    relationId = item['relationId'];
    parentOUID = item['parent'];
    regOuID = item['regouId'];
  }
}
