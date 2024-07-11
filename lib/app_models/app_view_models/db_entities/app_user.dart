import 'package:tawasol/app_models/app_utilities/app_helper.dart';

class AppUser {
  int id;
  int ouId;
  int regOuId;
  String enOuName;
  String arOuName;
  String loginName;
  String enAppUserName;
  String arAppUserName;
  int? relationId;
  int? securityLevelId;
  int? proxyUserID;
  int? proxyUserOUID;
  DateTime? proxyUserStartDate;
  DateTime? proxyUserEndDate;
  bool? isOutOfOffice;
  int? proxyUserSecurityLevels;
  bool isSelectedDeptHasRegistry;
  bool isEmailNotificationsOn;
  bool isSMSNotificationsOn;

  AppUser(
    this.id,
    this.loginName,
    this.enAppUserName,
    this.arAppUserName,
    this.relationId,
    this.securityLevelId,
    this.proxyUserID,
    this.proxyUserOUID,
    this.proxyUserStartDate,
    this.proxyUserEndDate,
    this.proxyUserSecurityLevels,
    this.isOutOfOffice,
    this.isSMSNotificationsOn,
    this.isEmailNotificationsOn,
    this.ouId,
    this.regOuId,
    this.arOuName,
    this.enOuName,
    this.isSelectedDeptHasRegistry,
  );

  String get appUserName => AppHelper.isCurrentArabic ? arAppUserName : enAppUserName;

  String get ouName => AppHelper.isCurrentArabic ? arOuName : enOuName;

  String get dropdownText => appUserName; // + (ouId == regOuId && isSelectedDeptHasRegistry ? '' : ' - $ouName');
}
