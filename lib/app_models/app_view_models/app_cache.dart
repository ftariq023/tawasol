import 'package:tawasol/app_models/app_utilities/app_helper.dart';

class AppCache {
  String? selectedLanguage;
  String? isBiometricEnabled;
  String? userName;
  String? password;
  int? lastOuId;

  AppCache();

  AppCache.fromEmpty(this.selectedLanguage, this.isBiometricEnabled, this.userName, this.password, this.lastOuId) {
    userName = userName ?? AppHelper.currentUserSession.userName;
    password = password ?? AppHelper.currentUserSession.password;
    selectedLanguage = AppHelper.isCurrentArabic ? 'ar' : 'en';
    lastOuId = lastOuId ?? AppHelper.currentUserSession.ouId;
  }
}
