import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/app_models/app_utilities/cache_manager.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/app_user.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/followup_ou.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/followup_user.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/inbox_Item.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/organization_unit.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/sent_Item.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/user_comment.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/wf_action.dart';
import 'package:tawasol/app_models/app_view_models/document_log.dart';
import 'package:tawasol/app_models/app_view_models/proxy_user.dart';
import 'package:tawasol/app_models/app_view_models/tawasol_entity.dart';
import 'package:tawasol/app_models/app_view_models/user_signature.dart';

import '../app_view_models/db_entities/search_result_item.dart';
import '../app_view_models/site_bind.dart';
import '../app_view_models/view_document_model.dart';
import './my_service_request.dart';
import './my_service_response.dart';
import './service_handler_base.dart';
import 'service_urls.dart';

class ServiceHandler {
  static Future<TawasolEntity> getPreLoginInfo(String entityCode, String serviceUrl) async {
    MyServiceResponse serviceResponse;
    try {
      MyServiceRequest myRequest = MyServiceRequest();
      myRequest.serviceRelativeUrl = AppServiceURLS.getPreLoginInformation;
      myRequest.headerParameters = {AppDefaultKeys.tawasolEntityID: entityCode};
      myRequest.serverBaseUrl = serviceUrl;
      serviceResponse = await ServiceHandlerBase.getData(myServiceRequest: myRequest, authenticationRequired: false);
      if (serviceResponse.isSuccessResponse) {
        File entityFile = await CacheManager.getFileByPath(AppCacheKeys.entityFileName);
        if (entityFile.existsSync()) {
          entityFile.deleteSync(recursive: true);
        }
        return CacheManager.saveEntityDetailsLocally(serviceResponse.resultString, serviceUrl);
        // return serviceResponse;
      }
    } catch (e) {
      // return MyServiceResponse(
      //     e.toString(), HttpStatusCode.badRequest, false, null, e.toString());
    }
    return TawasolEntity();
  }

