import 'package:tawasol/app_models/app_utilities/app_helper.dart';

class SecurityLevel{
  late int securityLevelId;
  late int lookupKey;
  late String enSecurityLevel;
  late String arSecurityLevel;

  String get securityLevelName=>AppHelper.isCurrentArabic?arSecurityLevel:enSecurityLevel;
  String get dropdownText=>securityLevelName;

  SecurityLevel(this.securityLevelId,this.lookupKey, this.arSecurityLevel,this.enSecurityLevel);
}