import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/app_models/app_view_models/user_session.dart';
import 'package:tawasol/app_models/service_models/service_urls.dart';
import 'package:tawasol/l10n/l10n.dart';

import '../app_view_models/tawasol_entity.dart';

class CacheManager {
  // Add the following methods to clear user session and entity details caches

  // static Future<void> clearUserSessionCache() async {
  //   await clearCacheFile(AppCacheKeys.userSessionFileName);
  // }

  // static Future<void> clearEntityDetailsCache() async {
  //   await clearCacheFile(AppCacheKeys.entityFileName);
  // }

  // static Future<void> clearCacheFile(String fileName) async {
  //   try {
  //     File cacheFile = await getFileByPath(fileName);
  //     if (await cacheFile.exists()) {
  //       await cacheFile.delete();
  //     }
  //   } catch (e) {
  //     print('Error clearing cache file: $e');
  //   }
  // }

  static Future<Directory> get localDirectoryPath async {
    return await getTemporaryDirectory();
  }

  static Future<File> getFileByPath(String fileName) async {
    return File('${(await localDirectoryPath).path}/$fileName');
  }

  static Future<TawasolEntity> getEntityDetailsLocally(String fileName) async {
    File entityFile = await getFileByPath(fileName);
    if (entityFile.existsSync()) {
      var jsonData = entityFile.readAsStringSync(encoding: utf8);
      var jsonBody = json.decode(jsonData);
      return TawasolEntity.fromEmpty(jsonBody);
    }
    return TawasolEntity();
  }

  static Future<TawasolEntity> saveEntityDetailsLocally(String jsonEntity, String serviceURL) async {
    try {
      var data = json.decode(jsonEntity);
      data['serviceUrl'] = serviceURL;
      var data1 = json.encode(data);
      File newEntityFile = await getFileByPath(AppCacheKeys.entityFileName);
      newEntityFile.writeAsStringSync(data1, mode: FileMode.write, encoding: utf8, flush: true);

      var jsonData = newEntityFile.readAsStringSync(encoding: utf8);
      var jsonBody = json.decode(jsonData);
      AppHelper.currentTawasolEntity = TawasolEntity.fromEmpty(jsonBody);

      return TawasolEntity.fromEmpty(jsonBody);
    } catch (e) {
      return TawasolEntity();
    }
  }

  static Future<bool> saveUserSessionLocally({required String jsonUserSession, required String password, required bool isBioMetricEnabled}) async {
    try {
      var data = json.decode(jsonUserSession);
      data['password'] = password;
      data['isBiometricEnabled'] = isBioMetricEnabled;

      var data1 = json.encode(data);
      File userSessionFile = await getFileByPath(AppCacheKeys.userSessionFileName);

      if (await userSessionFile.exists()) {
        await userSessionFile.delete();
        await Future.delayed(const Duration(seconds: 1));
      }

      userSessionFile = await getFileByPath(AppCacheKeys.userSessionFileName);
      await userSessionFile.writeAsString(
        data1,
        mode: FileMode.write,
        encoding: utf8,
        flush: true,
      );

      var jsonData = userSessionFile.readAsStringSync(encoding: utf8);
      var jsonBody = json.decode(jsonData);
      await Future.delayed(const Duration(seconds: 1));
      AppHelper.currentUserSession = UserSession.fromEmpty(jsonBody);
      return true;
    } catch (e) {
      return false;
    }
  }

  static void updateBiometric(bool isBiometricEnabled) async {
    try {
      File userSessionFile = await getFileByPath(AppCacheKeys.userSessionFileName);
      if (userSessionFile.existsSync()) {
        String readSession = userSessionFile.readAsStringSync();
        var jsonBody = json.decode(readSession);

        jsonBody['isBiometricEnabled'] = isBiometricEnabled;
        var encodedSession = json.encode(jsonBody);

        userSessionFile.deleteSync(recursive: true);

        userSessionFile = await getFileByPath(AppCacheKeys.userSessionFileName);
        userSessionFile.writeAsStringSync(encodedSession, mode: FileMode.write, encoding: utf8, flush: true);
        // AppHelper.currentUserSession.isBiometricEnabled = isBiometricEnabled;
      }
    } catch (e) {
      print(e);
    }
    // AppHelper.currentUserSession.isBiometricEnabled = isBiometricEnabled;
    //
    //
    // // String data = jsonEncode(AppHelper.currentUserSession);
    // //
    // // File userSessionFile =
    // //     await getFileByPath(AppCacheKeys.userSessionFileName);
    // // if (userSessionFile.existsSync()) {
    // //   userSessionFile.deleteSync(recursive: true);
    // //   userSessionFile = await getFileByPath(AppCacheKeys.userSessionFileName);
    // //
    // //   userSessionFile.writeAsStringSync(data,
    // //       mode: FileMode.write, encoding: utf8, flush: true);
    // // }
  }

  static Future<UserSession> getUserSessionLocally(String fileName) async {
    File userSessionFile = await getFileByPath(fileName);
    if (userSessionFile.existsSync()) {
      var jsonData = userSessionFile.readAsStringSync(encoding: utf8);
      var jsonBody = json.decode(jsonData);
      return UserSession.fromEmpty(jsonBody);
    }
    return UserSession();
  }

  static void globalCache(String selectedLanguage) async {
    File globalFile = await getFileByPath(AppCacheKeys.globalCacheFileName);
    if (globalFile.existsSync()) {
      globalFile.deleteSync(recursive: true);
    }
    globalFile.writeAsStringSync(selectedLanguage, mode: FileMode.write, encoding: utf8, flush: true);
  }

  static Future<String> getGlobalSelectedLanguage() async {
    try {
      File globalFile = await getFileByPath(AppCacheKeys.globalCacheFileName);
      if (globalFile.existsSync()) {
        return globalFile.readAsStringSync(encoding: utf8);
      } else {
        return L10n.all[1].languageCode;
      }
    } catch (e) {
      return 'ar';
    }
  }
}
