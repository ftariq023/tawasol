class AppServiceURLS {
  // static const baseUrl = 'https://tawasol.qfa.qa';
  // static const baseUrl = 'https://cms.eblacorp.com';
  // static const baseUrl = 'http://pmocms.pmo.gov.qa:80';
  // static const baseUrl = 'https://tawasol.qfc.qa:9443';
  // static const baseUrl = 'http://192.168.56.4:9080';

  // static const baseUrl = 'http://192.168.56.4:5003';
  static const baseUrl = 'https://tawasolprd.moi.gov.qa';
  // static const baseUrl = 'https://pmocms.pmo.gov.qa';

  // bundle ids:
  // com.eblacorp.distribution.tawasolmanagertest
  // com.eblacorp.distribution.mailingroom
  // com.eblacorp.distribution.mailingroompmo
  // com.eblacorp.distribution.mailingroompmoprod

  // com.eblacorp.personaltest

  static const getPreLoginInformation = "/CMSServices/service/auth/login/mobility-info";
  static const mobilityLogin = "/CMSServices/service/auth/mobility-login?withEncryption=false";

  static const changeOrganizationUnit = "/CMSServices/service/auth/login/mobility/select-ou";
  static const getUserInbox = "/CMSServices/service/cms-entity/user/inbox/all-mails?limit={PageSize}&offset={Offset}&optional-fields=mainClassification,subClassification";
  static const getSentItems = "/CMSServices/service/cms-entity/user/inbox/user-sent-items?limit={PageSize}&offset={Offset}";
  static const getAllOUs = '/CMSServices/service/cms-entity/admin/ou/dist/ous?as-dist-wf=true';
  static const getAllUsersByOUs = '/CMSServices/service/cms-entity/admin/ou-application-user/dist/search';

  static const markDocumentAsOpened = "/CMSServices/service/cms-entity/user/inbox/read";
  static const getDocumentContent = "/CMSServices/service/cms-entity/correspondence/common/mobility/vsid/{VSID}";
  static const getDocumentLinks = "/CMSServices/service/cms-entity/correspondence/common/{VSID}/all-linked-items";
  static const getDocumentContentWithLinks = "/CMSServices/service/cms-entity/correspondence/common/mobility/with-all-linked-items/vsid/{VSID}?docClassId={ClassId}&wobNum={WobNumber}&with-watermark=true";
  static const search = "/CMSServices/service/cms-entity/correspondence/search/{DocType}";
  static const markDocumentAsUnOpened = "/CMSServices/service/cms-entity/user/inbox/un-read";
  static const getAttachmentContent = "/CMSServices/service/cms-entity/correspondence/common/mobility/attachment/vsid/{VSID}?with-watermark={Watermark}";

  static const getOrganizationUnitsForFollowup = "/CMSServices/service/cms-entity/admin/ou-application-user/dist/mobility/followup-emp";
  static const getOrganizationUnitsForSend = "/CMSServices/service/cms-entity/admin/ou-application-user/dist/composite";

  static const getOrganizationUnitsForDelegation = "/CMSServices/service/cms-entity/admin/ou-application-user/dist/mobility/delegation-list";

  static const getUserSignatures = "/CMSServices/service/cms-entity/user/signature/mobility/user-id/{UserID}";
  static const uploadUserSignature = "/CMSServices/service/cms-entity/user/signature";

  static const transfer = "/CMSServices/service/cms-entity/user/inbox/{WobNumber}/reassign";
  static const terminate = "/CMSServices/service/cms-entity/correspondence/wf/{DocType}/terminate/wob-num";
  static const approve = "/CMSServices/service/cms-entity/correspondence/{DocType}/authorize";
  static const getDocumentHistory = "/CMSServices/service/cms-entity/user/event-log/vsid/{VSID}";
  static const getDocumentFullHistory = "/CMSServices/service/cms-entity/user/full-history/vsid/{VSID}/desc";

  static const getWorkflowActions = "/CMSServices/service/cms-entity/admin/wf-action/wf"; //user
  static const getUserComments = "/CMSServices/service/cms-entity/user/user-comment"; //department, user

  static const send = "/CMSServices/service/cms-entity/correspondence/wf/{DocType}/{VSID}/forward/{WobNumber}";

  static const sendFromSearch = "/CMSServices/service/cms-entity/correspondence/wf/{DocType}/vsid/{VSID}";

  static const getUsersForProxy = "/CMSServices/service/cms-entity/admin/ou-application-user/search";

  static const getOUsForSearchByUserId = "/CMSServices/service/cms-entity/admin/user-view-ou-permission/lookup/user-id/";
  static const delegate = "/CMSServices/service/cms-entity/admin/ou-application-user/proxy";
  static const terminateDelegate = "/CMSServices/service/cms-entity/admin/ou-application-user/proxy/{OuUserId}";
  static const availableActions = "/CMSServices/service/cms-entity/correspondence/common/mobility/available-action/vsid/{VSID}/wob-num/{wobNum}?from-group-queue=";

  static const getParentOUInfo = "/CMSServices/service/cms-entity/admin/ou/";

  static const getDocumentInfo = "/CMSServices/service/cms-entity/correspondence/{ClassId}/{VSID}";

  static const getSiteTypes = "/CMSServices/service/cms-entity/correspondence/common/load-lookup?asSearch=true";
  static const getMainSiteByType = "/CMSServices/service/cms-entity/correspondence/correspondence-site-view/search/main";
  static const getSubSiteByMainSiteId = "/CMSServices/service/cms-entity/correspondence/correspondence-site-view/search/sub";

  static const getFollowupOus = "/CMSServices/service/cms-entity/admin/ou/dist/follow-up-ou";
  static const getFollowupOuUsers = "/CMSServices/service/cms-entity/admin/ou-application-user/dist/follow-up/search";
  static const String getEmployeeFollowupItems = "/CMSServices/service/cms-entity/user/inbox/followup-emp-inbox/user/{User}/ou/{OUID}?securityLevels=";
  static const String getOuForTransfer = "/CMSServices/service/cms-entity/admin/ou/dist/ous?as-dist-wf=true";

  static const String getAllActiveOUs = "/CMSServices/service/cms-entity/admin/ou/active/lookup";

  static const String getSearchOus = '/CMSServices/service/cms-entity/admin/ou/dist/search/ous';
}

