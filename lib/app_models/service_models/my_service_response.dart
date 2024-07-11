import 'dart:typed_data';

import 'package:http/http.dart';

import '../app_utilities/app_helper.dart';

class MyServiceResponse {
  bool isSuccessResponse;
  String resultString;
  String? exceptionMessage;
  int? responseCode;
  int? itemCount;
  Uint8List? bytes;

  //public ExceptionType ExceptionType;
  //public object ResultObject;

  MyServiceResponse(this.resultString, this.responseCode, this.isSuccessResponse, this.bytes, this.exceptionMessage);

  bool? isSuccessfullyExecuted() => isSuccessResponse == true;
}
