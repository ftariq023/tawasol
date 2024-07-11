import 'package:tawasol/app_models/app_utilities/app_helper.dart';

class FollowupOu {
  String arName = '';
  String enName = '';
  int id = -1;
  int securityLevels=-1;

  String get ouName => AppHelper.isCurrentArabic ? arName : enName;
  String get dropdownText => ouName;

  FollowupOu();

  FollowupOu.forEmpty(dynamic item) {
    arName = item['arName'];
    enName = item['enName'];
    id = item['id'];
    securityLevels = item['securityLevels']??-1;
  }
}
