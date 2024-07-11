import 'package:tawasol/app_models/app_view_models/announcement_model.dart';
import 'package:tawasol/app_models/app_view_models/securityLevel.dart';
import 'package:tawasol/app_models/service_models/service_urls.dart';

import '../app_utilities/app_helper.dart';
import 'department.dart';

class UserSession {
  String token = '';
  int id = -1;
  int defaultOUID = -1;
  String userName = '';
  String password = '';
  String enJobTitle = '';
  String arJobTitle = '';
  String arFullName = '';
  String enFullName = '';
  String proxyEnName = '';
  String proxyArName = '';
  int securityLevels = -1;
  int? relatedBooksStatus;
  // bool isManager=false;
  int regOuId = -1;

  //Permissions
  bool isElectronicSignatureEnabled = false;
  bool isUserInboxEnabled = false;
  bool isSentItemsEnabled = false;
  bool isEmployeeFollowupEnabled = false;
  bool isSearchEnabled = false;
  bool outOfOffice = false;
  bool isGeneralSearchEnabled = false;
  bool isIncomingSearchEnabled = false;
  bool isOutgoingSearchEnabled = false;
  bool isInternalSearchEnabled = false;

  bool hasRegistry = false;
  bool isElectronicSignatureMemoEnabled = false;
  bool isPrintDocumentEnabled = false;

  int ouId = -1;
  String arOuName = '';
  String enOuName = '';
  bool isBiometricEnabled = false;

  List<DepartmentModel> userDepartments = [];
  List<SecurityLevel> securityLevelList = [];
  List<AnnouncementModel> announcements = [];

  String get jobTitle => AppHelper.isCurrentArabic ? arJobTitle : enJobTitle;

  String get proxyFullName => AppHelper.isCurrentArabic ? proxyArName : proxyEnName;

  bool get searchEnabled => isIncomingSearchEnabled || isOutgoingSearchEnabled || isInternalSearchEnabled || isGeneralSearchEnabled;

  String get fullName => AppHelper.isCurrentArabic ? arFullName : enFullName;

  String get ouName => AppHelper.isCurrentArabic ? arOuName : enOuName;

  // String get ouFullName {
  //   try {
  //     return hasRegistry
  //         ? ouName
  //         : "$ouName - ${userDepartments.firstWhere((dept) => dept.regOuId == regOuId).ouName}";
  //   } catch (ex) {
  //     return ouName;
  //   }
//  }

  UserSession();

  UserSession.fromEmpty(dynamic item) {
    try {
      token = item['rs']['token'];
      id = item['rs']['userInfo']['id'];
      defaultOUID = item['rs']['userInfo']['defaultOUID'];

      userName = item['rs']['userInfo']['domainName'];
      password = item['password'];
      isBiometricEnabled = item['isBiometricEnabled'];
      arJobTitle = item['rs']['userInfo']['jobTitle']['arName'];
      enJobTitle = item['rs']['userInfo']['jobTitle']['enName'];
      arFullName = item['rs']['userInfo']['arFullName'];
      enFullName = item['rs']['userInfo']['enFullName'];
      outOfOffice = item['rs']['userInfo']['outOfOffice'];
      securityLevels = item['rs']['ou']['securityLevels'];
      ouId = item['rs']['ou']['id'];
      regOuId = item['rs']['ou']['ouRegistryID'];
      //isManager= item["rs"]["manager"];
      arOuName = item['rs']['ouInfo']['arName'];
      enOuName = item['rs']['ouInfo']['enName'];
      relatedBooksStatus = item["rs"]["globalSetting"]["wFRelatedBookStatus"];
      if (item["rs"]["ou"]["proxyUser"] != null) {
        proxyEnName = item["rs"]["ou"]["proxyUser"]["enFullName"];
        proxyArName = item["rs"]["ou"]["proxyUser"]["arFullName"];
      }

      isElectronicSignatureEnabled = item["rs"]["permissions"].toString().contains(AppPermKeys.electronicSignature);

      isElectronicSignatureMemoEnabled = item["rs"]["permissions"].toString().contains(AppPermKeys.electronicSignatureMemo);

      isUserInboxEnabled = item["rs"]["permissions"].toString().contains(AppPermKeys.userInbox);
      isPrintDocumentEnabled = item["rs"]["permissions"].toString().contains(AppPermKeys.printDocument);

      isSentItemsEnabled = item["rs"]["permissions"].toString().contains(AppPermKeys.sentItems);

      isEmployeeFollowupEnabled = item["rs"]["permissions"].toString().contains(AppPermKeys.employeeFollowup);

      isGeneralSearchEnabled = item["rs"]["permissions"].toString().contains(AppPermKeys.generalSearch);

      isIncomingSearchEnabled = item["rs"]["permissions"].toString().contains(AppPermKeys.incomingSearch);

      isOutgoingSearchEnabled = item["rs"]["permissions"].toString().contains(AppPermKeys.outgoingSearch);

      isInternalSearchEnabled = item["rs"]["permissions"].toString().contains(AppPermKeys.internalSearch);

      for (var department in item['rs']['ouList']) {
        userDepartments.add(DepartmentModel.forEmpty(department));
      }

      for (var securityLevel in item['rs']['globalLookup']['securityLevel']) {
        securityLevelList.add(SecurityLevel(securityLevel["id"], securityLevel["lookupKey"], securityLevel["defaultArName"], securityLevel["defaultEnName"]));
      }

      for (var announcement in item['rs']['privateAnnounce']) {
        announcements.add(AnnouncementModel(
          announcement["itemOrder"],
          announcement["enSubject"],
          announcement["enBody"],
          announcement["arSubject"],
          announcement["arBody"],
        ));
      }
    } catch (e) {
      print(e);
    }
  }
}
