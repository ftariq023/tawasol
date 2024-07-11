import 'dart:convert';
import 'dart:typed_data';

class UserSignature {
  late String signContent;
  late String vsId;
  late bool isContractInitial;
  late String signTitle;
  late int signCount;

  Uint8List get userSignatureImage => base64Decode(signContent);

  UserSignature.fromEmpty(dynamic item,int count) {
    signContent = item['content'];
    vsId = item['metaData']['vsId'];
    signTitle = item['metaData']['documentTitle'];
    isContractInitial = item['metaData']['isContractInitial']??false;
    signCount=count;
  }
}
