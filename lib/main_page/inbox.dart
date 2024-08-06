import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:intl/intl.dart' as intl;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tawasol/app_models/app_view_models/user_signature.dart';
import 'package:tawasol/app_models/app_view_models/view_document_model.dart';
import 'package:tawasol/app_models/service_models/service_handler.dart';
import 'package:tawasol/app_models/service_models/service_urls.dart';
import 'package:tawasol/custom_controls/custom_dialog.dart';
import 'package:tawasol/custom_controls/my_button.dart';
import 'package:tawasol/custom_controls/slide_action.dart';
import 'package:tawasol/theme/theme_provider.dart';

import '../app_models/app_utilities/app_helper.dart';
import '../app_models/app_utilities/app_routes.dart';
import '../app_models/app_utilities/cache_manager.dart';
import '../app_models/app_view_models/db_entities/inbox_Item.dart';
import '../custom_controls/expandableDialog.dart';

class Inbox extends StatefulWidget {
  final bool multiSelectMode;
  final List selectedMailIndexes;
  VoidCallback enableMultiSelect;
  VoidCallback disableMultiSelect;

  // final ValueChanged<int> onItemSelection;

  Inbox({
    Key? key,
    required this.multiSelectMode,
    required this.selectedMailIndexes,
    required this.disableMultiSelect,
    required this.enableMultiSelect,
  }) : super(key: key);

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  bool isResponseReceived = false;

  List<InboxItem> inboxItems = [];

  bool isDarkMode = ThemeProvider.isDarkModeCheck();

