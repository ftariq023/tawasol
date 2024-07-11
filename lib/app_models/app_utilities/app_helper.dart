import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:tawasol/app_models/app_utilities/cache_manager.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/inbox_Item.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/organization_unit.dart';
import 'package:tawasol/app_models/app_view_models/tawasol_entity.dart';
import 'package:tawasol/app_models/app_view_models/user_session.dart';
import 'package:tawasol/app_models/service_models/my_service_response.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../app_models/service_models/service_handler.dart';
import '../../custom_controls/custom_dialog.dart';
import '../../custom_controls/slide_action.dart';
import '../../l10n/l10n.dart';
import '../../main.dart';
import '../../theme/theme_provider.dart';
import '../app_view_models/db_entities/wf_action.dart';
import '../app_view_models/db_entities/app_user.dart';
import '../app_view_models/department.dart';
import '../app_view_models/user_signature.dart';
import '../service_models/service_urls.dart';
import 'app_routes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppHelper {
  static String attachmentErrorMsg = "";
  static bool isSent = false;

  static bool get isAndroid {
    return defaultTargetPlatform == TargetPlatform.android;
  }

  static Future<List<UserSignature>> getUserSignatures(BuildContext context) async {
    return await ServiceHandler.getSignatureList(context);
  }

  static Future<bool> onApproveTapped({required BuildContext context, required InboxItem inboxItem, required String signatureVsId, bool validateMultiSignature = true, bool isNeedShowLoader = true}) async {
    if (isNeedShowLoader) {
      AppHelper.showLoaderDialog(context);
    }

    MyServiceResponse? response = await ServiceHandler.approveDocument(vsId: inboxItem.vsID, signVsId: signatureVsId, docType: inboxItem.docClassId, wobNumber: inboxItem.wobNumber);

    if (response!.resultString.contains(AppDefaultKeys.sameUserAuthorize)) {
      String selectedAction = await AppHelper.showCustomAlertDialog(
        context,
        null,
        AppLocalizations.of(context)!.approvedBySameUser,
        AppLocalizations.of(context)!.yes,
        AppLocalizations.of(context)!.no,
      );

      if (selectedAction == AppLocalizations.of(context)!.yes) {
        response = await ServiceHandler.approveDocument(
          vsId: inboxItem.vsID,
          signVsId: signatureVsId,
          docType: inboxItem.docClassId,
          wobNumber: inboxItem.wobNumber,
          validateMultiSignature: false,
        );
      } else {
        return false;
      }
    }

    if (!response!.isSuccessResponse) {
      await AppHelper.showCustomAlertDialog(
        context,
        null,
        AppLocalizations.of(context)!.errorMessage,
        AppLocalizations.of(context)!.close,
        null,
      );
    }

    AppHelper.hideLoader(context);

    if (response.isSuccessResponse) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          AppLocalizations.of(context)!.approveSuccess,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        )));
      }
      // await AppHelper.showCustomAlertDialog(context, null, AppLocalizations.of(context)!.approveSuccess, AppLocalizations.of(context)!.close, null);
    } else {
      await AppHelper.showCustomAlertDialog(
        context,
        null,
        AppLocalizations.of(context)!.errorMessage,
        AppLocalizations.of(context)!.close,
        null,
      );
      return false;
    }
    return response.isSuccessResponse;
  }

  static String getDocumentType({required int docType, BuildContext? context, bool needLocal = true}) {
    String docTypeContent = '';
    switch (docType) {
      case 0:
        {
          docTypeContent = needLocal ? AppLocalizations.of(context!)!.outgoing : 'outgoing';
          break;
        }
      case 1:
        {
          docTypeContent = needLocal ? AppLocalizations.of(context!)!.incoming : 'incoming';
          break;
        }
      case 2:
        {
          docTypeContent = needLocal ? AppLocalizations.of(context!)!.internal : 'internal';
          break;
        }
      default:
        {
          return 'none';
        }
    }
    return docTypeContent;
  }

  static int getDocumentClassIdByName(String docTypeName) {
    switch (docTypeName) {
      case 'outgoing':
        return 0;
      case 'incoming':
        return 1;
      case 'internal':
        return 2;
      default:
        return -1;
    }
  }

  static Future toggleScreenSecurity(bool isTurnOn) async {
    if (isTurnOn) {
      await ScreenProtector.preventScreenshotOn();
      _protectDataLeakageOn();
    } else {
      await ScreenProtector.protectDataLeakageOff();
      await ScreenProtector.preventScreenshotOff();
    }
  }

  static List<OrganizationUnit> getCurrentUserOuList() {
    List<OrganizationUnit> ouList = [];
    for (DepartmentModel dept in AppHelper.currentUserSession.userDepartments) {
      ouList.add(OrganizationUnit(int.parse(dept.ouId.toString()), dept.arOuName, dept.enOuName, bool.parse(dept.hasRegistry.toString()), bool.parse(dept.isStatusActive.toString()), -1, dept.regOuId, dept.regOuId));
    }
    return ouList;
  }

  static void _protectDataLeakageOn() async {
    if (Platform.isIOS) {
      await ScreenProtector.protectDataLeakageWithColor(Colors.white);
    } else if (Platform.isAndroid) {
      await ScreenProtector.protectDataLeakageOn();
    }
  }

  static bool get isIOS {
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  static Future<MyServiceResponse> login(String userName, String password, int? ouId) async {
    return await ServiceHandler.getUserByCredentials(userName: userName, password: password, ouID: ouId);
  }

// '34MJJn1eLokVPn8rUdShpmdNfMrqA8jI3KUDZXLYke4=:HkYefYrECycVZtIsVzZHpg=='  quality
// 'KGau22iSmwynj0jCm8wOwlE8Z2kHeYv1Mro0ZfHS1q8=:DibALE+Kv30PjaDRTBdOyw=='  support16

  static Future<TawasolEntity> get getCurrentTawasolEntity async {
    return await CacheManager.getEntityDetailsLocally(AppCacheKeys.entityFileName);
  }

  static Future<UserSession> get getCurrentUserSession async {
    return await CacheManager.getUserSessionLocally(AppCacheKeys.userSessionFileName);
  }

  static UserSession currentUserSession = UserSession();
  static TawasolEntity currentTawasolEntity = TawasolEntity();

//0 english 1 arabic
  static void changeLocalization(BuildContext ctx) {
    Locale myLocale = Localizations.localeOf(ctx);
    if (myLocale == L10n.all.elementAt(0)) {
      MyApp.of(ctx)?.setLocale(L10n.all.elementAt(1));
      isCurrentArabic = true;
    } else {
      MyApp.of(ctx)?.setLocale(L10n.all.elementAt(0));
      isCurrentArabic = false;
    }
  }

  static bool isMobileDevice(BuildContext context) => MediaQuery.of(context).size.shortestSide < 600;

  // static Future showLoaderDialog(BuildContext ctx) async {
  //   showDialog(
  //     context: ctx,
  //     builder: (ctx) {
  //       return const Center(child: CircularProgressIndicator());
  //     },
  //   );
  // }

  static showLoaderDialog(BuildContext context) {
    AlertDialog alert = const AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Center(
        child: CupertinoActivityIndicator(
          // color: Theme.of(context).colorScheme.primary,
          color: Color(0xFF0E4B6E),
          animating: true,
          radius: 15,
        ),
        // child: CircularProgressIndicator(
        //   color: Theme.of(context).colorScheme.primary,
        // ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static void hideLoader(BuildContext ctx) {
    //if (!ctx.mounted) return;
    Navigator.of(ctx).pop();
  }

  static bool isCurrentArabic = true;

  static bool isDashboardFromLogin = false;

  static Future<String> showCustomAlertDialog(
    BuildContext context,
    String? alertTitle,
    String alertMessage,
    String accept,
    String? reject,
  ) async {
    String? actionSelected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: ThemeProvider.isDarkMode ? null : Colors.white,
        surfaceTintColor: ThemeProvider.isDarkMode ? null : Colors.white,
        shadowColor: null,
        contentPadding: const EdgeInsets.all(20),
        actionsPadding: const EdgeInsets.only(bottom: 10),
        actionsAlignment: MainAxisAlignment.center,
        shape: RoundedRectangleBorder(side: BorderSide(width: 0.5, color: Colors.grey.shade700), borderRadius: const BorderRadius.all(Radius.circular(10))),
        title: alertTitle == null ? null : Text(alertTitle),
        // insetPadding: const EdgeInsets.all(0),
        // actionsPadding: const EdgeInsets.only(bottom: 10),
        // backgroundColor: Colors.white,
        // contentPadding: const EdgeInsets.all(30),
        // shape: RoundedRectangleBorder(
        //     side: BorderSide(
        //         color: Theme.of(context).colorScheme.primary, width: 0.5),
        //     borderRadius: BorderRadius.circular(8)),
        content: SingleChildScrollView(
          child: Text(
            alertMessage,
            style: const TextStyle(
              // color: Colors.grey.shade800,
              fontSize: 16,
            ),
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, accept),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  fixedSize: const Size(120, 30),
                  alignment: Alignment.center,
                ),
                child: Text(accept),
              ),
              if (reject != null) ...[
                Container(
                  color: Colors.grey,
                  height: 22,
                  width: 0.3,
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, reject),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    fixedSize: const Size(120, 30),
                    alignment: Alignment.center,
                  ),
                  child: Text(reject),
                ),
              ],
            ],
          )
        ],
      ),
    );
    return actionSelected.toString();
  }

  static Future<String> showAttachmentErrorDialog(
    BuildContext context,
    String? alertTitle,
    String alertMessage,
    String accept,
    String? reject,
    double contHgt,
  ) async {
    String? actionSelected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: ThemeProvider.isDarkMode ? null : Colors.white,
        surfaceTintColor: ThemeProvider.isDarkMode ? null : Colors.white,
        shadowColor: null,
        contentPadding: const EdgeInsets.all(20),
        actionsPadding: const EdgeInsets.only(bottom: 10),
        actionsAlignment: MainAxisAlignment.center,
        shape: RoundedRectangleBorder(side: BorderSide(width: 0.5, color: Colors.grey.shade700), borderRadius: const BorderRadius.all(Radius.circular(10))),
        title: alertTitle == null ? null : Text(alertTitle),
        // insetPadding: const EdgeInsets.all(0),
        // actionsPadding: const EdgeInsets.only(bottom: 10),
        // backgroundColor: Colors.white,
        // contentPadding: const EdgeInsets.all(30),
        // shape: RoundedRectangleBorder(
        //     side: BorderSide(
        //         color: Theme.of(context).colorScheme.primary, width: 0.5),
        //     borderRadius: BorderRadius.circular(8)),
        content: Container(
          height: contHgt,
          child: SingleChildScrollView(
            child: Text(
              // alertMessage + "\n\nalertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessagealertMessage4u",
              alertMessage + "\n\n" + attachmentErrorMsg,
              style: const TextStyle(
                // color: Colors.grey.shade800,
                fontSize: 16,
              ),
            ),
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, accept),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  fixedSize: const Size(120, 30),
                  alignment: Alignment.center,
                ),
                child: Text(accept),
              ),
              if (reject != null) ...[
                Container(
                  color: Colors.grey,
                  height: 22,
                  width: 0.3,
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, reject),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    fixedSize: const Size(120, 30),
                    alignment: Alignment.center,
                  ),
                  child: Text(reject),
                ),
              ],
            ],
          )
        ],
      ),
    );
    return actionSelected.toString();
  }

  static Future<bool> authenticate() async {
    try {
      LocalAuthentication auth = LocalAuthentication();

      bool authenticate = await auth.authenticate(
        localizedReason: 'Register yourself for easy login',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
      // print('Authenticated: $authenticate');
      return authenticate;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

  static List<String> get listOfVIPUsers => const [
        "aalhamar",
        "a1338",
        "opm1338",
        "a2314",
        "a1965",
        "a2401",
        "a5720",
        "tawasol1",
        "Tawasol1",
        "a2629",
        "a3079",
      ];

  static String get ministerUser => "minister";

  static void showAnnouncementAlertDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Icon(
            Icons.warning_outlined,
            color: myColor("#B89B46"),
            size: 28,
          ),
        ),
        // insetPadding: const EdgeInsets.all(0),
        // actionsPadding: const EdgeInsets.only(bottom: 10),
        // backgroundColor: Colors.white,
        // contentPadding: const EdgeInsets.all(30),
        // shape: RoundedRectangleBorder(
        //     side: BorderSide(
        //         color: Theme.of(context).colorScheme.primary, width: 0.5),
        //     borderRadius: BorderRadius.circular(8)),
        content: Text(
          //   "تصوير المستندات و تداولها يعرض مرتكبها للعقوبة المنصوص عليها بالمادة ( ۳۳۲ ) في قانون العقوبات رقم (١١) لسنة ٢٠٠٤ ومخالفا لما نصت عليه المادة رقم ( ۷۲ ) من قانون الخدمة العسكرية.",
          removeAllHtmlTags(currentUserSession.announcements[0].body),
          style: const TextStyle(
            // color: Colors.black,
            fontWeight: FontWeight.w300,
            fontSize: 16,
          ),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.transparent)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppLocalizations.of(context)!.close,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  static String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  static http.Client? httpClient;

  static Color myColor(String colorString) => Color(int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);

  // static Color themeColor = Colors.pink;

  static String setMailDate(String? mailDate) {
    if (mailDate == null || mailDate.isEmpty) return "-";
    List dates = mailDate.split(" ");
    if (dates.length > 1) {
      DateTime ob = DateFormat("dd/MM/yyyy").parse(mailDate);
      DateTime ob2 = DateUtils.dateOnly(DateTime.now());
      if (ob.compareTo(ob2) == 0) {
        return dates[1] + " " + dates[2];
      }
      return dates[0];
    }
    return mailDate;
  }

  static String setMailDateModified(String? mailDate) {
    if (mailDate == null || mailDate.isEmpty) return "-";
    List dates = mailDate.split(" ");
    // print(dates[1] + " " + dates[2]);
    if (dates.length > 1) {
      DateTime ob = DateFormat("dd/MM/yyyy").parse(mailDate);
      DateTime ob2 = DateUtils.dateOnly(DateTime.now());
      String diffBwDatesStr = (ob2.difference(ob).inDays).toString();
      int diffBwDates = int.parse(diffBwDatesStr);
      // print("diffBwDates");
      // print(diffBwDates);
      if (diffBwDates == 0) {
        return dates[1] + " " + dates[2];
      } else if (diffBwDates == 1) {
        return AppHelper.isCurrentArabic ? "أمس" : "Yesterday";
      } else if (diffBwDates < 7) {
        // return day name here
        String weekDay = DateFormat('EEEE').format(ob);
        if (AppHelper.isCurrentArabic) {
          if (weekDay == "Sunday") return "الأحد";
          if (weekDay == "Monday") return "الاثنين";
          if (weekDay == "Tuesday") return "يوم الثلاثاء";
          if (weekDay == "Wednesday") return "الأربعاء";
          if (weekDay == "Thursday") return "يوم الخميس";
          if (weekDay == "Friday") return "جمعة";
          if (weekDay == "Saturday") return "السبت";
        }
        return weekDay;
      }
      return dates[0];
    }
    return mailDate;
  }

  static ActionPane getContentOfSlideable({
    var rLang,
    var rBuildContext,
    var rContext,
    required bool isPort,
    required double mHgt,
    required double mWdt,
    required InboxItem rCurrentInboxItem,
  }) {
    return ActionPane(
      dragDismissible: false,
      // extentRatio: AppHelper.isMobileDevice(rContext) ? 0.75 : 0.45,
      extentRatio: AppHelper.isMobileDevice(rContext)
          ? 0.5
          : isPort
              ? 0.35
              : 0.3,
      // motion: const BehindMotion(),
      motion: const DrawerMotion(),
      // motion: const StretchMotion(),
      children: [
        CustomSlidableAction(
          padding: EdgeInsets.zero,
          backgroundColor: AppHelper.myColor("#0278AB"),
          onPressed: (context) {
            // Routes.moveSend(context: context, selectedItem: rCurrentInboxItem);
            Routes.moveSend2(
              ctx: rContext,
              selectedItem: rCurrentInboxItem,
              rHgt: mHgt,
              langg: rLang,
              rWdt: mWdt,
            );
          },
          child: SlideAction(
            imageName: "send_shortcut_new",
            actionName: rLang.send,
          ),
        ),
        if (rCurrentInboxItem.isApproveEnabled)
          CustomSlidableAction(
            padding: EdgeInsets.zero,
            onPressed: (context) async {
              AppHelper.showLoaderDialog(rBuildContext);
              List<UserSignature> signatureList = await AppHelper.getUserSignatures(rBuildContext);
              // signatureList.first.signCount == 1 && AppHelper.hideLoader(rBuildContext);
              if (AppHelper.currentUserSession.userName.toLowerCase() == AppHelper.ministerUser || signatureList.where((sign) => sign.signContent.isNotEmpty).length == 1) {
                bool isApproved = await AppHelper.onApproveTapped(
                  context: rBuildContext,
                  inboxItem: rCurrentInboxItem,
                  signatureVsId: signatureList.firstWhere((signature) => signature.signContent.isNotEmpty).vsId,
                  isNeedShowLoader: false,
                );
                // if (isApproved) {
                //   Routes.moveDashboard(context: rBuildContext);
                // }
                //
                // if (rCurrentInboxItem.securityLevelId == 4) Routes.moveSend(context: context, selectedItem: rCurrentInboxItem);
                //
                if (isApproved) {
                  if (rCurrentInboxItem.securityLevelId == 4)
                    Routes.moveSend(context: context, selectedItem: rCurrentInboxItem);
                  else
                    Routes.moveDashboard(context: rBuildContext);
                }
              } else {
                AppHelper.hideLoader(rBuildContext);
                CustomDialog.showApproveDialog(rBuildContext, rCurrentInboxItem);
              }
              // Routes.moveApprove(context, rCurrentInboxItem);
            },
            backgroundColor: AppHelper.myColor("#cb9640"),
            // backgroundColor: AppHelper.myColor("#419644"),
            child: SlideAction(
              imageName: "approve_shortcut_new",
              actionName: rLang.approve,
            ),
          ),
        if (!rCurrentInboxItem.isApproveEnabled)
          CustomSlidableAction(
            padding: EdgeInsets.zero,
            backgroundColor: AppHelper.myColor("#1054b9"),
            // backgroundColor: rCurrentInboxItem.isApproveEnabled? AppHelper.myColor('#0278AB'): Colors.blue.shade900,
            onPressed: (context) {
              // Routes.moveMultiSend(context: context, selectedItems: [rCurrentInboxItem]);
              Routes.moveMultiSend2(
                ctx: rContext,
                selectedItems: [rCurrentInboxItem],
                rWdt: mWdt,
              );
            },
            child: SlideAction(
              imageName: "multi_send_shortcut_new",
              actionName: rLang.multiSend,
            ),
          ),
        CustomSlidableAction(
          padding: EdgeInsets.zero,
          // backgroundColor: AppHelper.myColor("#BD332A"),
          backgroundColor: AppHelper.myColor("#cd2937"),
          onPressed: (context) {
            // CustomDialog.showTerminateDialog(context, [rCurrentInboxItem]);
            CustomDialog.showTerminateDialog2(
              context,
              [rCurrentInboxItem],
              mHgt,
            );
          },
          child: SlideAction(
            imageName: "terminate_shortcut_new",
            actionName: rLang.terminate,
          ),
        ),
      ],
    );
  }

  static Widget getRoundedBtn(String btnText, Color btnClr, VoidCallback onPress, double btnHgt, double btnWdt, double textSize) {
    return Container(
      height: btnHgt,
      width: btnWdt,
      child: ElevatedButton(
        // onPressed: () {},
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnClr,
          foregroundColor: Colors.white,
          // textStyle: TextStyle(
          //   fontSize: 30,
          //   fontWeight: FontWeight.bold,
          // ),
        ),
        child: Text(
          btnText,
          style: TextStyle(fontSize: textSize),
        ),
      ),
    );
  }

  // WfAction? latestAction = null;
  static List<WfAction> recentActions = [];

  static void processStoredRecentActions(String actionsWithIds) {
    List listOfUnsetActions = actionsWithIds.split(",");
    for (String unsetAction in listOfUnsetActions) {
      List singleAction = unsetAction.split("/");
      recentActions.add(WfAction(
        int.parse(singleAction[0]),
        singleAction[1],
        singleAction[2],
      ));
    }
  }

  static void saveRecentlyUsedActions(WfAction latestAction) {
    if (recentActions.isNotEmpty && recentActions[0] == latestAction) return;
    List<WfAction> updatedRecentActions = [];
    if (!recentActions.contains(latestAction)) {
      // print("doesnt contain");
      updatedRecentActions = [latestAction];
      int i = 1;
      for (WfAction anAction in recentActions) {
        if (i == 4) break;
        // updatedRecentActions[i++] = anAction;
        updatedRecentActions.add(anAction);
        i++;
      }
    } else {
      // print("contains");
      updatedRecentActions = recentActions;
      int indexOfNewAction = recentActions.indexOf(latestAction);
      // for (int i = 0; i < indexOfNewAction; i++) {
      //   updatedRecentActions[i + 1] = updatedRecentActions[i];
      // }
      updatedRecentActions[indexOfNewAction] = updatedRecentActions[0]; // swapping
      updatedRecentActions[0] = latestAction;
    }
    recentActions = updatedRecentActions;

    // storing in local strg:
    String recentActionsToBeSaved = '';
    for (WfAction anAction in recentActions) {
      String anActionInString = anAction.actionID.toString() + "/" + anAction.enActionName + "/" + anAction.arActionName + ",";
      recentActionsToBeSaved += anActionInString;
    }
    recentActionsToBeSaved = recentActionsToBeSaved.substring(0, recentActionsToBeSaved.length - 1);
    // print(recentActionsToBeSaved);
    var storage = const FlutterSecureStorage();
    storage.write(key: "mostUsedActions", value: recentActionsToBeSaved);
  }

  //users:
  static List<AppUser> recentUsers = [];

  static void processStoredRecentUsers(String users) {
    // print(users);
    List listOfUnsetUsers = users.split(",");
    for (String unsetUser in listOfUnsetUsers) {
      List singleUser = unsetUser.split("/");
      recentUsers.add(AppUser(
        int.parse(singleUser[0]),
        "",
        "",
        singleUser[1],
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        false,
        false,
        int.parse(singleUser[2]),
        0,
        "",
        "",
        false,
      ));
    }
  }

  static void saveRecentlyUsedUsers(List<AppUser> rcvdAppUsers) {
    if ((rcvdAppUsers == recentUsers) || (rcvdAppUsers.length == 1 && recentUsers.contains(rcvdAppUsers[0]))) return;
    if (recentUsers.isEmpty || rcvdAppUsers.length > 2) {
      recentUsers = rcvdAppUsers;
      if (recentUsers.length > 3) recentUsers = [recentUsers[0], recentUsers[1], recentUsers[2]];
    } else {
      // List updatedRecentUsers = [];
      List<AppUser> updatedRecentUsers = rcvdAppUsers;
      for (AppUser recentUser in recentUsers) {
        updatedRecentUsers.add(recentUser);
      }
      updatedRecentUsers = updatedRecentUsers.toSet().toList();
      if (updatedRecentUsers.length > 3) updatedRecentUsers = [updatedRecentUsers[0], updatedRecentUsers[1], updatedRecentUsers[2]];
      recentUsers = updatedRecentUsers;
    }
    // storing in local strg:
    String recentUsersToBeSaved = '';
    for (AppUser recentUser in recentUsers) {
      // String userInString = recentUser.id.toString() + ",";
      // String userInString = recentUser.id.toString() + "/" + recentUser.arAppUserName + "/" + recentUser.ouId.toString() + ",";
      String userInString = recentUser.id.toString() + "/" + recentUser.arAppUserName + "/" + recentUser.ouId.toString() + ",";
      recentUsersToBeSaved += userInString;
    }
    recentUsersToBeSaved = recentUsersToBeSaved.substring(0, recentUsersToBeSaved.length - 1);
    // print("recentUsersToBeSavedInString");
    // print(recentUsersToBeSaved);
    var storage = const FlutterSecureStorage();
    storage.write(key: "recentlyUsedUsers", value: recentUsersToBeSaved);
  }
}

