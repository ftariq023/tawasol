import 'dart:convert';
import 'dart:typed_data';

import 'package:tawasol/app_models/app_utilities/app_helper.dart';

import '../app_utilities/app_ui_helper.dart';

class ViewDocumentModel {
  String docContent = '';
  late String vsId = '';
  List<Attachment> attachments = [];
  List<LinkedDocument> linkedDocuments = [];

  ViewDocumentModel();

  Uint8List get docPdfFile => base64Decode(docContent);

  ViewDocumentModel.fromEmpty(dynamic item, String docVsId) {
    docContent = item['content'];
    vsId = docVsId;
    for (var attach in item['linkedAttachments']) {
      attachments.add(Attachment.fromEmpty(attach));
    }
    for (var linkDoc in item['linkedDocs']) {
      linkedDocuments.add(LinkedDocument.fromEmpty(linkDoc));
    }

    // attachments.add(item['linkedAttachments']
    //     .map((item) => LinkedDocument.fromEmpty(item)));
    //
    // linkedDocuments = item['linkedDocs']
    //     .map((item) => LinkedDocument.fromEmpty(item))
    //     .toList();
  }
}

class Attachment {
  late String vsId;
  late String id;
  late String subject;

  Attachment();

  Attachment.fromEmpty(dynamic item) {
    id = item['id'];
    vsId = item['vsId'];
    subject = item['docSubject'];
  }
}

class LinkedDocument {
  String vsID = '';
  String id = '';
  String docSubject = '';
  String docClassName = '';
  DateTime? createdOn;
  DateTime? lastModified;
  DateTime? docDate;
  // String? docSerial = '';

  String arCreatedOuName = '';
  String enCreatedOuName = '';

  String get creatorOuName => AppHelper.isCurrentArabic ? arCreatedOuName : enCreatedOuName;

  String arLastModifierName = '';
  String enLastModifierName = '';

  String get lastModifierName => AppHelper.isCurrentArabic ? arLastModifierName : enLastModifierName;

  String arCreatorName = '';
  String enCreatorName = '';

  String get creatorName => AppHelper.isCurrentArabic ? arCreatorName : enCreatorName;

  String arSecurityLevel = '';
  String enSecurityLevel = '';

  String get securityLevelName => AppHelper.isCurrentArabic ? arSecurityLevel : enSecurityLevel;

  String arPriorityLevel = '';
  String enPriorityLevel = '';

  String get priorityLevelName => AppHelper.isCurrentArabic ? arPriorityLevel : enPriorityLevel;

  // List<Attachment> attachmentList = [];

  int get documentClassId => AppHelper.getDocumentClassIdByName(docClassName.toLowerCase());

  LinkedDocument();

  LinkedDocument.fromEmpty(dynamic item) {
    id = item['id'];
    vsID = item['vsId'];
    docSubject = item['docSubject'];
    docClassName = item['classDescription'];
    //docSerial = item['docSerial'];
    createdOn = AppUIHelper.timeStampToDate(item['createdOn']);
    lastModified = AppUIHelper.timeStampToDate(item['lastModified']);
    docDate = AppUIHelper.timeStampToDate(item['docDate']);

    arCreatedOuName = item['creatorOuInfo']['arName'];
    enCreatedOuName = item['creatorOuInfo']['enName'];

    arCreatorName = item['creatorInfo']['arName'];
    enCreatorName = item['creatorInfo']['enName'];

    arSecurityLevel = item['securityLevelInfo']['arName'];
    enSecurityLevel = item['securityLevelInfo']['enName'];

    arPriorityLevel = item['priorityLevelInfo']['arName'];
    enPriorityLevel = item['priorityLevelInfo']['enName'];

    arLastModifierName = item['lastModifierInfo']['arName'];
    enLastModifierName = item['lastModifierInfo']['enName'];

    // for (var attachment in item['attachments']) {
    //   attachmentList.add(Attachment.fromEmpty(attachment));
    // }
  }
}