  List<InboxItem> setInboxItems = [];
  TextEditingController searchController = TextEditingController();

  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // FileProvider.pgName = 'wfinbox';
    // Auth.countTotalNotif();
    callProviders();
  }

  // Future<void> callProviders() async {
  void callProviders() async {
    // setState(() {
    // isResponseReceived = false;
    // searchController.clear();
    // });
    inboxItems = await ServiceHandler.getUserInbox();
    // inboxItems = snapshot.data!;
    setInboxItems = inboxItems;
    //
    if (mounted) {
      setState(() {
        isResponseReceived = true;
      });
    }
  }

  void doNothing(BuildContext context) {}

  Future<List<InboxItem>> getInboxItems() async {
    return await ServiceHandler.getUserInbox();
  }

  Future<void> pullRefresh() async {
    setState(() {});
  }

  void onClickDuringMultiSelect(index) {
    setState(() {
      if (widget.selectedMailIndexes.contains(index)) {
        widget.selectedMailIndexes.remove(index);
      } else {
        widget.selectedMailIndexes.add(index);
      }
    });
  }

  void search() {
    if (searchController.text.isEmpty)
      setInboxItems = inboxItems;
    else {
      setInboxItems = [];
      String s = searchController.text.toLowerCase();
      for (int i = 0; i < inboxItems.length; i++) {
        // var mail = inboxItems[i];
        InboxItem mail = inboxItems[i];
        if ((mail.senderName).toLowerCase().contains(s) || (mail.docSubject).toLowerCase().contains(s) || (mail.mainSite).toLowerCase().contains(s) || (mail.subSite).toLowerCase().contains(s) || (mail.actionName).toLowerCase().contains(s)) {
          setInboxItems.add(mail);
        }
      }
    }
    // print("setting state");
    setState(() {});
  }

  void clearSearchField() {
    setState(() {
      searchController.clear();
      setInboxItems = inboxItems;
    });
  }

  // void navigateToOutboxDetails(int index) {
  //     Navigator.pushNamed(context, Dashboard.routeName, arguments: {
  //       'multiSelectMode': multiSelectMode,
  //       'selectedMailIndexes': selectedMailIndexes,
  //     }).then((_) {
  //     });
  //   }

  @override
  Widget build(BuildContext buildContext) {
    var mqContext = MediaQuery.of(context);
    var size = mqContext.size;

    var mHeight = size.height - AppBar().preferredSize.height - mqContext.padding.top - mqContext.padding.bottom;
    var mWidth = size.width;

    bool isPortrait = mqContext.orientation == Orientation.portrait;

    var lang = AppLocalizations.of(context)!;

    Color dividerClr = isDarkMode ? Color(0xFF323232) : Color(0xFFEEEEEE);
    Color searchTextClr = isDarkMode ? Color(0xFF868686) : Color(0xFFAEAEAE);

    var searchTextStyle = TextStyle(
      color: searchTextClr,
    );

    void onInboxItemTapped(BuildContext ctx, InboxItem item, int itemIndex) async {
      // print(item.securityLevelId);
      // Routes.moveDashboard(context: ctx);
      // return;
      AppHelper.showLoaderDialog(ctx);
      if (!item.isOpen) {
        await ServiceHandler.markItemAsRead(item.wobNumber);
        // inboxItems.elementAt(itemIndex).isOpen = true;
        setInboxItems.elementAt(itemIndex).isOpen = true;
        setState(() {});
      }

      // print('The SIgnature counts for this Inbox Item is '+ item.signatureCount.toString());
      // print("wob");
      // print(item.wobNumber);
      // print(item.vsID);
      // print(item.docClassId.toString());

      ViewDocumentModel viewDocModel = await ServiceHandler.getDocumentContentWithLinks(
        vsId: item.vsID,
        wobNumber: item.wobNumber,
        docClass: item.docClassId.toString(),
      );

      AppHelper.hideLoader(ctx);

      // viewDocModel.

      if (viewDocModel.docContent.isEmpty) {
        // ignore: use_build_context_synchronously
        AppHelper.showCustomAlertDialog(
          context,
          null,
          lang.errorMessage,
          lang.close,
          null,
          // mHeight * 0.22,
        );
        //
        // ignore: use_build_context_synchronously
        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return ExpandableDialog(
        //       lang,
        //       AppHelper.attachmentErrorMsg,
        //     );
        //   },
        // );
      } else {
        // ignore: use_build_context_synchronously
        Routes.moveViewDocument(
          context: context,
          linkedDocument: null,
          docItem: item,
          viewDocModel: viewDocModel,
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add Your Code here.
      if (AppHelper.currentUserSession.announcements.isNotEmpty && AppHelper.isDashboardFromLogin) {
        AppHelper.showAnnouncementAlertDialog(buildContext);
        //  CustomDialog.showAnnouncementsDialog(context);
        if (AppHelper.currentUserSession.isBiometricEnabled) {
          AppHelper.isDashboardFromLogin = false;
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Add Your Code here.
      if (!AppHelper.currentUserSession.isBiometricEnabled && AppHelper.isDashboardFromLogin) {
        AppHelper.isDashboardFromLogin = false;
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return Container(
              // height: AppHelper.isCurrentArabic
              //     ? ThemeProvider.isDarkModeCheck()
              //         ? 430
              //         : 385
              //     : 430,
              height: 440,
              width: AppHelper.isMobileDevice(buildContext) ? double.maxFinite : 550,
              decoration: const BoxDecoration(
                // color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      height: 1.5,
                      width: 40,
                      alignment: Alignment.center,
                      color: Colors.black,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 15, right: 20, left: 20),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.fingerprint_outlined,
                            color: ThemeProvider.primaryColor,
                            size: 40,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            lang.activateBiometricTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            lang.activateBiometricDescription,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          MyButton(
                              btnText: AppLocalizations.of(buildContext)!.activate,
                              btnWidth: 200,
                              onTap: () async {
                                bool fingerPrintSuccess = await AppHelper.authenticate();
                                if (fingerPrintSuccess) {
                                  CacheManager.updateBiometric(fingerPrintSuccess);
                                  AppHelper.currentUserSession.isBiometricEnabled = fingerPrintSuccess;
                                }
                                Navigator.pop(context);
                              }),
                          const SizedBox(
                            height: 10,
                          ),
                          TextButton(
                            child: Text(
                              lang.doLater,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        // final result = await AppHelper.showCustomAlertDialog(
        //   buildContext,
        //   null,
        //   AppLocalizations.of(buildContext)!.enableBiometric,
        //   AppLocalizations.of(buildContext)!.yes,
        //   AppLocalizations.of(buildContext)!.no,
        // );
        //
        // if (result == AppLocalizations.of(buildContext)!.yes) {
        //   bool fingerPrintSuccess = await AppHelper.authenticate();
        //   if (fingerPrintSuccess) {
        //     CacheManager.updateBiometric(fingerPrintSuccess);
        //     AppHelper.currentUserSession.isBiometricEnabled =
        //         fingerPrintSuccess;
        //   }
        // }

        //  CustomDialog.showAnnouncementsDialog(context);
      }
    });

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        // key: _scaffoldKey,
        // backgroundColor: Colors.white, //AppHelper.myColor("#f4f4f4"),
        // body: FutureBuilder<List<InboxItem>>(
        //   future: getInboxItems(),
        //   builder: (BuildContext context, AsyncSnapshot<List<InboxItem>> snapshot) {
        //     if (!snapshot.hasData) {
        //       // while data is loading:
        //       return Center(
        //         child: CupertinoActivityIndicator(
        //           color: Theme.of(context).colorScheme.primary,
        //           animating: true,
        //           radius: 15,
        //         ),
        //         // child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
        //       );
        //     } else {
        //       inboxItems = snapshot.data!;
        //       setInboxItems = inboxItems;
        //       // setState(() {});
        //       //====There is no Record=====
        //       if (setInboxItems.isEmpty) {
        //         return Center(
        //           child: Text(
        //             lang.noRecordFound,
        //             style: TextStyle(color: Colors.grey.shade700, fontSize: 18),
        //           ),
        //         );
        //       } else {
        //         //====There is Record=====
        //         return Padding(
        //           // padding: const EdgeInsets.only(top: 0.0, right: 0, left: 0, bottom: 0),
        //           padding: const EdgeInsets.all(0),
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.end,
        //             children: [
        //               // multi-select actions
        //               if (widget.multiSelectMode && widget.selectedMailIndexes.isNotEmpty) ...[
        //                 Container(
        //                   height: 40,
        //                   // width: double.infinity,
        //                   color: ThemeProvider.lightenClr(Theme.of(context).colorScheme.primary, 12),
        //                   // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.red)),
        //                   child: Row(
        //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
        //                     children: [
        //                       // Text(lang.multiSend),
        //                       GestureDetector(
        //                         onTap: () {
        //                           if (widget.selectedMailIndexes.isEmpty) return;
        //                           List selectedItems = [];
        //                           for (var index in widget.selectedMailIndexes) selectedItems.add(setInboxItems[index]);
        //                           Routes.moveMultiSend(
        //                             context: context,
        //                             selectedItems: selectedItems,
        //                           );
        //                         },
        //                         child: Text(
        //                           lang.multiSend,
        //                           style: const TextStyle(color: Colors.white),
        //                         ),
        //                       ),
        //                       // Divider(
        //                       //   height: 40,
        //                       //   thickness: 2,
        //                       //   color: Theme.of(context).colorScheme.primary,
        //                       // ),
        //                       GestureDetector(
        //                         onTap: () {
        //                           if (widget.selectedMailIndexes.isEmpty) return;
        //                           List selectedItems = [];
        //                           for (var index in widget.selectedMailIndexes) selectedItems.add(setInboxItems[index]);
        //                           CustomDialog.showTerminateDialog(context, selectedItems);
        //                         },
        //                         child: Text(lang.terminate, style: const TextStyle(color: Colors.white)),
        //                       )
        //                     ],
        //                   ),
        //                 ),
        //                 Divider(
        //                   color: Colors.grey.shade300,
        //                   height: 0.2,
        //                 )
        //               ],
        //               //========Docs Count=========
        //               Container(
        //                 height: mHeight * 0.05,
        //                 // width: double.infinity,
        //                 margin: EdgeInsets.only(top: mHeight * 0.007),
        //                 padding: EdgeInsets.symmetric(
        //                   horizontal: mWidth * 0.015,
        //                   // vertical: mHeight * 0.01,
        //                 ),
        //                 // color: Colors.red,
        //                 child: Row(
        //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                   // crossAxisAlignment: CrossAxisAlignment.center,
        //                   children: [
        //                     Container(
        //                       width: mWidth * 0.73,
        //                       child: TextField(
        //                         controller: searchController,
        //                         style: searchTextStyle,
        //                         onChanged: (_) => search(),
        //                         decoration: InputDecoration(
        //                           filled: true,
        //                           hintText: lang.search,
        //                           hintStyle: searchTextStyle,
        //                           prefixIcon: Icon(
        //                             Icons.search,
        //                             color: searchTextClr,
        //                           ),
        //                           contentPadding: const EdgeInsets.only(),
        //                           fillColor: isDarkMode ? const Color(0XFF282828) : const Color(0XFFF2F2F2),
        //                           border: OutlineInputBorder(
        //                             borderRadius: BorderRadius.circular(mWidth * 0.02),
        //                             borderSide: const BorderSide(
        //                               width: 0,
        //                               style: BorderStyle.none,
        //                             ),
        //                           ),
        //                           suffixIcon: searchController.text.isEmpty
        //                               ? null
        //                               : IconButton(
        //                                   icon: Icon(Icons.clear, size: mWidth * 0.05),
        //                                   onPressed: clearSearchField,
        //                                 ),
        //                         ),
        //                       ),
        //                     ),
        //                     Text(
        //                       lang.docCount + (widget.multiSelectMode ? widget.selectedMailIndexes.length.toString() + "/" : "") + setInboxItems.length.toString(),
        //                       style: TextStyle(
        //                         fontSize: 16,
        //                         color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.grey.shade600,
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //               const SizedBox(
        //                 height: 5,
        //               ),
        //               Divider(
        //                 // color: Colors.grey.shade300,
        //                 color: dividerClr,
        //                 height: 0.5,
        //               ),
        //               Expanded(
        //                 child: ListView.separated(
        //                   separatorBuilder: (context, index) {
        //                     //return const SizedBox.shrink();
        //                     return Divider(
        //                       height: 0.3,
        //                       // color: Colors.red,
        //                       color: dividerClr,
        //                     );
        //                     // return const SizedBox(
        //                     //   height: 20,
        //                     // );
        //                   },
        //                   // itemCount: snapshot.data!.length,
        //                   itemCount: setInboxItems.length,
        //                   physics: const AlwaysScrollableScrollPhysics(),
        //                   shrinkWrap: true,
        //                   padding: EdgeInsets.zero,
        //                   itemBuilder: (context, index) {
        //                     InboxItem currentInboxItem = setInboxItems[index];
        //                     return Directionality(
        //                       textDirection: TextDirection.ltr,
        //                       child: Slidable(
        //                         closeOnScroll: true,
        //                         //
        //                         endActionPane: AppHelper.isCurrentArabic
        //                             ? ActionPane(
        //                                 dragDismissible: false,
        //                                 // extentRatio: AppHelper.isMobileDevice(context) ? 0.75 : 0.45,
        //                                 extentRatio: AppHelper.isMobileDevice(context) ? 0.5 : 0.45,
        //                                 // motion: const BehindMotion(),
        //                                 motion: const DrawerMotion(),
        //                                 // motion: const StretchMotion(),
        //                                 children: [
        //                                   CustomSlidableAction(
        //                                     padding: EdgeInsets.zero,
        //                                     // borderRadius: BorderRadius.only(
        //                                     //   topLeft: AppHelper.isCurrentArabic ? const Radius.circular(0) : const Radius.circular(10),
        //                                     //   topRight: AppHelper.isCurrentArabic ? const Radius.circular(10) : const Radius.circular(0),
        //                                     //   bottomRight: AppHelper.isCurrentArabic ? const Radius.circular(10) : const Radius.circular(0),
        //                                     //   bottomLeft: AppHelper.isCurrentArabic ? const Radius.circular(0) : const Radius.circular(10),
        //                                     // ),
        //                                     backgroundColor: AppHelper.myColor("#0278AB"),
        //                                     onPressed: (context) {
        //                                       Routes.moveSend(context: context, selectedItem: currentInboxItem);
        //                                     },
        //                                     child: SlideAction(
        //                                       imageName: "send_shortcut_new",
        //                                       actionName: lang.send,
        //                                     ),
        //                                   ),
        //                                   if (currentInboxItem.isApproveEnabled)
        //                                     CustomSlidableAction(
        //                                       padding: EdgeInsets.zero,
        //                                       onPressed: (context) async {
        //                                         AppHelper.showLoaderDialog(buildContext);
        //                                         List<UserSignature> signatureList = await AppHelper.getUserSignatures(buildContext);
        //                                         //signatureList.first.signCount == 1 && AppHelper.hideLoader(buildContext);
        //                                         if (AppHelper.currentUserSession.userName.toLowerCase() == AppHelper.ministerUser || signatureList.where((sign) => sign.signContent.isNotEmpty).length == 1) {
        //                                           bool isApproved = await AppHelper.onApproveTapped(context: buildContext, inboxItem: currentInboxItem, signatureVsId: signatureList.firstWhere((signature) => signature.signContent.isNotEmpty).vsId, isNeedShowLoader: false);
        //                                           if (isApproved) {
        //                                             Routes.moveDashboard(context: buildContext);
        //                                           }
        //                                         } else {
        //                                           AppHelper.hideLoader(buildContext);
        //                                           CustomDialog.showApproveDialog(buildContext, currentInboxItem);
        //                                         }
        //                                         //  Routes.moveApprove(context, currentInboxItem);
        //                                       },
        //                                       backgroundColor: AppHelper.myColor("#cb9640"),
        //                                       // backgroundColor: AppHelper.myColor("#419644"),
        //                                       child: SlideAction(
        //                                         imageName: "approve_shortcut_new",
        //                                         actionName: lang.approve,
        //                                       ),
        //                                     ),
        //                                   if (!currentInboxItem.isApproveEnabled)
        //                                     CustomSlidableAction(
        //                                       padding: EdgeInsets.zero,
        //                                       backgroundColor: AppHelper.myColor("#1054b9"),
        //                                       // backgroundColor: currentInboxItem.isApproveEnabled? AppHelper.myColor('#0278AB'): Colors.blue.shade900,
        //                                       onPressed: (context) {
        //                                         Routes.moveMultiSend(
        //                                           context: context,
        //                                           selectedItems: [currentInboxItem],
        //                                         );
        //                                       },
        //                                       child: SlideAction(
        //                                         imageName: "multi_send_shortcut_new",
        //                                         actionName: lang.multiSend,
        //                                       ),
        //                                     ),
        //                                   CustomSlidableAction(
        //                                     padding: EdgeInsets.zero,
        //                                     // backgroundColor: AppHelper.myColor("#BD332A"),
        //                                     backgroundColor: AppHelper.myColor("#cd2937"),
        //                                     onPressed: (context) {
        //                                       CustomDialog.showTerminateDialog(context, [currentInboxItem]);
        //                                     },
        //                                     child: SlideAction(
        //                                       imageName: "terminate_shortcut_new",
        //                                       actionName: lang.terminate,
        //                                     ),
        //                                   ),
        //                                 ],
        //                               )
        //                             : null,
        //                         startActionPane: AppHelper.isCurrentArabic
        //                             ? null
        //                             : ActionPane(
        //                                 dragDismissible: false,
        //                                 // extentRatio: AppHelper.isMobileDevice(context) ? 0.75 : 0.45,
        //                                 extentRatio: AppHelper.isMobileDevice(context) ? 0.5 : 0.45,
        //                                 // motion: const BehindMotion(),
        //                                 motion: const DrawerMotion(),
        //                                 // motion: const StretchMotion(),
        //                                 children: [
        //                                   CustomSlidableAction(
        //                                     padding: EdgeInsets.zero,
        //                                     // borderRadius: BorderRadius.only(
        //                                     //   topLeft: AppHelper.isCurrentArabic ? const Radius.circular(0) : const Radius.circular(10),
        //                                     //   topRight: AppHelper.isCurrentArabic ? const Radius.circular(10) : const Radius.circular(0),
        //                                     //   bottomRight: AppHelper.isCurrentArabic ? const Radius.circular(10) : const Radius.circular(0),
        //                                     //   bottomLeft: AppHelper.isCurrentArabic ? const Radius.circular(0) : const Radius.circular(10),
        //                                     // ),
        //                                     backgroundColor: AppHelper.myColor("#0278AB"),
        //                                     onPressed: (context) {
        //                                       Routes.moveSend(context: context, selectedItem: currentInboxItem);
        //                                     },
        //                                     child: SlideAction(
        //                                       imageName: "send_shortcut_new",
        //                                       actionName: lang.send,
        //                                     ),
        //                                   ),
        //                                   if (currentInboxItem.isApproveEnabled)
        //                                     CustomSlidableAction(
        //                                       padding: EdgeInsets.zero,
        //                                       onPressed: (context) async {
        //                                         AppHelper.showLoaderDialog(buildContext);
        //                                         List<UserSignature> signatureList = await AppHelper.getUserSignatures(buildContext);
        //                                         //signatureList.first.signCount == 1 && AppHelper.hideLoader(buildContext);
        //                                         if (AppHelper.currentUserSession.userName.toLowerCase() == AppHelper.ministerUser || signatureList.where((sign) => sign.signContent.isNotEmpty).length == 1) {
        //                                           bool isApproved = await AppHelper.onApproveTapped(context: buildContext, inboxItem: currentInboxItem, signatureVsId: signatureList.firstWhere((signature) => signature.signContent.isNotEmpty).vsId, isNeedShowLoader: false);
        //                                           if (isApproved) {
        //                                             Routes.moveDashboard(context: buildContext);
        //                                           }
        //                                         } else {
        //                                           AppHelper.hideLoader(buildContext);
        //                                           CustomDialog.showApproveDialog(buildContext, currentInboxItem);
        //                                         }
        //                                         //  Routes.moveApprove(context, currentInboxItem);
        //                                       },
        //                                       backgroundColor: AppHelper.myColor("#cb9640"),
        //                                       // backgroundColor: AppHelper.myColor("#419644"),
        //                                       child: SlideAction(
        //                                         imageName: "approve_shortcut_new",
        //                                         actionName: lang.approve,
        //                                       ),
        //                                     ),
        //                                   if (!currentInboxItem.isApproveEnabled)
        //                                     CustomSlidableAction(
        //                                       padding: EdgeInsets.zero,
        //                                       backgroundColor: AppHelper.myColor("#1054b9"),
        //                                       // backgroundColor: currentInboxItem.isApproveEnabled? AppHelper.myColor('#0278AB'): Colors.blue.shade900,
        //                                       onPressed: (context) {
        //                                         Routes.moveMultiSend(
        //                                           context: context,
        //                                           selectedItems: [currentInboxItem],
        //                                         );
        //                                       },
        //                                       child: SlideAction(
        //                                         imageName: "multi_send_shortcut_new",
        //                                         actionName: lang.multiSend,
        //                                       ),
        //                                     ),
        //                                   CustomSlidableAction(
        //                                     padding: EdgeInsets.zero,
        //                                     // backgroundColor: AppHelper.myColor("#BD332A"),
        //                                     backgroundColor: AppHelper.myColor("#cd2937"),
        //                                     onPressed: (context) {
        //                                       CustomDialog.showTerminateDialog(context, [currentInboxItem]);
        //                                     },
        //                                     child: SlideAction(
        //                                       imageName: "terminate_shortcut_new",
        //                                       actionName: lang.terminate,
        //                                     ),
        //                                   ),
        //                                 ],
        //                               ),
        //                         child: Directionality(
        //                           textDirection: AppHelper.isCurrentArabic ? TextDirection.rtl : TextDirection.ltr,
        //                           child: GestureDetector(
        //                             onTap: widget.multiSelectMode
        //                                 ? () => onClickDuringMultiSelect(index)
        //                                 : () {
        //                                     // print("This is the function");
        //                                     onInboxItemTapped(context, currentInboxItem, index);
        //                                   },
        //                             // onDoubleTap: () => enableMultiSelect(index),
        //                             child: ListTile(
        //                               trailing: null,
        //                               contentPadding: EdgeInsets.zero,
        //                               leading: widget.multiSelectMode
        //                                   ? Padding(
        //                                       padding: AppHelper.isCurrentArabic ? const EdgeInsets.only(right: 10) : const EdgeInsets.only(left: 10),
        //                                       child: widget.selectedMailIndexes.contains(index)
        //                                           ? Icon(
        //                                               Icons.circle,
        //                                               size: 30,
        //                                               // color: Theme.of(context).primaryColor,
        //                                               color: Theme.of(context).colorScheme.primary,
        //                                             )
        //                                           : Icon(
        //                                               Icons.circle_outlined,
        //                                               // color: Theme.of(context).primaryColor,
        //                                               color: Theme.of(context).colorScheme.primary,
        //                                               size: 30,
        //                                             ),
        //                                     )
        //                                   : null,
        //                               subtitle: Stack(
        //                                 children: [
        //                                   Padding(
        //                                     padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
        //                                     child: Column(
        //                                       children: <Widget>[
        //                                         const SizedBox(
        //                                           height: 5,
        //                                         ),
        //                                         Row(
        //                                           children: <Widget>[
        //                                             // const Image(
        //                                             //   image: AssetImage(
        //                                             //     "assets/images/person_list_view_new.png",
        //                                             //   ),
        //                                             //   height: 32,
        //                                             //   width: 32,
        //                                             // ),
        //                                             //
        //                                             // const SizedBox(
        //                                             //   width: 5,
        //                                             // ),
        //                                             Text(
        //                                               currentInboxItem.senderName,
        //                                               style: TextStyle(
        //                                                 color: ThemeProvider.isDarkModeCheck() ? Colors.white : Theme.of(context).colorScheme.primary,
        //                                                 fontWeight: FontWeight.bold,
        //                                                 fontSize: 18,
        //                                               ),
        //                                             )
        //                                           ],
        //                                         ),
        //                                         Row(
        //                                           children: [
        //                                             // const Image(
        //                                             //   image: AssetImage(
        //                                             //       "assets/images/document_list_view_new.png"),
        //                                             //   height: 32,
        //                                             //   width: 32,
        //                                             // ),
        //                                             //
        //                                             // const SizedBox(
        //                                             //   width: 5,
        //                                             // ),
        //                                             Expanded(
        //                                               child: Tooltip(
        //                                                 message: currentInboxItem.docSubject.toUpperCase(),
        //                                                 child: Text(
        //                                                   currentInboxItem.docSubject.toUpperCase(),
        //                                                   maxLines: 10,
        //                                                   overflow: TextOverflow.ellipsis,
        //                                                   style: TextStyle(
        //                                                     fontSize: 17,
        //                                                     // color: ThemeProvider.isDarkMode && !ThemeProvider.adaptSystemTheme ? Colors.white : Colors.grey.shade700,
        //                                                     // color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.grey.shade700,
        //                                                     // color: Theme.of(context).colorScheme.primary,
        //                                                     color: ThemeProvider.isDarkModeCheck() ? Colors.white : Theme.of(context).colorScheme.primary,
        //                                                     // fontWeight: FontWeight.bold,
        //                                                   ),
        //                                                 ),
        //                                               ),
        //                                             ),
        //                                             Padding(
        //                                               padding: const EdgeInsets.symmetric(horizontal: 10),
        //                                               child: Container(
        //                                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        //                                                 decoration: BoxDecoration(
        //                                                   color: dividerClr,
        //                                                   // color: ThemeProvider.isDarkModeCheck() ? Colors.white70 : dividerClr,
        //                                                   borderRadius: BorderRadius.circular(12.0),
        //                                                 ),
        //                                                 child: Text(
        //                                                   AppHelper.getDocumentType(docType: currentInboxItem.docClassId, context: context, needLocal: true),
        //                                                   style: TextStyle(
        //                                                     fontSize: 14,
        //                                                     fontWeight: FontWeight.w500,
        //                                                     color: ThemeProvider.isDarkModeCheck() ? Colors.white70 : Theme.of(context).colorScheme.primary,
        //                                                   ),
        //                                                 ),
        //                                               ),
        //                                             ),
        //                                           ],
        //                                         ),
        //                                         Row(
        //                                           children: <Widget>[
        //                                             // const Image(
        //                                             //   image: AssetImage(
        //                                             //       "assets/images/department_list_view_new.png"),
        //                                             //   height: 32,
        //                                             //   width: 32,
        //                                             // ),
        //                                             //
        //                                             // const SizedBox(
        //                                             //   width: 5,
        //                                             // ),
        //                                             Expanded(
        //                                               child: Text(
        //                                                 '${currentInboxItem.mainSite} - ${currentInboxItem.subSite}',
        //                                                 overflow: TextOverflow.ellipsis,
        //                                                 style: TextStyle(
        //                                                   fontSize: 14,
        //                                                   // color: ThemeProvider.isDarkMode && !ThemeProvider.adaptSystemTheme ? Colors.white : Colors.grey.shade700,
        //                                                   // color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.grey.shade700,
        //                                                   color: ThemeProvider.isDarkModeCheck() ? Colors.white70 : Colors.grey.shade700,
        //                                                 ),
        //                                               ),
        //                                             ),
        //                                             Padding(
        //                                               padding: const EdgeInsets.symmetric(horizontal: 10),
        //                                               child: GestureDetector(
        //                                                 onTap: () {
        //                                                   widget.multiSelectMode ? onClickDuringMultiSelect(index) : CustomDialog.showDocHistoryDialog(context, currentInboxItem.vsID, currentInboxItem.docSubject);
        //                                                 },
        //                                                 child: Image(
        //                                                   image: const AssetImage("assets/images/doc_history.png"),
        //                                                   height: 32,
        //                                                   width: 32,
        //                                                   color: Theme.of(context).colorScheme.primary,
        //                                                 ),
        //                                               ),
        //                                             ),
        //                                             // if (widget.multiSelectMode)
        //                                             //   widget.selectedMailIndexes
        //                                             //           .contains(index)
        //                                             //       ? Icon(
        //                                             //           Icons.circle,
        //                                             //           size: 30,
        //                                             //           // color: Theme.of(context).primaryColor,
        //                                             //           color:
        //                                             //               Theme.of(context)
        //                                             //                   .colorScheme
        //                                             //                   .primary,
        //                                             //         )
        //                                             //       : Icon(
        //                                             //           Icons.circle_outlined,
        //                                             //           // color: Theme.of(context).primaryColor,
        //                                             //           color:
        //                                             //               Theme.of(context)
        //                                             //                   .colorScheme
        //                                             //                   .primary,
        //                                             //           size: 30,
        //                                             //         )
        //                                           ],
        //                                         ),
        //                                         Row(
        //                                           children: <Widget>[
        //                                             // const Icon(
        //                                             //   Icons.info_outline_rounded,
        //                                             //   size: 30, weight: 0.4,),
        //                                             // Image(
        //                                             //   image: const AssetImage(
        //                                             //       "assets/images/doc_history.png"),
        //                                             //   height: 30,
        //                                             //   width: 30,
        //                                             //   color: Theme.of(context)
        //                                             //       .colorScheme
        //                                             //       .primary,
        //                                             //   opacity:
        //                                             //       const AlwaysStoppedAnimation(
        //                                             //           .8),
        //                                             // ),
        //                                             //
        //                                             // const SizedBox(
        //                                             //   width: 5,
        //                                             // ),
        //                                             Expanded(
        //                                               child: Text(
        //                                                 currentInboxItem.actionName,
        //                                                 overflow: TextOverflow.ellipsis,
        //                                                 style: TextStyle(
        //                                                   fontSize: 14,
        //                                                   // color: ThemeProvider.isDarkMode && !ThemeProvider.adaptSystemTheme ? Colors.white70 : Colors.grey.shade700,
        //                                                   color: ThemeProvider.isDarkModeCheck() ? Colors.white70 : Colors.grey.shade700,
        //                                                 ),
        //                                               ),
        //                                             ),
        //                                             Padding(
        //                                               padding: const EdgeInsets.symmetric(horizontal: 12.0),
        //                                               child: Text(
        //                                                 // intl.DateFormat().addPattern(AppDefaults.dateFormat).format(currentInboxItem.receivedDate),
        //                                                 // currentInboxItem.receivedDate.toString(),
        //                                                 //
        //                                                 AppHelper.setMailDate(intl.DateFormat().addPattern(AppDefaults.dateFormat).format(currentInboxItem.receivedDate)),
        //                                                 // AppHelper.setMailDateModified("02/04/2024 08:07 PM"),
        //                                                 // AppHelper.setMailDateModified("01/04/2024 08:07 PM"),
        //                                                 // AppHelper.setMailDateModified("31/03/2024 08:07 PM"),
        //                                                 // AppHelper.setMailDateModified("30/03/2024 08:07 PM"),
        //                                                 // AppHelper.setMailDateModified("29/03/2024 08:07 PM"),
        //                                                 // AppHelper.setMailDateModified("28/03/2024 08:07 PM"),
        //                                                 // AppHelper.setMailDateModified("27/03/2024 08:07 PM"),
        //                                                 // AppHelper.setMailDateModified("26/03/2024 08:07 PM"),
        //                                                 // AppHelper.setMailDateModified("25/03/2024 08:07 PM"),
        //                                                 // AppHelper.setMailDateModified("10/03/2024 08:07 PM"),
        //                                                 textDirection: TextDirection.ltr,
        //                                                 overflow: TextOverflow.ellipsis,
        //                                                 style: TextStyle(
        //                                                   fontSize: 14,
        //                                                   // fontFamily: 'Arial',
        //                                                   // locale: const Locale('ar'),
        //                                                   color: ThemeProvider.isDarkModeCheck() ? Colors.white70 : Colors.grey.shade700,
        //                                                 ),
        //                                               ),
        //                                             ),
        //                                           ],
        //                                         ),
        //                                         // const SizedBox(
        //                                         //   height: 5,
        //                                         // ),
        //                                         // const SizedBox(
        //                                         //   height: 3,
        //                                         // ),
        //                                       ],
        //                                     ),
        //                                   ),
        //                                   if (!currentInboxItem.isOpen)
        //                                     Positioned(
        //                                       right: AppHelper.isCurrentArabic ? null : 0,
        //                                       top: 0,
        //                                       left: AppHelper.isCurrentArabic ? 0 : null,
        //                                       child: Image(
        //                                         image: AssetImage("assets/images/${AppHelper.isCurrentArabic ? 'new_ar' : 'new_en'}.png"),
        //                                         height: 45,
        //                                         width: 50,
        //                                       ),
        //                                     )
        //                                 ],
        //                               ),
        //                             ),
        //                           ),
        //                         ),
        //                       ),
        //                     );
        //                   },
        //                 ),
        //               ),
        //             ],
        //           ),
        //         );
        //       }
        //     }
        //   },
        // ),
        //
        //
        body: isResponseReceived
            ? Padding(
                // padding: const EdgeInsets.only(top: 0.0, right: 0, left: 0, bottom: 0),
                padding: const EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // multi-select actions
                    if (widget.multiSelectMode && widget.selectedMailIndexes.isNotEmpty) ...[
                      Container(
                        height: 40,
                        // width: double.infinity,
                        color: ThemeProvider.lightenClr(Theme.of(context).colorScheme.primary, 12),
                        // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.red)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Text(lang.multiSend),
                            GestureDetector(
                              onTap: () {
                                if (widget.selectedMailIndexes.isEmpty) return;
                                List selectedItems = [];
                                for (var index in widget.selectedMailIndexes) selectedItems.add(setInboxItems[index]);
                                // Routes.moveMultiSend(
                                //   context: context,
                                //   selectedItems: selectedItems,
                                // );
                                Routes.moveMultiSend2(
                                  ctx: context,
                                  selectedItems: selectedItems,
                                  rWdt: mWidth,
                                );
                              },
                              child: Text(
                                lang.multiSend,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (widget.selectedMailIndexes.isEmpty) return;
                                List selectedItems = [];
                                for (var index in widget.selectedMailIndexes) selectedItems.add(setInboxItems[index]);
                                // CustomDialog.showTerminateDialog(context, selectedItems);
                                CustomDialog.showTerminateDialog2(
                                  context,
                                  selectedItems,
                                  mHeight,
                                );
                              },
                              child: Text(lang.terminate, style: const TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey.shade300,
                        height: 0.2,
                      )
                    ],
                    //========Docs Count=========
                    Container(
                      height: mHeight * 0.06,
                      // width: double.infinity,
                      margin: EdgeInsets.only(top: mHeight * 0.007),
                      padding: EdgeInsets.symmetric(
                        horizontal: mWidth * 0.015,
                        // vertical: mHeight * 0.01,
                      ),
                      // color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: mWidth * 0.71,
                            child: TextField(
                              controller: searchController,
                              style: searchTextStyle,
                              enabled: isResponseReceived,
                              onChanged: (_) => search(),
                              decoration: InputDecoration(
                                filled: true,
                                hintText: lang.search,
                                hintStyle: searchTextStyle,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: searchTextClr,
                                ),
                                contentPadding: const EdgeInsets.only(),
                                fillColor: isDarkMode ? const Color(0XFF282828) : const Color(0XFFF2F2F2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(isPortrait ? mWidth * 0.02 : mWidth * 0.01),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                suffixIcon: searchController.text.isEmpty
                                    ? null
                                    : IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          size: AppHelper.isMobileDevice(context)
                                              ? mWidth * 0.05
                                              : isPortrait
                                                  ? mWidth * 0.03
                                                  : mWidth * 0.02,
                                        ),
                                        onPressed: clearSearchField,
                                      ),
                              ),
                            ),
                          ),
                          Text(
                            // lang.docCount + (widget.multiSelectMode ? widget.selectedMailIndexes.length.toString() + "/" : "") + setInboxItems.length.toString(),
                            lang.total + (widget.multiSelectMode ? widget.selectedMailIndexes.length.toString() + "/" : "") + setInboxItems.length.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Divider(
                      // color: Colors.grey.shade300,
                      color: dividerClr,
                      height: 0.5,
                    ),
                    setInboxItems.isNotEmpty
                        ? Expanded(
                            child: ListView.separated(
                              separatorBuilder: (context, index) {
                                //return const SizedBox.shrink();
                                return Divider(
                                  height: 0.3,
                                  // color: Colors.red,
                                  color: dividerClr,
                                );
                              },
                              // itemCount: snapshot.data!.length,
                              itemCount: setInboxItems.length,
                              physics: const AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                InboxItem currentInboxItem = setInboxItems[index];
                                return Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Slidable(
                                    closeOnScroll: true,
                                    endActionPane: AppHelper.isCurrentArabic
                                        ? AppHelper.getContentOfSlideable(
                                            rBuildContext: context,
                                            rContext: context,
                                            rLang: lang,
                                            isPort: isPortrait,
                                            rCurrentInboxItem: currentInboxItem,
                                            mHgt: mHeight,
                                            mWdt: mWidth,
                                          )
                                        : null,
                                    startActionPane: AppHelper.isCurrentArabic
                                        ? null
                                        : AppHelper.getContentOfSlideable(
                                            rBuildContext: context,
                                            rContext: context,
                                            rLang: lang,
                                            isPort: isPortrait,
                                            rCurrentInboxItem: currentInboxItem,
                                            mHgt: mHeight,
                                            mWdt: mWidth,
                                          ),
                                    child: Directionality(
                                      textDirection: AppHelper.isCurrentArabic ? TextDirection.rtl : TextDirection.ltr,
                                      child: GestureDetector(
                                        onTap: widget.multiSelectMode
                                            ? () => onClickDuringMultiSelect(index)
                                            : () {
                                                // print("This is the function");
                                                onInboxItemTapped(context, currentInboxItem, index);
                                              },
                                        // onDoubleTap: () => enableMultiSelect(index),
                                        child: ListTile(
                                          trailing: null,
                                          contentPadding: EdgeInsets.zero,
                                          leading: widget.multiSelectMode
                                              ? Padding(
                                                  padding: AppHelper.isCurrentArabic ? const EdgeInsets.only(right: 10) : const EdgeInsets.only(left: 10),
                                                  child: widget.selectedMailIndexes.contains(index)
                                                      ? Icon(
                                                          Icons.circle,
                                                          size: 30,
                                                          // color: Theme.of(context).primaryColor,
                                                          color: Theme.of(context).colorScheme.primary,
                                                        )
                                                      : Icon(
                                                          Icons.circle_outlined,
                                                          // color: Theme.of(context).primaryColor,
                                                          color: Theme.of(context).colorScheme.primary,
                                                          size: 30,
                                                        ),
                                                )
                                              : null,
                                          subtitle: Stack(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
                                                child: Column(
                                                  children: <Widget>[
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        // const Image(
                                                        //   image: AssetImage(
                                                        //     "assets/images/person_list_view_new.png",
                                                        //   ),
                                                        //   height: 32,
                                                        //   width: 32,
                                                        // ),
                                                        //
                                                        // const SizedBox(
                                                        //   width: 5,
                                                        // ),
                                                        Text(
                                                          currentInboxItem.senderName,
                                                          style: TextStyle(
                                                            color: ThemeProvider.isDarkModeCheck() ? Colors.white : Theme.of(context).colorScheme.primary,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 18,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        // const Image(
                                                        //   image: AssetImage(
                                                        //       "assets/images/document_list_view_new.png"),
                                                        //   height: 32,
                                                        //   width: 32,
                                                        // ),
                                                        //
                                                        // const SizedBox(
                                                        //   width: 5,
                                                        // ),
                                                        Expanded(
                                                          child: Tooltip(
                                                            message: currentInboxItem.docSubject.toUpperCase(),
                                                            child: Text(
                                                              currentInboxItem.docSubject.toUpperCase(),
                                                              maxLines: 10,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                fontSize: 17,
                                                                // color: ThemeProvider.isDarkMode && !ThemeProvider.adaptSystemTheme ? Colors.white : Colors.grey.shade700,
                                                                // color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.grey.shade700,
                                                                // color: Theme.of(context).colorScheme.primary,
                                                                color: ThemeProvider.isDarkModeCheck() ? Colors.white : Theme.of(context).colorScheme.primary,
                                                                // fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                            decoration: BoxDecoration(
                                                              color: dividerClr,
                                                              // color: ThemeProvider.isDarkModeCheck() ? Colors.white70 : dividerClr,
                                                              borderRadius: BorderRadius.circular(12.0),
                                                            ),
                                                            child: Text(
                                                              AppHelper.getDocumentType(docType: currentInboxItem.docClassId, context: context, needLocal: true),
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w500,
                                                                color: ThemeProvider.isDarkModeCheck() ? Colors.white70 : Theme.of(context).colorScheme.primary,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        // const Image(
                                                        //   image: AssetImage(
                                                        //       "assets/images/department_list_view_new.png"),
                                                        //   height: 32,
                                                        //   width: 32,
                                                        // ),
                                                        //
                                                        // const SizedBox(
                                                        //   width: 5,
                                                        // ),
                                                        Expanded(
                                                          child: Text(
                                                            '${currentInboxItem.mainSite} - ${currentInboxItem.subSite}',
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              // color: ThemeProvider.isDarkMode && !ThemeProvider.adaptSystemTheme ? Colors.white : Colors.grey.shade700,
                                                              // color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.grey.shade700,
                                                              color: ThemeProvider.isDarkModeCheck() ? Colors.white70 : Colors.grey.shade700,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              widget.multiSelectMode ? onClickDuringMultiSelect(index) : CustomDialog.showDocHistoryDialog(context, currentInboxItem.vsID, currentInboxItem.docSubject);
                                                            },
                                                            child: Image(
                                                              image: const AssetImage("assets/images/doc_history.png"),
                                                              height: 32,
                                                              width: 32,
                                                              color: Theme.of(context).colorScheme.primary,
                                                            ),
                                                          ),
                                                        ),
                                                        // if (widget.multiSelectMode)
                                                        //   widget.selectedMailIndexes
                                                        //           .contains(index)
                                                        //       ? Icon(
                                                        //           Icons.circle,
                                                        //           size: 30,
                                                        //           // color: Theme.of(context).primaryColor,
                                                        //           color:
                                                        //               Theme.of(context)
                                                        //                   .colorScheme
                                                        //                   .primary,
                                                        //         )
                                                        //       : Icon(
                                                        //           Icons.circle_outlined,
                                                        //           // color: Theme.of(context).primaryColor,
                                                        //           color:
                                                        //               Theme.of(context)
                                                        //                   .colorScheme
                                                        //                   .primary,
                                                        //           size: 30,
                                                        //         )
                                                      ],
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        // const Icon(
                                                        //   Icons.info_outline_rounded,
                                                        //   size: 30, weight: 0.4,),
                                                        // Image(
                                                        //   image: const AssetImage(
                                                        //       "assets/images/doc_history.png"),
                                                        //   height: 30,
                                                        //   width: 30,
                                                        //   color: Theme.of(context)
                                                        //       .colorScheme
                                                        //       .primary,
                                                        //   opacity:
                                                        //       const AlwaysStoppedAnimation(
                                                        //           .8),
                                                        // ),
                                                        //
                                                        // const SizedBox(
                                                        //   width: 5,
                                                        // ),
                                                        Expanded(
                                                          child: Text(
                                                            currentInboxItem.actionName,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              // color: ThemeProvider.isDarkMode && !ThemeProvider.adaptSystemTheme ? Colors.white70 : Colors.grey.shade700,
                                                              color: ThemeProvider.isDarkModeCheck() ? Colors.white70 : Colors.grey.shade700,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                          child: Text(
                                                            // intl.DateFormat().addPattern(AppDefaults.dateFormat).format(currentInboxItem.receivedDate),
                                                            // currentInboxItem.receivedDate.toString(),
                                                            //
                                                            AppHelper.setMailDateModified(intl.DateFormat().addPattern(AppDefaults.dateFormat).format(currentInboxItem.receivedDate)),
                                                            // AppHelper.setMailDateModified("02/04/2024 08:07 PM"),
                                                            // AppHelper.setMailDateModified("01/04/2024 08:07 PM"),
                                                            // AppHelper.setMailDateModified("31/03/2024 08:07 PM"),
                                                            // AppHelper.setMailDateModified("30/03/2024 08:07 PM"),
                                                            // AppHelper.setMailDateModified("29/03/2024 08:07 PM"),
                                                            // AppHelper.setMailDateModified("28/03/2024 08:07 PM"),
                                                            // AppHelper.setMailDateModified("27/03/2024 08:07 PM"),
                                                            // AppHelper.setMailDateModified("26/03/2024 08:07 PM"),
                                                            // AppHelper.setMailDateModified("25/03/2024 08:07 PM"),
                                                            // AppHelper.setMailDateModified("10/03/2024 08:07 PM"),
                                                            textDirection: TextDirection.ltr,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              // fontFamily: 'Arial',
                                                              // locale: const Locale('ar'),
                                                              color: ThemeProvider.isDarkModeCheck() ? Colors.white70 : Colors.grey.shade700,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    // const SizedBox(
                                                    //   height: 5,
                                                    // ),
                                                    // const SizedBox(
                                                    //   height: 3,
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                              if (!currentInboxItem.isOpen)
                                                Positioned(
                                                  right: AppHelper.isCurrentArabic ? null : 0,
                                                  top: 0,
                                                  left: AppHelper.isCurrentArabic ? 0 : null,
                                                  child: Image(
                                                    image: AssetImage("assets/images/${AppHelper.isCurrentArabic ? 'new_ar' : 'new_en'}.png"),
                                                    height: 45,
                                                    width: 50,
                                                  ),
                                                )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Text(
                              lang.noRecordFound,
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 18),
                            ),
                          ),
                  ],
                ),
              )
            : Center(
                child: CupertinoActivityIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  animating: true,
                  radius: 15,
                ),
              ),
      ),
    );
  }
}
