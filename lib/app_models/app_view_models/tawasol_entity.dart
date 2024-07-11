import 'dart:convert';
import 'dart:typed_data';

import '../app_utilities/app_helper.dart';

class TawasolEntity {
  String serviceUrl = ''; // // http://eblaepm.no-ip.org:9080

  String entityCode = ''; //identifier motc//moi
  String entityArabicName = ''; //tawasolEntity arName
  String entityEnglishName = ''; //tawasolEntity enName
  String applicationArabicDisplayName = 'المراسلات'; ////appArName
  String applicationEnglishDisplayName = 'Al Morasalat';

  ///appEnName
  String tawasolVersionNumber = ''; //version
  bool isOTPEnabled = false; //otpEnabled
  String logoContent = '';

  String get appName => AppHelper.isCurrentArabic ? applicationArabicDisplayName : applicationEnglishDisplayName;

  Uint8List get logo => base64Decode(logoContent);

  TawasolEntity();

  TawasolEntity.fromEmpty(dynamic item) {
    entityCode = item['rs']['tawasolEntity']['identifier'];
    entityArabicName = item['rs']['tawasolEntity']['arName'];
    entityEnglishName = item['rs']['tawasolEntity']['enName'];
    applicationArabicDisplayName = item['rs']['tawasolEntity']['appArName'];
    applicationEnglishDisplayName = item['rs']['tawasolEntity']['appEnName'];
    tawasolVersionNumber = item['rs']['tawasolEntity']['version'];
    isOTPEnabled = item['rs']['tawasolEntity']['otpEnabled'];
    logoContent = item['rs']['logo'];
    serviceUrl = item['serviceUrl'];
  }
}
