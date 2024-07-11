import '../../app_utilities/app_helper.dart';
import '../../app_utilities/app_ui_helper.dart';

class InboxItem {
  InboxItem();

  InboxItem.fromEmpty(dynamic item) {
    try {
      docSubject = item['generalStepElm']['docSubject'].toString().trim().replaceAll("\n\n\n", " ").replaceAll("\n\n", " ").replaceAll("\n", " ") ?? '';
      docSerial = item['generalStepElm']['docFullSerial'] ?? '';
      arActionName = item['action']['arName'] ?? '';
      enActionName = item['action']['enName'] ?? '';
      arPriorityLevel = item['priorityLevel']['arName'] ?? '';
      enPriorityLevel = item['priorityLevel']['enName'] ?? '';
      arSenderName = item['senderInfo']['arName'] ?? '';
      senderId = item['senderInfo']['id'] ?? -1;
      enSenderName = item['senderInfo']['enName'] ?? '';
      arSenderOuName = item['fromOuInfo']['arName'] ?? '';
      senderOuId = item['fromOuInfo']['id'] ?? -1;
      senderSendEmail = item['fromOuInfo']['sendEmail'] ?? false;
      senderSendSMS = item['fromOuInfo']['sendSMS'] ?? false;
      enSenderOuName = item['fromOuInfo']['enName'] ?? '';
      vsID = item['generalStepElm']['vsId'] ?? '';
      wobNumber = item['generalStepElm']['workObjectNumber'] ?? '';
      actionId = item['generalStepElm']['action'];
      senderDomainName = item['generalStepElm']['sender'];
      regOuId = item['generalStepElm']['regOUID'];
      fromRegOuId = item['fromOuInfo']['regOUID'] ?? -1;
      receivedDate = AppUIHelper.timeStampToDate(item['generalStepElm']['receivedDate']);
      securityLevelId = item['generalStepElm']['securityLevel'];
      priorityLevel = item['generalStepElm']['priorityLevel'];
      linkedDocsNo = item['generalStepElm']['linkedDocsNO'];
      attachmentsNo = item['generalStepElm']['attachementsNO'];
      isOpen = item['generalStepElm']['isOpen'];
      docStatus = item['generalStepElm']['docStatus'];
      arSecurityLevel = item['securityLevel']['arName'];
      enSecurityLevel = item['securityLevel']['enName'];
      docClassId = item['generalStepElm']['docType'];

      isBroadcasted = item['generalStepElm']['isBrodcasted'];
      isSeqWFLaunch = item['generalStepElm']['isSeqWFLaunch'];
      isMultiSignature = docClassId == 1 ? false : item['generalStepElm']['isMultiSignature'] ?? false;
      isApprovedBefore = docClassId == 1 ? false : item['generalStepElm']['isApprovedBefore'] ?? false;
      signatureCount = docClassId == 1 ? 0 : item['generalStepElm']['signaturesCount'];
      addMethod = docClassId == 1 ? -1 : item['generalStepElm']['addMethod'];
      if (item['siteInfo'] != null) {
        arMainSite = item['siteInfo']['mainSite']['arName'];
        enMainSite = item['siteInfo']['mainSite']['enName'];
        arSubSite = item['siteInfo']['subSite']['arName'];
        enSubSite = item['siteInfo']['subSite']['enName'];
        arFollowupStatus = item['siteInfo']['followupStatusResult']['arName'];
        enFollowupStatus = item['siteInfo']['followupStatusResult']['enName'];
        followupDate = item['siteInfo']['followupDate'] != null ? AppUIHelper.timeStampToDate(item['generalStepElm']['documentCreationDate']) : null;
      }

      createdOn = AppUIHelper.timeStampToDate(item['generalStepElm']['documentCreationDate']);
      comment = item['generalStepElm']['comments'];
    } catch (e) {
      print(e);
    }
  }

  String arSenderName = '';
  String enSenderName = '';

  String get senderName => AppHelper.isCurrentArabic ? arSenderName : enSenderName;

  String arSenderOuName = '';
  String enSenderOuName = '';
  int senderOuId = -1;
  String senderDomainName = '';

  String get senderOuName => AppHelper.isCurrentArabic ? arSenderOuName : enSenderOuName;

  String get mainSite => AppHelper.isCurrentArabic ? arMainSite : enMainSite;

  String get subSite => AppHelper.isCurrentArabic ? arSubSite : enSubSite;

  String get followupStatus => AppHelper.isCurrentArabic ? arFollowupStatus : enFollowupStatus;

  String vsID = '';
  String wobNumber = '';
  int actionId = -1;
  int regOuId = -1;
  int fromRegOuId = -1;
  DateTime receivedDate = DateTime.now();
  int securityLevelId = -1;
  int priorityLevel = -1;
  int linkedDocsNo = 0;
  int attachmentsNo = 0;
  bool isOpen = false;
  bool senderSendEmail = false;
  bool senderSendSMS = false;
  int senderId = -1;
  bool? isBroadcasted;
  bool isMultiSignature = false;
  bool isApprovedBefore = false;
  bool isSeqWFLaunch = false;
  int signatureCount = 0;
  int addMethod = -1;
  int docStatus = 0;
  String arSecurityLevel = '';
  String enSecurityLevel = '';

  String folder = '';
  DateTime? followupDate;
  String arFollowupStatus = '';
  String enFollowupStatus = '';
  DateTime createdOn = DateTime.now();
  String comment = '';
  String arMainSite = '';
  String enMainSite = '';
  String arSubSite = '';
  String enSubSite = '';

  String get securityLevelName => AppHelper.isCurrentArabic ? arSecurityLevel : enSecurityLevel;
  String arPriorityLevel = '';
  String enPriorityLevel = '';

  String get priorityLevelName => AppHelper.isCurrentArabic ? arPriorityLevel : enPriorityLevel;
  String arActionName = '';
  String enActionName = '';

  String get actionName => AppHelper.isCurrentArabic ? arActionName : enActionName;
  String docSubject = '';
  String docSerial = '';
  int docClassId = -1;

  bool get isApproveEnabled => ((docClassId == 0 && AppHelper.currentUserSession.isElectronicSignatureEnabled) || (docClassId == 2 && AppHelper.currentUserSession.isElectronicSignatureMemoEnabled)) && !isSeqWFLaunch && addMethod != 1 && docStatus < 24 && isBroadcasted != null && isBroadcasted == false;
}