class AppDefaultKeys {
  static const String resultKey = "rs";
  static const String tawasolEntityID = "tawasol-entity-Id";
  static const String tawasolEntityID1 = "tawasolEntityId";

  // static const String tawasolEntityCode = "qtr";
  static const String tawasolEntityCode = "moi";
  // static const String tawasolEntityCode = "qfa";
  // static const String tawasolEntityCode = "pmo";
  // static const String tawasolEntityCode = "qfc";

  static const String tawasoltempToken =
      "eyJhbGciOiJIUzUxMiJ9.eyJwIjpbMTYsMzIsMzMsMzYsMTU2LDIyNCwzNSwyMDYsMTU3LDM3LDM0LDM4LDMxLDIyNywxNzAsNDUsNTMsMzksMTYzLDE1NSwxMTUsNDEsMTE0LDIxMCw0MiwxNzQsMjIzLDQ2LDIwOSw0Nyw0Myw0MCwxNTQsNDgsNDQsMjI5LDIwNSwxNzEsNTAsMTIzLDIyNSwxMTcsMTE4LDExOSw1MSw1NCwyMTEsMTU5LDE1OCwxMjAsNTIsMjA3LDE4MCw0OSwyMjgsMTE2LDIyMiwxMzQsMTc3LDE2NSwyMDAsNjAsNjQsMTEyLDE4MiwxOTEsMTc5LDYxLDIwMiw2Miw1OCwxODMsMTMyLDEzMywxMzUsMTkzLDEzNiwxNjgsMTI0LDU3LDE2OSw2MywxODQsNTUsMjMwLDE3Niw2NSw3MCw2OSw2OCw2Niw3MSw3NSw3NCwxOTgsNzYsMTY2LDc3LDcyLDczLDE3OCwxMTMsOTksMTAxLDIwMSwxNzUsMTA1LDEyMiwxODEsMTUwLDE0OSwxNDgsMTUyLDEwNiw5NywxOTUsMjAzLDEwNCwxMDcsMTk2LDE2NCwxNzIsMTkwLDIwNCwxOSwxMjgsMTUxLDEyNiwxMzEsMTI3LDk0LDk4LDEyOSw5MSw5NSw5MiwxMzAsODksNSwxMDksMTAsMTEwLDI0LDIsMTQsMzAsMTExLDIyLDcsMjYsNCwzLDIzLDYsMjEsMTcsMTUsMSwyMCw5LDI1LDI3LDE2NywxMSwxMDgsMTkyLDE2MSw3OSwyMDgsMjI2LDc4LDE2MiwxNjAsODBdLCJzdWIiOiJucjciLCJwcyI6Imc2aW9KUEZTZ1RUTTdqOTNyRjFzVUE9PTpZQ3kxZXd5cU43dGg3Y3lXeXJpL0FnPT0iLCJ0aSI6Im1vdGMiLCJpYSI6ZmFsc2UsInVvIjpbMTEsNjcsMTE0LDExNSwxMTYsMTE3LDExOF0sImRvIjp0cnVlLCJvaWQiOjE0LCJzbyI6Wy0xXSwiZ2QiOiJlODc2ZjYzMS03NjA5LTQ0MjktYjIxMC0wOGE2Mjk5YjFiMzYiLCJzc28iOmZhbHNlLCJjciI6MTY4ODM4ODAzNTgyMiwiZXhwIjoyMzE5NTQwMDM1fQ.NGJmzkrpta0Dun5icFD3uZNdhdv_obDB7bqfNmhAlF7l92unJNZLsI5KSq4G3R2SpKooCQI0mhVUGopT1Bps9A";

