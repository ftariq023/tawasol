import '../../../app_models/app_utilities/app_helper.dart';

class WfAction {
  int actionID;
  String arActionName;
  String enActionName;

  WfAction(this.actionID, this.enActionName, this.arActionName);

  String get actionName => AppHelper.isCurrentArabic ? arActionName : enActionName;

  String get dropdownText => actionName;
}
