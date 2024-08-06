import '../../../app_models/app_utilities/app_helper.dart';
import '../../app_utilities/app_ui_helper.dart';

class SearchResultItem {
  SearchResultItem();

  SearchResultItem.fromEmpty(dynamic item) {
    try {
      vsID = item["vsId"];
      // wobNumber = item['generalStepElm']['workObjectNumber'] ?? '';
      docSubject = item["docSubject"].toString().trim().replaceAll("\n\n\n", " ").replaceAll("\n\n", " ").replaceAll("\n", " ") ?? '';
      docSerial = item["docFullSerial"] ?? '';
      comment = item["docNotes"] ?? '';
      actionDate = AppUIHelper.timeStampToDate(item["docDate"]);
      classDescription = item["classDescription"];
      securityLevelId = item["securityLevelInfo"]["id"];
      arSecurityLevel = item["securityLevelInfo"]["arName"];
      enSecurityLevel = item["securityLevelInfo"]["enName"];
      arActionName = item["docStatusInfo"]["arName"];
      enActionName = item["docStatusInfo"]["enName"];

      if (item["siteInfo"] != null) {
        arMainSite = item["siteInfo"]["mainSite"]["arName"];
        enMainSite = item["siteInfo"]["mainSite"]["enName"];

        arSubSite = item["siteInfo"]["subSite"]["arName"];
        enSubSite = item["siteInfo"]["subSite"]["enName"];
      }
    } catch (e) {
      print(e);
    }
  }

  late String vsID;
  late String docSubject;

  late String docSerial;
  late String? comment;
  late DateTime actionDate;

  //docClas=classDescription
  late String classDescription;
  late int securityLevelId;

//docStatusInfo=actionName
  late String arActionName;
  late String enActionName;
  late String arSecurityLevel;
  late String enSecurityLevel;

  String enMainSite = '';
  String arMainSite = '';

  //
  // String wobNumber = '';

  String get mainSite => AppHelper.isCurrentArabic ? arMainSite : enMainSite;

  String enSubSite = '';
  String arSubSite = '';
  String get subSite => AppHelper.isCurrentArabic ? arSubSite : enSubSite;

  String get actionName => AppHelper.isCurrentArabic ? arActionName : enActionName;

  String get securityLevelName => AppHelper.isCurrentArabic ? arSecurityLevel : enSecurityLevel;
}