  static const String tawasolAuthenticationToken = "tawasol-auth-header";
  static const String jsonApplicationTypeHeader = "application/json; charset=UTF-8";
  static const String pdfApplicationTypeHeader = "application/pdf";
  static const String contentType = 'Content-Type';
  static const String userAgent = 'User-Agent';

  static const String userName = "username";
  static const String userId = "userId";
  static const String shortComment = "shortComment";
  static const String comment = "comment";
  static const String status = "status";
  static const String itemOrder = "itemOrder";

  static const String password = "password";
  static const String wobNumber = "wob-num";
  static const String entity = "entity";
  static const String ouID = "ouId";
  static const String ou = "OU";
  static const String registryOU = "RegistryOU";
  static const String vSID = "VSID";
  static const String docType = "DocType";
  static const String loginUsingDefaultOu = "loginUsingDefaultOu";
  static const String withEncryption = "withEncryption";
  static const String oTPReference = "otpReference";
  static const String oTP = "otp";
  static const String allowMultiSession = "allowConcurrentSessionInvalidation";
  static const String searchSubjectKeyword = "DocSubjectSrc";
  static const String searchSerialKeyword = "DocFullSerial";
  static const String searchSecurityLevelKeyword = "SecurityLevel";
  static const String searchDateKeyword = "DocDate";
  static const String searchRegistryOUKeyword = "RegistryOU";
  static const String sameUserAuthorize = "SAME_USER_AUTHORIZED";
  static const String additionalData = "additionalData";
  static const String type = "type";
  static const String vsId = "vsid";
  static const String approvers = "Approvers";
  static const String incomingHistoryDate = "RefDocDate";
  static const String approverDateFrom = "first";
  static const String approverDateTo = "second";

  static const String searchTypeIncoming = "incoming";
  static const String searchTypeOutgoing = "outgoing";
  static const String searchTypeInternal = "internal";
  static const String searchTypeGeneral = "general";
  static const String searchTypeCorrespondence = "correspondence";
}

class AppDefaults {
  static const int defaultTimeOutInSeconds = 20;

  // static const String dateFormat = 'dd/MM/yyyy hh:mm a';
  // static const String dateFormat = 'dd/MM/yyyy HH:MM';
  static const String dateFormat = 'dd/MM/yyyy hh:mm a';

  static const String testComment =
      "السكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعيالسكرتارية تطوير الأنظمة، قسم الخدمات الإلكترونية والإنترنت، قسم الأنظمة الأمنية و الجغرافية، قسم النظم المدنية، مكتب إدارة مشاريع وتأكيد الجودة، سكرتير المدير، قسم الذكاء الإصطناعي";
}

class AppCacheKeys {
  static const String entityFileName = 'entityDetails';
  static const String userSessionFileName = 'userSessionDetails';
  static const String globalCacheFileName = 'globalCache';
  static const String globalSelectedLanguage = 'globalSelectedLanguage';
}

class AppPermKeys {
  static const String electronicSignature = 'ELECTRONIC_SIGNATURE';
  static const String electronicSignatureMemo = 'ELECTRONIC_SIGNATURE_MEMO';
  static const String userInbox = 'USER_INBOX';
  static const String sentItems = 'SENT_ITEMS';
  static const String generalSearch = 'GENERAL_SEARCH';
  static const String incomingSearch = 'SEARCH_INCOMING';
  static const String outgoingSearch = 'SEARCH_OUTGOING';
  static const String internalSearch = 'SEARCH_INTERNAL_DOCUMENT';
  static const String employeeFollowup = 'FOLLOW-UP_EMPLOYEES’_INBOXES';
  static const String printDocument = 'PRINT_DOCUMENT';
}
