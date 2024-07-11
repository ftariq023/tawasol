import 'package:http/http.dart';

import './service_urls.dart';
import '../app_utilities/app_helper.dart';

class MyServiceRequest {
  HttpMethod? method;
  bool? isStreamRequest;
  String serverBaseUrl = '';
  String serviceRelativeUrl = '';
  Map<String, String> headerParameters = {};
  Object? formParameters;
  int? timeOutSeconds;

  //CancellationToken CTS;

  bool? hideable;
  bool? cancelable;
  bool? authenticationRequired;
  bool? showLoading;
  String? loadingMessage;
  bool isDownloadContent=false;
  String? fileNameWithExtension;

  //public Object PutFormParameters;

  MyServiceRequest() {
    formParameters = null;
    //PutFormParameters = null;

    serviceRelativeUrl = "";
    serverBaseUrl = AppServiceURLS.baseUrl;
    timeOutSeconds = AppDefaults.defaultTimeOutInSeconds;

//    CTS = new CancellationTokenSource(AppConstants.Defaults.DefaultTimeOutInSeconds * 1000);

    hideable = true;
    cancelable = true;
    showLoading = true;
    authenticationRequired = true;
    isStreamRequest = false;

    loadingMessage = "";
    //Himanshu
    fileNameWithExtension = "";
  }
}
