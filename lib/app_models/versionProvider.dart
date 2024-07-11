import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionProvider extends ChangeNotifier {
  String _version = '';
  static String depName = "";
  // String _buildNumber = '';

  String get version => _version;
  // String get buildNumber => _buildNumber;

  Future<void> loadVersionInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _version = packageInfo.version;
      // _buildNumber = packageInfo.buildNumber;
      // print('Version: $_version, Build number: $_buildNumber');
    } catch (e) {
      // Handle the exception or log the error
      print('Error fetching version info: $e');
    }
    notifyListeners();
  }
}
