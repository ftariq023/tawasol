import 'package:tawasol/app_models/app_utilities/app_helper.dart';

class AnnouncementModel {
  String enSubject;
  String arSubject;
  String arBody;
  String enBody;
  int itemOrder;

  String get subject => AppHelper.isCurrentArabic ? arSubject : enSubject;
  String get body => AppHelper.isCurrentArabic ? arBody : enBody;

  AnnouncementModel(this.itemOrder, this.enSubject, this.enBody, this.arSubject, this.arBody);
}