  static Future<List<InboxItem>> getUserInbox() async {
    List<InboxItem> inboxItems = [];
    try {
      MyServiceRequest myRequest = MyServiceRequest();
      myRequest.serviceRelativeUrl = AppServiceURLS.getUserInbox.replaceAll('{PageSize}', '200').replaceAll('{Offset}', '0');
      MyServiceResponse serviceResponse = await ServiceHandlerBase.getData(myServiceRequest: myRequest);

      if (serviceResponse.isSuccessResponse) {
        var jsonBody = json.decode(serviceResponse.resultString);
        for (var item in jsonBody['rs']) {
          inboxItems.add(InboxItem.fromEmpty(item));
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return inboxItems;
  }

  static Future<MyServiceResponse> getUserByCredentials({required String userName, required String password, int? ouID, String userOTP = '', String otpReference = "", bool isChangeDepartment = false, bool isMultiSessionApproved = false}) async {
    MyServiceRequest myRequest = MyServiceRequest();

    if (AppHelper.currentTawasolEntity.tawasolVersionNumber.isEmpty) {
      await getPreLoginInfo(AppDefaultKeys.tawasolEntityCode, AppServiceURLS.baseUrl);
    }

    myRequest.formParameters = {
      AppDefaultKeys.userName: userName,
      AppDefaultKeys.password: password,
      AppDefaultKeys.tawasolEntityID1: AppHelper.currentTawasolEntity.entityCode,
      AppDefaultKeys.ouID: ouID,
      AppDefaultKeys.loginUsingDefaultOu: ouID == null ? true : false,
    };

    myRequest.authenticationRequired = isChangeDepartment;
    myRequest.serviceRelativeUrl = ouID == null ? AppServiceURLS.mobilityLogin : AppServiceURLS.changeOrganizationUnit;
    MyServiceResponse myServiceResponse = await ServiceHandlerBase.postData(
      myServiceRequest: myRequest,
      authenticationRequired: ouID == null ? false : true,
    );

    if (myServiceResponse.isSuccessResponse) {
      bool isBioMetricEnabled = AppHelper.currentUserSession.isBiometricEnabled;

      await CacheManager.saveUserSessionLocally(jsonUserSession: myServiceResponse.resultString, password: password, isBioMetricEnabled: isBioMetricEnabled);

      return myServiceResponse;
    }

    return myServiceResponse;
  }

  static Future<List<UserComment>> getUserComments() async {
    List<UserComment> userComments = [];
    try {
      MyServiceRequest myRequest = MyServiceRequest();
      myRequest.serviceRelativeUrl = AppServiceURLS.getUserComments;

      MyServiceResponse serviceResponse = await ServiceHandlerBase.getData(myServiceRequest: myRequest);

      var jsonBody = json.decode(serviceResponse.resultString);

      for (var item in jsonBody['rs']) {
        userComments.add(UserComment(item['id'], item['shortComment'], item['comment']));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return userComments;
  }

  static Future<List<WfAction>> getWfActions() async {
    List<WfAction> wfActions = [];
    MyServiceRequest myRequest = MyServiceRequest();
    try {
      myRequest.serviceRelativeUrl = AppServiceURLS.getWorkflowActions;

      MyServiceResponse serviceResponse = await ServiceHandlerBase.getData(myServiceRequest: myRequest);
      var jsonBody = json.decode(serviceResponse.resultString);
      for (var item in jsonBody['rs']) {
        wfActions.add(WfAction(item['id'], item['enName'], item['arName']));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return wfActions;
  }

  static Future<List<SentItem>> getSentItems() async {
    List<SentItem> sentItems = [];
    MyServiceRequest myRequest = MyServiceRequest();
    try {
      myRequest.serviceRelativeUrl = AppServiceURLS.getSentItems.replaceAll('{PageSize}', '200').replaceAll('{Offset}', '0');

      MyServiceResponse serviceResponse = await ServiceHandlerBase.getData(myServiceRequest: myRequest);
      var jsonBody = json.decode(serviceResponse.resultString);
      for (var item in jsonBody['rs']) {
        sentItems.add(SentItem.fromEmpty(item));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return sentItems;
  }

//get all ous for send screen
  static Future<List<OrganizationUnit>> getAllOUs() async {
    List<OrganizationUnit> ouList = [];
    MyServiceRequest myRequest = MyServiceRequest();
    try {
      myRequest.serviceRelativeUrl = AppServiceURLS.getAllOUs;

      MyServiceResponse serviceResponse = await ServiceHandlerBase.getData(myServiceRequest: myRequest);

      var jsonBody = json.decode(serviceResponse.resultString);

      for (var item in jsonBody['rs']) {
        ouList.add(OrganizationUnit.forEmpty(item));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return ouList;
  }

  //get all ous for send screen
  static Future<List<OrganizationUnit>> getOusForSearch() async {
    List<OrganizationUnit> ouList = [];
    MyServiceRequest myRequest = MyServiceRequest();
    try {
      myRequest.serviceRelativeUrl = AppServiceURLS.getSearchOus;

      MyServiceResponse serviceResponse = await ServiceHandlerBase.getData(myServiceRequest: myRequest);

      var jsonBody = json.decode(serviceResponse.resultString);

      for (var item in jsonBody['rs']) {
        OrganizationUnit ou = OrganizationUnit.forEmpty(item);
        if (ou.hasRegistry == true) {
          ouList.add(ou);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return ouList;
  }

  static Future<List<AppUser>> getAllUsersByOUs(int ouID, bool isRegOu) async {
    // print("ouID");
    // print(ouID);
    // print(isRegOu);
    List<AppUser> appUserList = [];
    MyServiceRequest myRequest = MyServiceRequest();
    try {
      myRequest.serviceRelativeUrl = AppServiceURLS.getAllUsersByOUs;

      myRequest.formParameters = {
        isRegOu ? "regOu" : "ou": ouID,
      };

      MyServiceResponse serviceResponse = await ServiceHandlerBase.postData(myServiceRequest: myRequest);

      var jsonBody = json.decode(serviceResponse.resultString);

      for (var item in jsonBody['rs']) {
        appUserList.add(AppUser(
          item['id'],
          item['domainName'],
          item['enName'],
          item['arName'],
          item['relationId'],
          item['securityLevel'],
          0,
          0,
          DateTime.now(),
          DateTime.now(),
          0,
          false,
          item['sendSMS'],
          item['sendEmail'],
          item['ouId'],
          item['regouId'],
          item['ouArName'],
          item['ouEnName'],
          isRegOu,
        ));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return appUserList;
  }

  static Future<ViewDocumentModel> getDocumentContentWithLinks({
    required String vsId,
    required String docClass,
    String wobNumber = '',
  }) async {
    MyServiceRequest myRequest = MyServiceRequest();

    myRequest.serviceRelativeUrl = AppServiceURLS.getDocumentContentWithLinks.replaceAll('{VSID}', vsId).replaceAll('{WobNumber}', wobNumber).replaceAll(
          '{ClassId}',
          docClass,
        );

    MyServiceResponse serviceResponse = await ServiceHandlerBase.getData(myServiceRequest: myRequest);

    // print(serviceResponse.resultString);
    // if (!AppHelper.isCurrentArabic) {
    //   await Clipboard.setData(
    //       ClipboardData(text: serviceResponse.resultString));
    // }
    // return serviceResponse.isSuccessResponse;

    if (serviceResponse.isSuccessResponse) {
      AppHelper.attachmentErrorMsg = "";
      var jsonBody = json.decode(serviceResponse.resultString);
      return ViewDocumentModel.fromEmpty(jsonBody['rs'], vsId);
    } else {
      // print("exceptionMsg");
      // print(serviceResponse.exceptionMessage);
      // print(serviceResponse.resultString);
      AppHelper.attachmentErrorMsg = serviceResponse.resultString;
      return ViewDocumentModel();
    }
  }

  static Future<void> markItemAsRead(String wobNum) async {
    MyServiceRequest myRequest = MyServiceRequest();
    myRequest.serviceRelativeUrl = AppServiceURLS.markDocumentAsOpened;
    myRequest.formParameters = [wobNum];
    MyServiceResponse serviceResponse = await ServiceHandlerBase.putData(myServiceRequest: myRequest);
  }

  static Future<Uint8List?> fetchAttachmentContent({
    required String vsId,
  }) async {
    MyServiceRequest myRequest = MyServiceRequest();
    myRequest.isDownloadContent = true;
    myRequest.serviceRelativeUrl = AppServiceURLS.getAttachmentContent.replaceAll('{VSID}', vsId).replaceAll('{Watermark}', 'true');

    MyServiceResponse serviceResponse = await ServiceHandlerBase.getData(myServiceRequest: myRequest);
    if (serviceResponse.isSuccessResponse) {
      return serviceResponse.bytes;
    }
    return null;
  }

  static Future<bool> send(String vsId, String docType, String wobNumber, Object users, {bool isSentItem = false}) async {
    MyServiceRequest myRequest = MyServiceRequest();
    try {
      String serviceUrl = (wobNumber.isEmpty || isSentItem) ? AppServiceURLS.sendFromSearch : AppServiceURLS.send;
      myRequest.serviceRelativeUrl = serviceUrl.replaceAll('{DocType}', docType).replaceAll('{VSID}', vsId).replaceAll(
            '{WobNumber}',
            wobNumber,
          );

      myRequest.method = HttpMethod.httpPOST;
      myRequest.formParameters = users;
      MyServiceResponse response = await ServiceHandlerBase.postData(myServiceRequest: myRequest);
      // if (!AppHelper.isCurrentArabic) {
      //   await Clipboard.setData(ClipboardData(text: response.resultString));
      // }
      print("resultString");
      print(response.resultString);
      print(response.exceptionMessage);
      return response.isSuccessResponse;
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  static Future<bool> terminateDocument(int docType, String wobNumber, String userComment) async {
    MyServiceRequest myRequest = MyServiceRequest();
    try {
      myRequest.serviceRelativeUrl = AppServiceURLS.terminate.replaceAll('{DocType}', AppHelper.getDocumentType(docType: docType, needLocal: false));

      myRequest.formParameters = {"first": wobNumber, "second": userComment};

      myRequest.method = HttpMethod.httpPUT;
      MyServiceResponse response = await ServiceHandlerBase.putData(myServiceRequest: myRequest);
      return response.isSuccessResponse;
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  static Future<MyServiceResponse?> approveDocument({required String vsId, required String signVsId, required int docType, required String wobNumber, bool validateMultiSignature = true}) async {
    MyServiceRequest myRequest = MyServiceRequest();
    MyServiceResponse? response;
    try {
      myRequest.serviceRelativeUrl = AppServiceURLS.approve.replaceAll(
        '{DocType}',
        AppHelper.getDocumentType(docType: docType, needLocal: false),
      );

      Map<String, Object?> formParams = {
        "bookVsid": vsId,
        "signatureVsid": signVsId,
        "pinCode": "",
        "wobNum": wobNumber,
      };

      if (!validateMultiSignature) {
        formParams["validateMultiSignature"] = validateMultiSignature;
      }

      myRequest.formParameters = formParams;
      if (!validateMultiSignature) {}
      myRequest.method = HttpMethod.httpPUT;
      MyServiceResponse response = await ServiceHandlerBase.putData(myServiceRequest: myRequest);
      // if (!AppHelper.isCurrentArabic) {
      //   await Clipboard.setData(ClipboardData(text: response.resultString));
      // }

      return response;
    } catch (e) {
      debugPrint(e.toString());
    }
    return response;
  }

  static Future<List<UserSignature>> getSignatureList(BuildContext context) async {
    MyServiceRequest myRequest = MyServiceRequest();
    List<UserSignature> signList = [];
    try {
      myRequest.serviceRelativeUrl = AppServiceURLS.getUserSignatures.replaceAll('{UserID}', AppHelper.currentUserSession.id.toString());
      myRequest.method = HttpMethod.httpGet;
      MyServiceResponse serviceResponse = await ServiceHandlerBase.getData(myServiceRequest: myRequest);
      if (serviceResponse.isSuccessResponse) {
        var jsonBody = json.decode(serviceResponse.resultString);

        // await AppHelper.showCustomAlertDialog(
        //     context,
        //     "Approve Service Response",
        //     serviceResponse.resultString,
        //     "Close",
        //     null);

        for (var item in jsonBody['rs']) {
          signList.add(UserSignature.fromEmpty(item, jsonBody['count']));
        }
        return signList;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return signList;
  }

  static Future<List<DocumentLog>> getDocumentHistory({required String docVsId, bool isFullHistory = false}) async {
    MyServiceRequest myRequest = MyServiceRequest();
    List<DocumentLog> docLogs = [];
    try {
      String serviceUrl = isFullHistory ? AppServiceURLS.getDocumentFullHistory : AppServiceURLS.getDocumentHistory;

      myRequest.serviceRelativeUrl = serviceUrl.replaceAll('{VSID}', docVsId);

      myRequest.method = HttpMethod.httpGet;
      MyServiceResponse response = await ServiceHandlerBase.getData(myServiceRequest: myRequest);
      if (response.isSuccessResponse) {
        var jsonBody = json.decode(response.resultString);
        for (var item in jsonBody['rs']) {
          docLogs.add(DocumentLog.fromEmpty(item, docVsId, isFullHistory));
        }
        return docLogs;
      }
      // return response.isSuccessResponse;
    } catch (e) {
      debugPrint(e.toString());
    }
    return docLogs;
    // return false;
  }

  static Future<List<SiteBind>> getSiteTypes() async {
    MyServiceRequest myRequest = MyServiceRequest();
    List<SiteBind> siteTypeList = [];
    try {
      myRequest.serviceRelativeUrl = AppServiceURLS.getSiteTypes;

      myRequest.method = HttpMethod.httpGet;
      MyServiceResponse response = await ServiceHandlerBase.getData(myServiceRequest: myRequest);
      if (response.isSuccessResponse) {
        var jsonBody = json.decode(response.resultString);
        for (var item in jsonBody['rs']["0"]["siteTypes"]) {
          siteTypeList.add(SiteBind(item["lookupKey"], item["enName"], item["arName"], null, null));
        }
        return siteTypeList;
      }
      // return response.isSuccessResponse;
    } catch (e) {
      debugPrint(e.toString());
    }
    return siteTypeList;
    // return false;
  }

  static Future<List<SiteBind>> getSiteList(int siteTypeId, int? mainSiteId) async {
    MyServiceRequest myRequest = MyServiceRequest();
    List<SiteBind> mainSites = [];
    try {
      var serviceUrl = mainSiteId == null ? AppServiceURLS.getMainSiteByType : AppServiceURLS.getSubSiteByMainSiteId;

      Map<String, Object?> formParams = {
        "criteria": null,
        "excludeOuSites": false,
        "includeDisabled": true,
        "type": siteTypeId,
      };
      if (mainSiteId != null) {
        formParams["parent"] = mainSiteId;
      }
      myRequest.formParameters = formParams;

      myRequest.serviceRelativeUrl = serviceUrl;
      myRequest.method = HttpMethod.httpPOST;
      MyServiceResponse response = await ServiceHandlerBase.postData(myServiceRequest: myRequest);
      if (response.isSuccessResponse) {
        var jsonBody = json.decode(response.resultString);
        for (var item in jsonBody['rs']) {
          mainSites.add(SiteBind(item["id"], item["enDisplayName"], item["arDisplayName"], mainSiteId, siteTypeId));
        }
        return mainSites;
      }
      // return response.isSuccessResponse;
    } catch (e) {
      debugPrint(e.toString());
    }
    return mainSites;
// return false;
  }

  static Future<List<SiteBind>> getSubSiteByMainSiteId(int siteTypeId, int mainSiteId) async {
    MyServiceRequest myRequest = MyServiceRequest();
    List<SiteBind> mainSites = [];
    try {
      myRequest.formParameters = {"criteria": null, "excludeOuSites": false, "includeDisabled": true, "type": siteTypeId};
      myRequest.serviceRelativeUrl = AppServiceURLS.getSubSiteByMainSiteId;
      myRequest.method = HttpMethod.httpPUT;
      MyServiceResponse response = await ServiceHandlerBase.getData(myServiceRequest: myRequest);
      if (response.isSuccessResponse) {
        var jsonBody = json.decode(response.resultString);
        for (var item in jsonBody['rs']) {
          mainSites.add(SiteBind(item["id"], item["enDisplayName"], item["arDisplayName"], null, siteTypeId));
        }
        return mainSites;
      }
// return response.isSuccessResponse;
    } catch (e) {
      debugPrint(e.toString());
    }
    return mainSites;
// return false;
  }

  static Future<List<SearchResultItem>> getSearchResultItems(String dateFrom, String dateTo, String deptId, String? subject, String? docFullSerial, String searchType, int? securityLevelId, int? siteTypeId, int? mainSiteId, int? subSiteId, int? approverStartDate, int? approverEndDate, String? docHistoryDateFrom, String? docHistoryDateTo) async {
    MyServiceRequest myRequest = MyServiceRequest();
    List<SearchResultItem> searchResultItems = [];
    try {
      if (searchType == AppDefaultKeys.searchTypeGeneral) {
        if (siteTypeId != null || mainSiteId != null || subSiteId != null) {
          searchType = AppDefaultKeys.searchTypeCorrespondence;
        }
      }

      // print(searchType);

      myRequest.serviceRelativeUrl = AppServiceURLS.search.replaceAll('{DocType}', searchType);
      Map<String, Object?> formParams = {
        "DocDate": "{\"From\":\"$dateFrom\",\"To\":\"$dateTo\"}",
        "SitesInfoTo": "{\"siteType\":$siteTypeId,\$${mainSiteId != null ? "mainSiteId\":$mainSiteId,\"subSiteId\":$subSiteId" : ''}}",
        "DocSubjectSrc": subject,
        "DocFullSerial": docFullSerial,
        "SecurityLevel": securityLevelId,
        "RegistryOU": deptId,
      };

      if (searchType != AppDefaultKeys.searchTypeGeneral && searchType != AppDefaultKeys.searchTypeInternal) {
        if (subSiteId != null || mainSiteId != null) {
          formParams["SitesInfoTo"] = "{\"siteType\":$siteTypeId,\"mainSiteId\":$mainSiteId,\"subSiteId\":$subSiteId}";
        } else if (siteTypeId != null) {
          formParams["SitesInfoTo"] = "{\"siteType\":$siteTypeId}";
        } else {
          formParams["SitesInfoTo"] = null;
        }
        if (searchType == AppDefaultKeys.searchTypeOutgoing && approverStartDate != null) {
          formParams[AppDefaultKeys.approvers] = "{\"userId\":null,\"userOuId\":null,\"approveDate\":{\"first\":$approverStartDate,\"second\":$approverEndDate}}";
        }
        if (searchType == AppDefaultKeys.searchTypeIncoming && docHistoryDateFrom != null) {
          formParams[AppDefaultKeys.incomingHistoryDate] = "{\"From\":\"$docHistoryDateFrom\",\"To\":\"$docHistoryDateTo\"}";
        }
      }

      myRequest.formParameters = formParams;

      myRequest.method = HttpMethod.httpPOST;

      MyServiceResponse response = await ServiceHandlerBase.postData(myServiceRequest: myRequest);
      debugPrint(response.resultString);
      if (response.isSuccessResponse) {
        var jsonBody = json.decode(response.resultString);
        for (var item in jsonBody['rs']) {
          searchResultItems.add(SearchResultItem.fromEmpty(item));
        }
        // if (!AppHelper.isCurrentArabic) {
        //   await Clipboard.setData(ClipboardData(text: response.resultString));
        // }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return searchResultItems;
  }

  static Future<List<FollowupOu>> getFollowupOrTransferOUs({bool forTransfer = false}) async {
    List<FollowupOu> followupOuList = [];
    MyServiceRequest myRequest = MyServiceRequest();
    try {
      myRequest.serviceRelativeUrl = forTransfer ? AppServiceURLS.getOuForTransfer : AppServiceURLS.getFollowupOus;

      MyServiceResponse serviceResponse = await ServiceHandlerBase.getData(myServiceRequest: myRequest);

      var jsonBody = json.decode(serviceResponse.resultString);

      for (var item in jsonBody['rs']) {
        followupOuList.add(FollowupOu.forEmpty(item));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return followupOuList;
  }

  static Future<List<FollowupUser>> getFollowupOrTransferUsers(int followupOuId) async {
    List<FollowupUser> followupUserList = [];
    MyServiceRequest myRequest = MyServiceRequest();
    try {
      myRequest.serviceRelativeUrl = AppServiceURLS.getFollowupOuUsers;

      myRequest.formParameters = {"ou": followupOuId};
      MyServiceResponse serviceResponse = await ServiceHandlerBase.postData(myServiceRequest: myRequest);

      var jsonBody = json.decode(serviceResponse.resultString);

      for (var item in jsonBody['rs']) {
        followupUserList.add(FollowupUser.forEmpty(item));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    //
    // print(followupOuId);
    // print(AppHelper.currentUserSession.defaultOUID);
    return followupUserList.skipWhile((user) => user.ouId == AppHelper.currentUserSession.defaultOUID && user.id == AppHelper.currentUserSession.id).toList();
  }

  static Future<List<InboxItem>> getFollowupUserItems(int followupOuId, String followupUserDomainName, int securityLevelId) async {
    List<InboxItem> followupItemList = [];
    MyServiceRequest myRequest = MyServiceRequest();
    try {
      myRequest.serviceRelativeUrl = AppServiceURLS.getEmployeeFollowupItems.replaceAll('{OUID}', followupOuId.toString()).replaceAll('{User}', followupUserDomainName) + securityLevelId.toString();

      MyServiceResponse serviceResponse = await ServiceHandlerBase.getData(myServiceRequest: myRequest);

      var jsonBody = json.decode(serviceResponse.resultString);

      for (var item in jsonBody['rs']) {
        followupItemList.add(InboxItem.fromEmpty(item));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return followupItemList;
  }

  static Future<bool> transferDocument(String senderUserLogin, String wobNum, String senderOUtoMove, String comment) async {
    MyServiceRequest myRequest = MyServiceRequest();
    try {
      myRequest.serviceRelativeUrl = AppServiceURLS.transfer.replaceAll('{WobNumber}', wobNum);

      myRequest.formParameters = {"user": senderUserLogin, "comment": comment, "appUserOUID": senderOUtoMove, "fromUserOUID": AppHelper.currentUserSession.defaultOUID};

      MyServiceResponse serviceResponse = await ServiceHandlerBase.putData(myServiceRequest: myRequest);
      return serviceResponse.isSuccessResponse;
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  static Future<List<OrganizationUnit>> getOUListForManagerProxy() async {
    return AppHelper.getCurrentUserOuList();

    // List<OrganizationUnit> ouList = [];
    // MyServiceRequest myRequest = MyServiceRequest();
    // try {
    //   for (DepartmentModel dept
    //       in AppHelper.currentUserSession.userDepartments) {
    //     ouList.add(OrganizationUnit(
    //         int.parse(dept.ouId.toString()),
    //         dept.arOuName,
    //         dept.enOuName,
    //         bool.parse(dept.hasRegistry.toString()),
    //         bool.parse(dept.isStatusActive.toString()),
    //         -1,
    //         dept.regOuId,
    //         dept.regOuId));
    //   }

    // myRequest.serviceRelativeUrl = AppServiceURLS.getAllActiveOUs;
    //
    // MyServiceResponse serviceResponse =
    //     await ServiceHandlerBase.getData(myServiceRequest: myRequest);
    //
    // var jsonBody = json.decode(serviceResponse.resultString);
    // for (var item in jsonBody['rs']) {
    //   OrganizationUnit tempOu=OrganizationUnit.forEmpty(item);
    //
    //   if(AppHelper.currentUserSession.userDepartments.any((dept) =>dept.ouId== tempOu.ouID)) {
    //     ouList.add(OrganizationUnit.forEmpty(tempOu));
    //   }
    // }
    // } catch (e) {
    //  debugPrint(e.toString());
    // }
    // return ouList;
  }

  static Future<List<ProxyUserModel>> getProxyUsers(int selectedOuId) async {
    MyServiceRequest myRequest = MyServiceRequest();
    List<ProxyUserModel> proxyUserList = [];
    try {
      myRequest.serviceRelativeUrl = AppServiceURLS.getUsersForProxy;

      myRequest.formParameters = {"regOu": null, "outOfOffice": false, "includeChildOus": false, "ou": selectedOuId};

      MyServiceResponse serviceResponse = await ServiceHandlerBase.postData(myServiceRequest: myRequest);

      var jsonBody = json.decode(serviceResponse.resultString);

      debugPrint(serviceResponse.resultString);

      for (var item in jsonBody['rs']) {
        proxyUserList.add(ProxyUserModel.fromEmpty(item));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    proxyUserList.removeWhere((proxy) => proxy.loginName == AppHelper.currentUserSession.userName);

    return proxyUserList;
  }

  static Future<bool> setProxyUser(ProxyUserModel proxyModel, int proxyUserOuId, bool isOnLeave) async {
    MyServiceRequest myRequest = MyServiceRequest();
    try {
      myRequest.serviceRelativeUrl = AppServiceURLS.delegate;
      Map<String, Object> proxyParams = {"id": proxyModel.id};
      Map<String, Object> currentUserParams = {
        "id": AppHelper.currentUserSession.id,
        "outOfOffice": isOnLeave,
      };
      myRequest.formParameters = {
        "id": AppHelper.currentUserSession.ouId,
        "applicationUser": currentUserParams,
        "proxyUser": proxyParams,
        "proxyStartDate": DateTime.now().millisecondsSinceEpoch,
        "proxyEndDate": DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch,
        "viewProxyMessage": false,
        "proxyMessage": null,
        "useProxyWFSecurity": false,
        "proxyOUId": proxyUserOuId,
        "proxyAuthorityLevels": proxyModel.securityLevels,
      };
      MyServiceResponse response = await ServiceHandlerBase.putData(myServiceRequest: myRequest);
      return response.isSuccessResponse;
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  static Future<bool> terminateProxyUser() async {
    MyServiceRequest myRequest = MyServiceRequest();
    try {
      myRequest.serviceRelativeUrl = AppServiceURLS.terminateDelegate.replaceAll("{OuUserId}", AppHelper.currentUserSession.ouId.toString());

      MyServiceResponse response = await ServiceHandlerBase.deleteData(myServiceRequest: myRequest);
      return response.isSuccessResponse;
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }
}
