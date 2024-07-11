import 'dart:convert';
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:tawasol/app_models/app_utilities/cache_manager.dart';
import 'package:tawasol/app_models/service_models/my_service_response.dart';

import './my_service_request.dart';
import './service_urls.dart';
import '../app_utilities/app_helper.dart';

class ServiceHandlerBase {
  static bool isAuthenticationNeeded = true;

  static Future<MyServiceResponse> getData({required MyServiceRequest myServiceRequest, bool authenticationRequired = true}) async {
    isAuthenticationNeeded = authenticationRequired;
    try {
      http.Response? response;

      myServiceRequest.headerParameters = await prepareRequestHeaders(myServiceRequest.headerParameters);

      //   await Future.delayed(const Duration(seconds: 2));
      var url = Uri.parse((AppHelper.currentTawasolEntity.serviceUrl.isEmpty ? myServiceRequest.serverBaseUrl : AppHelper.currentTawasolEntity.serviceUrl) + myServiceRequest.serviceRelativeUrl + "");

      // print("printing get request");
      // print(url);
      // print(myServiceRequest.headerParameters);

      response = await http.get(
        url,
        headers: myServiceRequest.headerParameters,
      );

      // print("response");
      // log(response.toString());
      // log(response.body);

      if (response.statusCode == HttpStatusCode.oK) {
        if (myServiceRequest.isDownloadContent) {
          return MyServiceResponse('', HttpStatusCode.oK, true, response.bodyBytes, null);
        } else {
          return MyServiceResponse(utf8.decode(response.bodyBytes), HttpStatusCode.oK, true, null, null);
        }
      } else {
        return MyServiceResponse(utf8.decode(response.bodyBytes), response.statusCode, false, null, null);
      }
    } catch (e) {
      return MyServiceResponse(e.toString(), HttpStatusCode.badRequest, false, null, e.toString());
    }
  }

  static Future<MyServiceResponse> postData({required MyServiceRequest myServiceRequest, bool authenticationRequired = true}) async {
    isAuthenticationNeeded = authenticationRequired;
    http.Response response;
    try {
      myServiceRequest.headerParameters = await prepareRequestHeaders(myServiceRequest.headerParameters);

      // print("myurl");
      // print(AppHelper.currentTawasolEntity.serviceUrl + myServiceRequest.serviceRelativeUrl);

      var url = Uri.parse(
        AppHelper.currentTawasolEntity.serviceUrl + myServiceRequest.serviceRelativeUrl,
      );

      // print("printing put request");
      // print(url);
      // print(myServiceRequest.headerParameters);
      // print(jsonEncode(myServiceRequest.formParameters));

      // print("url");
      // print(url);
      // print((url.toString()).startsWith("http"));

      // String tempUrl = url.toString();
      // if (!tempUrl.startsWith("http")) {
      //   tempUrl = AppServiceURLS.baseUrl + tempUrl;
      // }
      // url = Uri.parse(tempUrl);

      response = await http.post(
        url,
        headers: myServiceRequest.headerParameters,
        body: jsonEncode(myServiceRequest.formParameters),
      );

      // print("code");
      // print(response.statusCode);

      if (response.statusCode == HttpStatusCode.oK) {
        return MyServiceResponse(utf8.decode(response.bodyBytes), HttpStatusCode.oK, true, null, null);
      } else {
        return MyServiceResponse(utf8.decode(response.bodyBytes), response.statusCode, false, null, null);
      }
    } catch (e) {
      print(e);

      return MyServiceResponse(e.toString(), HttpStatusCode.badRequest, false, null, e.toString());
    }
  }

  static Future<MyServiceResponse> putData({required MyServiceRequest myServiceRequest, bool authenticationRequired = true}) async {
    isAuthenticationNeeded = authenticationRequired;
    late http.Response response;
    try {
      myServiceRequest.headerParameters = await prepareRequestHeaders(myServiceRequest.headerParameters);
      var url = Uri.parse(AppHelper.currentTawasolEntity.serviceUrl + myServiceRequest.serviceRelativeUrl);

      response = await http.put(
        url,
        headers: myServiceRequest.headerParameters,
        body: jsonEncode(myServiceRequest.formParameters),
      );

      if (response.statusCode == HttpStatusCode.oK) {
        return MyServiceResponse(utf8.decode(response.bodyBytes), HttpStatusCode.oK, true, null, null);
      } else {
        return MyServiceResponse(utf8.decode(response.bodyBytes), response.statusCode, false, null, null);
      }
    } catch (e) {
      return MyServiceResponse(utf8.decode(response.bodyBytes), response.statusCode, false, null, e.toString());
    }
  }

  static Future<MyServiceResponse> deleteData({required MyServiceRequest myServiceRequest, bool authenticationRequired = true}) async {
    isAuthenticationNeeded = authenticationRequired;
    late http.Response response;
    try {
      myServiceRequest.headerParameters = await prepareRequestHeaders(myServiceRequest.headerParameters);
      var url = Uri.parse(AppHelper.currentTawasolEntity.serviceUrl + myServiceRequest.serviceRelativeUrl);

      response = await http.delete(url, headers: myServiceRequest.headerParameters, body: jsonEncode(myServiceRequest.formParameters));
      if (response.statusCode == HttpStatusCode.oK) {
        return MyServiceResponse(utf8.decode(response.bodyBytes), HttpStatusCode.oK, true, null, null);
      } else {
        return MyServiceResponse(utf8.decode(response.bodyBytes), response.statusCode, false, null, null);
      }
    } catch (e) {
      return MyServiceResponse(utf8.decode(response.bodyBytes), response.statusCode, false, null, e.toString());
    }
  }

  static Future<Map<String, String>> prepareRequestHeaders(Map<String, String> myRequestHeaders) async {
    if (isAuthenticationNeeded) {
      if (AppHelper.currentUserSession.token.isEmpty) {
        AppHelper.currentUserSession = await CacheManager.getUserSessionLocally(AppCacheKeys.userSessionFileName);
        await Future.delayed(const Duration(seconds: 1));
      }

      myRequestHeaders.addAll({AppDefaultKeys.tawasolAuthenticationToken: AppHelper.currentUserSession.token});
    }
    myRequestHeaders.addAll({
      AppDefaultKeys.userAgent: await getUserAgent(),
      AppDefaultKeys.contentType: AppDefaultKeys.jsonApplicationTypeHeader,
    });
    // AppDefaultKeys.userAgent:
    // 'Mobility - ${defaultTargetPlatform.toString()}',
    return myRequestHeaders;
  }

  // 'User-Agent: Mobility - Android - 13'
  static Future<String> getUserAgent() async {
    String os = Platform.operatingSystem;
    // Or, use a predicate getter.
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;
      var manufacturer = androidInfo.manufacturer;
      var model = androidInfo.model;

      return "User-Agent: Mobility - Android - $release (SDK $sdkInt), $manufacturer $model";
      // Android 9 (SDK 28), Xiaomi Redmi Note 7
    } else {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var systemName = iosInfo.systemName;
      var version = iosInfo.systemVersion;
      var name = iosInfo.name;
      var model = iosInfo.model;

      return "User-Agent: Mobility - $systemName - $version, $name $model";
    }
  }
}