class MyEncryptionDecryption {
  static final key = encrypt.Key.fromLength(32);
  static final encrypter = encrypt.Encrypter(encrypt.AES(key));
  static String ivString = "0102030405060708";

  static String encryptAES(String plainText) {
    try {
      if (plainText.isEmpty) return '';
      final iv = encrypt.IV.fromUtf8(ivString);
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      String aaa = '${key.base64}:${encrypted.base64}';
      print(aaa);
      return aaa;
    } catch (e) {
      print(e);
    }
    return '';
  }

  static String decryptAES(String encryptedText) {
    return '';
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

// public static
//
// string EncryptStringToBytes_Aes(string plainText) {
//   if (plainText == "")
//     return "";
//
//
//   byte[] encrypted;
//   // Create an Aes object
//   // with the specified key and IV.
//   byte[] key = null;
//   using(Aes aesAlg = Aes.Create())
//   {
//   //aesAlg.Key = Key;
//   aesAlg.IV = Encoding.UTF8.GetBytes(IVString);
//   aesAlg.GenerateKey();
//   key = aesAlg.Key;
//
//   // Create a decrytor to perform the stream transform.
//   ICryptoTransform encryptor = aesAlg.CreateEncryptor(aesAlg.Key, aesAlg.IV);
//   // Create the streams used for encryption.
//   using (MemoryStream msEncrypt = new MemoryStream())
//   {
//   using (CryptoStream csEncrypt = new CryptoStream(msEncrypt, encryptor, CryptoStreamMode.Write))
//   {
//   using (StreamWriter swEncrypt = new StreamWriter(csEncrypt))
//   {
//
//   //Write all data to the stream.
//   swEncrypt.Write(plainText);
//   }
//   encrypted = msEncrypt.ToArray();
//   }
//   }
//   }
//   string aaa = Convert.ToBase64String(key) + (":" + Convert.ToBase64String(encrypted));
//
//
//   string bbb = DecryptStringFromBytes_Aes(plainText);
//
//
// // Return the encrypted bytes from the memory stream.
//   return Convert.ToBase64String(key) + (":" + Convert.ToBase64String(encrypted));
// }
//
// public static
//
// string DecryptStringFromBytes_Aes(string cipherText) {
//   if (string.IsNullOrEmpty(cipherText))
//     return "";
//   //var temp = Convert.FromBase64String(cipherText);
//   try {
//     var key = cipherText.Split(':')[0];
//     cipherText = cipherText.Split(':')[1];
//
//     // Check arguments.
//     if (cipherText == null || cipherText.Length <= 0)
//       throw new ArgumentNullException("cipherText");
//     if (key == null || key.Length <= 0)
//       throw new ArgumentNullException("Key");
//     if (IVString == null || IVString.Length <= 0)
//       throw new ArgumentNullException("IV");
//
//     // Declare the string used to hold
//     // the decrypted text.
//     string plaintext = null;
//
//     // Create an Aes object
//     // with the specified key and IV.
//     using(Aes aesAlg = Aes.Create())
//   {
//   aesAlg.Key = Convert.FromBase64String(key);
//   aesAlg.IV = Encoding.UTF8.GetBytes(IVString);
//
//   // Create a decrytor to perform the stream transform.
//   ICryptoTransform decryptor = aesAlg.CreateDecryptor(aesAlg.Key, aesAlg.IV);
//
//   // Create the streams used for decryption.
//   using (MemoryStream msDecrypt = new MemoryStream(Convert.FromBase64String(cipherText)))
//   {
//   using (CryptoStream csDecrypt = new CryptoStream(msDecrypt, decryptor, CryptoStreamMode.Read))
//   {
//   using (StreamReader srDecrypt = new StreamReader(csDecrypt))
//   {
//
//   // Read the decrypted bytes from the decrypting
//   // and place them in a string.
//   plaintext = srDecrypt.ReadToEnd();
//   }
//   }
//   }
//
//   }
//
//   return plaintext;
//   }
//   catch (Exception exp)
//   {
//   return "";
//   }
// }

class DocType {
  static int get none => -1;
  static int get incoming => 1;
  static int get outgoing => 0;
  static int get internal => 2;
}

enum SearchType { general, incoming, outgoing, internalMemo }

enum HttpMethod { httpGet, httpPOST, httpPUT, httpDelete }

class HttpStatusCode {
  static int get oK => 200;

  static int get created => 201;

  static int get badRequest => 400;

  static int get unauthorized => 401;

  static int get forbidden => 403;

  static int get notFound => 404;

  static int get internalServerError => 500;
}
