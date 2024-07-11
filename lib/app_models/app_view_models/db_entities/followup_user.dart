import '../../app_utilities/app_helper.dart';

class FollowupUser {
  String arName = '';
  String enName = '';
  int id = -1;
  int ouId = -1;
  String domainName = '';

  String get followupUserName => AppHelper.isCurrentArabic ? arName : enName;
  String get dropdownText => followupUserName;

  FollowupUser();

  FollowupUser.forEmpty(dynamic item) {
    arName = item['arName'];
    enName = item['enName'];
    id = item['id'];
    ouId = item['ouId'];
    domainName = item['domainName'];
  }
}
