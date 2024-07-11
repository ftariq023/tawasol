import 'package:flutter/material.dart';

import '../../../app_models/app_utilities/app_helper.dart';
import '../../app_utilities/app_ui_helper.dart';

class SentItem {
  SentItem();

  SentItem.fromEmpty(dynamic item) {
    try {
      vsID = item['documentVSID'];
      docSubject = item['docSubject'].toString().trim().replaceAll("\n\n\n", " ").replaceAll("\n\n", " ").replaceAll("\n", " ") ?? '';
      docSerial = item['docFullSerial'] ?? '';
      arActionName = item['workflowActionInfo']['arName'] ?? '';
      enActionName = item['workflowActionInfo']['enName'] ?? '';
      arReceiverName = item['userToInfo']['arName'] ?? '';
      enReceiverName = item['userToInfo']['enName'] ?? '';
      arReceiverOuName = item['userToOuInfo']['arName'] ?? '';
      enReceiverOuName = item['userToOuInfo']['enName'] ?? '';
      securityLevelId = item['securityLevel'];
      docClassId = item['docClassId'];
      actionDate = AppUIHelper.timeStampToDate(item['actionDate']);
      createdOn = AppUIHelper.timeStampToDate(item['documentCreationDate']);

      try{
      if (item['mainSiteInfo'] != null) {
        arMainSite = item['mainSiteInfo'][0]['arName'];
        enMainSite = item['mainSiteInfo'][0]['enName'];
      }
      if (item['subSiteInfo'] != null) {
        arSubSite = item['subSiteInfo'][0]['arName'];
        enSubSite = item['subSiteInfo'][0]['enName'];
      }
      }
      catch(e){
       // debugPrint('From Sent Item $e');
      }
    } catch (e) {
      debugPrint('From Sent Item $e');
    }
  }

  String vsID = '';
  String docSubject = '';

  String docSerial = '';
  DateTime actionDate = DateTime.now();
  int docClassId = -1;
  int securityLevelId = -1;

  String arReceiverName = '';
  String enReceiverName = '';

  String get receiverName =>
      AppHelper.isCurrentArabic ? arReceiverName : enReceiverName;

  String arReceiverOuName = '';
  String enReceiverOuName = '';

  String get receiverOuName =>
      AppHelper.isCurrentArabic ? arReceiverOuName : enReceiverOuName;

  String arActionName = '';
  String enActionName = '';
  DateTime createdOn = DateTime.now();
  String comment = '';
  String arMainSite = '';
  String enMainSite = '';
  String arSubSite = '';
  String enSubSite = '';

  String get mainSite => AppHelper.isCurrentArabic ? arMainSite : enMainSite;

  String get subSite => AppHelper.isCurrentArabic ? arSubSite : enSubSite;

  String get actionName =>
      AppHelper.isCurrentArabic ? arActionName : enActionName;
}
