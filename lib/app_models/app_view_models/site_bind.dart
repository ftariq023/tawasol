import 'package:tawasol/app_models/app_utilities/app_helper.dart';

class SiteBind{

  late int siteId;
  late String enSiteName;
  late String arSiteName;
  int? siteTypeId;
  int? mainSiteId;

  String get siteName=>AppHelper.isCurrentArabic?arSiteName:enSiteName;

  String get dropdownText=>siteName;

  SiteBind(this.siteId,this.enSiteName,this.arSiteName,this.mainSiteId,this.siteTypeId);

}