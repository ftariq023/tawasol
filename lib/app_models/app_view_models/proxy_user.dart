import 'package:tawasol/app_models/app_utilities/app_helper.dart';

class ProxyUserModel {
  int id = -1;
  String enFullName = '';
  String arFullName = '';
  String loginName = '';
  int securityLevels = -1;

  ProxyUserModel();

  ProxyUserModel.fromEmpty(dynamic item) {
    id = item['applicationUser']['id'];
    enFullName = item['applicationUser']['enFullName'];
    arFullName = item['applicationUser']['arFullName'];
    securityLevels = item['securityLevels'];
    loginName = item['applicationUser']['loginName'];
  }

  String get proxyUserName =>
      AppHelper.isCurrentArabic ? arFullName : enFullName;

  String get dropdownText => proxyUserName;
}
