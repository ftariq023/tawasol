import 'dart:async';

import 'dart:typed_data';

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:printing/printing.dart';

import 'package:tawasol/actions_pages/doc_info.dart';

import 'package:tawasol/app_models/app_utilities/app_helper.dart';

import 'package:tawasol/app_models/app_utilities/app_routes.dart';

import 'package:tawasol/app_models/app_view_models/db_entities/inbox_Item.dart';

import 'package:tawasol/app_models/app_view_models/db_entities/search_result_item.dart';

import 'package:tawasol/app_models/app_view_models/view_document_model.dart';

import 'package:tawasol/app_models/service_models/service_handler.dart';

import '../actions_pages/print_doc_info.dart';
import '../app_models/app_view_models/db_entities/sent_Item.dart';

import '../app_models/app_view_models/user_signature.dart';
import '../custom_controls/custom_dialog.dart';

import '../custom_controls/document_viewer.dart';

class ViewDocument extends StatelessWidget {
  ViewDocument({super.key, required this.currentItem, required this.viewDocModel, this.linkedDocument, this.isFromTransfer = false, this.onTransferCallback});

  dynamic currentItem;

  dynamic linkedDocument;

  final bool isFromTransfer;

  final VoidCallback? onTransferCallback;
  ViewDocumentModel viewDocModel = ViewDocumentModel();

  CustomPopupMenuController menuController = CustomPopupMenuController();

  @override
  Widget build(BuildContext context) {
    var mqContext = MediaQuery.of(context);
    var size = mqContext.size;

    var mHeight = size.height - AppBar().preferredSize.height - mqContext.padding.top - mqContext.padding.bottom;
    var mWidth = size.width;

    bool isPortrait = mqContext.orientation == Orientation.portrait;

    var lang = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 60),
        child: AppBar(
          actions: [
            if (viewDocModel.linkedDocuments.isNotEmpty && linkedDocument == null)
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: PopupMenuButton<List<String>>(
                  shadowColor: Theme.of(context).colorScheme.primary,
                  surfaceTintColor: Colors.white,
                  itemBuilder: (context) => [
                    ...viewDocModel.linkedDocuments.map(
                      (linkDoc) => PopupMenuItem(
                        value: [linkDoc.vsID, linkDoc.docSubject, linkDoc.documentClassId.toString()],
                        // row with 2 children
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.link,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    linkDoc.docSubject,
                                    style: TextStyle(color: Theme.of(context).colorScheme.primary, overflow: TextOverflow.ellipsis),
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                            if (viewDocModel.linkedDocuments.last != linkDoc)
                              Container(
                                height: 0.5,
                                width: double.infinity,
                                color: AppHelper.myColor("#d4d4d4"),
                              )
                          ],
                        ),
                      ),
                    ),
                  ],
                  position: PopupMenuPosition.under,
                  color: Colors.white,
                  elevation: 1,
                  // on selected we show the dialog box
                  onSelected: (docLink) async {
                    AppHelper.showLoaderDialog(context);
                    if (docLink.length > 2) {
                      ViewDocumentModel docModel = await ServiceHandler.getDocumentContentWithLinks(vsId: docLink[0], docClass: docLink[2]);
                      AppHelper.hideLoader(context);
                      Routes.moveViewDocument(context: context, docItem: currentItem, viewDocModel: docModel, linkedDocument: viewDocModel.linkedDocuments.firstWhere((x) => x.vsID == docLink[0]), isFromTransfer: isFromTransfer, onTransferCallback: onTransferCallback);
                    } else {
                      Uint8List? docContent = await ServiceHandler.fetchAttachmentContent(vsId: docLink[0]);
                      AppHelper.hideLoader(context);
                      Routes.moveViewLinkAttachment(context, isFromTransfer, currentItem, docLink[1], docContent);
                    }
                  },
                  child: const Icon(
                    CupertinoIcons.link,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),

            if (viewDocModel.attachments.isNotEmpty)
              const SizedBox(
                width: 15,
              ),
            if (viewDocModel.attachments.isNotEmpty)
              Padding(
                padding: viewDocModel.linkedDocuments.isNotEmpty ? const EdgeInsets.only(right: 5.0) : EdgeInsets.zero,
                child: PopupMenuButton<List<String>>(
                  shadowColor: Theme.of(context).colorScheme.primary,
                  surfaceTintColor: Colors.white,
                  offset: const Offset(0, 10),
                  itemBuilder: (context) => [
                    ...viewDocModel.attachments.map(
                      (attach) => PopupMenuItem(
                        value: [attach.vsId, attach.subject],
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.paperclip,
                                  size: 20,
                                  color: Colors.grey.shade700,
                                ),
                                // Image.asset(
                                // "assets/images/attachment.png",
                                // height: 20,
                                // width: 20,
                                // color: Colors.grey.shade700,
                                // ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    attach.subject,
                                    style: TextStyle(color: Theme.of(context).colorScheme.primary, overflow: TextOverflow.ellipsis),
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                            if (viewDocModel.attachments.last != attach)
                              Container(
                                height: 0.5,
                                width: double.infinity,
                                color: AppHelper.myColor("#d4d4d4"),
                              )
                          ],
                        ),
                      ),
                    ),
                  ],
                  position: PopupMenuPosition.under,
                  color: Colors.white,
                  elevation: 1,
                  // on selected we show the dialog box
                  onSelected: (docLink) async {
                    AppHelper.showLoaderDialog(context);
                    if (docLink.length > 2) {
                      ViewDocumentModel docModel = await ServiceHandler.getDocumentContentWithLinks(vsId: docLink[0], docClass: docLink[2]);
                      AppHelper.hideLoader(context);
                      Routes.moveViewLinkAttachment(context, isFromTransfer, currentItem, docLink[1], docModel.docPdfFile);
                    } else {
                      Uint8List? docContent = await ServiceHandler.fetchAttachmentContent(vsId: docLink[0]);
                      AppHelper.hideLoader(context);
                      Routes.moveViewLinkAttachment(context, isFromTransfer, currentItem, docLink[1], docContent);
                    }
                  },
                  child: const Icon(
                    CupertinoIcons.paperclip,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),

            const SizedBox(
              width: 15,
            ),
//=========Show Doc INFO================
            CustomPopupMenu(
                pressType: PressType.singleClick,
                arrowSize: 20,
                showArrow: true,
                barrierColor: Color.fromARGB(122, 0, 0, 0),
                controller: menuController,
                arrowColor: Theme.of(context).colorScheme.primary,
                position: PreferredPosition.bottom,
                verticalMargin: -10,
// horizontalMargin: 15,
                child: IconButton(
                  icon: Icon(
                    CupertinoIcons.lightbulb,
                    size: 32,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    menuController.showMenu();
                  },
                ),
                menuBuilder: () {
                  return Container(
                    width: 400,
                    height: 600,
                    // color: Colors.white,
                    child: DocInfo(
                      currentItem: linkedDocument ?? currentItem,
                    ),
                  );
                }),
            //=========================================
            const SizedBox(
              width: 15,
            ),
            IconButton(
              onPressed: () {
                // print("History");
                CustomDialog.showDocHistoryDialog(context, linkedDocument != null ? linkedDocument.vsID : currentItem.vsID, linkedDocument != null ? linkedDocument.docSubject : currentItem.docSubject);
              },
              iconSize: 30,
              icon: const Icon(
                CupertinoIcons.info_circle,
                color: Colors.white,
              ),
            ),

            const Spacer(),
            //  if (AppHelper.currentUserSession.isPrintDocumentEnabled)
            IconButton(
              onPressed: () async {
                if (AppHelper.listOfVIPUsers.contains(AppHelper.currentUserSession.userName.toLowerCase())) {
                  await Printing.layoutPdf(onLayout: (_) => viewDocModel.docPdfFile);
                } else {
                  PrintDocInfo.printGeneratedDocInfoPdf(linkedDocument ?? currentItem, context, false);
                }
                // Routes.movePrint(
                //  context: context, docFile: viewDocModel.docPdfFile);
              },
              iconSize: 30,
              icon: const Icon(
                CupertinoIcons.printer,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              iconSize: 30,
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ],
          backgroundColor: Theme.of(context).colorScheme.primary,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
// borderRadius: BorderRadius.only(
// bottomLeft: Radius.circular(20), // Adjust the border radius for left bottom
// bottomRight: Radius.circular(20), // Adjust the border radius for right bottom
// ),
            ),
          ),
          shape: const OvalBorder(side: BorderSide.none),
          leadingWidth: 10,
          leading: null,
          titleSpacing: 0,
          automaticallyImplyLeading: false,
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 10,
            color: Theme.of(context).colorScheme.primary,
          ),
          Expanded(child: DocumentViewer(docFile: viewDocModel.docPdfFile)),
        ],
      ),
      bottomNavigationBar: isFromTransfer
          ? const SizedBox.shrink()
          : Container(
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20, top: 0, bottom: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: currentItem is SentItem ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentItem is! SentItem)
                      TextButton(
                          onPressed: () {
                            // Routes.moveSend(
                            //   context: context,
                            //   selectedItem: currentItem,
                            //   // rHgt: mHeight,
                            //   // langg: lang,
                            //   // rWdt: mWidth,
                            // );
                            Routes.moveSend2(
                              ctx: context,
                              selectedItem: currentItem,
                              rHgt: mHeight,
                              langg: lang,
                              rWdt: mWidth,
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.send,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w200),
                          )),
                    if (currentItem is! SearchResultItem && currentItem is! SentItem && currentItem.isApproveEnabled)
                      TextButton(
                          onPressed: () async {
                            AppHelper.showLoaderDialog(context);
                            List<UserSignature> signatureList = await AppHelper.getUserSignatures(context);
                            // AppHelper.hideLoader(context);
                            if (signatureList.isNotEmpty) {
                              // AppHelper.hideLoader(buildContext);
                              //signatureList.first.signCount == 1 &&
                              if (AppHelper.currentUserSession.userName.toLowerCase() == AppHelper.ministerUser || signatureList.where((sign) => sign.signContent.isNotEmpty).length == 1) {
                                bool isApproved = await AppHelper.onApproveTapped(
                                  context: context,
                                  inboxItem: currentItem,
                                  signatureVsId: signatureList.firstWhere((signature) => signature.signContent.isNotEmpty).vsId,
                                  isNeedShowLoader: false,
                                );
                                // if (isApproved) {
                                //   Routes.moveDashboard(context: context);
                                // }
                                //
                                // if (currentItem.securityLevelId == 4) Routes.moveSend(context: context, selectedItem: currentItem);
                                //
                                //
                                if (isApproved) {
                                  if (currentItem.securityLevelId == 4)
                                    Routes.moveSend(context: context, selectedItem: currentItem);
                                  else
                                    Routes.moveDashboard(context: context);
                                }
                              } else {
                                CustomDialog.showApproveDialog(context, currentItem);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!.approveSuccess,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            AppLocalizations.of(context)!.approve,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w200),
                          )),
                    if (((currentItem is SearchResultItem || currentItem is SentItem) && currentItem.docSerial.isNotEmpty) || (currentItem is InboxItem && !currentItem.isApproveEnabled))
                      TextButton(
                          onPressed: () {
                            // Routes.moveMultiSend(
                            //   context: context,
                            //   selectedItems: [currentItem],
                            // );
                            Routes.moveMultiSend2(
                              ctx: context,
                              selectedItems: [currentItem],
                              rWdt: mWidth,
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.multiSend,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w200),
                          )),
                    if (currentItem is! SearchResultItem && currentItem is! SentItem)
                      TextButton(
                          onPressed: () {
                            CustomDialog.showTerminateDialog2(
                              context,
                              [currentItem],
                              mHeight,
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.terminate,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w200),
                          )),
                  ],
                ),
              ),
            ),

// floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
// floatingActionButton: (currentItem is SentItem || isFromTransfer)
// ? const SizedBox.shrink()
// : Container(
// padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
// margin: const EdgeInsets.symmetric(horizontal: 10),
// decoration: BoxDecoration(
// borderRadius: BorderRadius.circular(35),
// border: const Border.fromBorderSide(
// BorderSide(width: 0, color: Colors.transparent)),
// color: Colors.white,
// boxShadow: [
// BoxShadow(
// blurRadius: 4,
// spreadRadius: 1,
// color: Colors.grey.shade200,
// offset: const Offset(1.5, 1.5))
// ]),
// child: Row(
// mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// children: [
// GestureDetector(
// onTap: () {
// Routes.moveSend(
// context: context, selectedItem: currentItem);
// },
// child: Column(
// mainAxisSize: MainAxisSize.min,
// children: <Widget>[
// Image(
// image: const AssetImage(
// "assets/images/send_shortcut_new.png"),
// height: 40,
// width: 40,
// color: Theme.of(context).colorScheme.primary,
// ),
//
// // SvgPicture.asset(
// // "assets/images/send_new.svg",
// // height: 40,
// // width: 40,
// // ),
//
// // Icon(
// // Icons.send_outlined,
// // size: 40,
// // color: Theme.of(context).colorScheme.primary,
// // ),
// Text(
// AppLocalizations.of(context)!.send,
// style: TextStyle(
// color: Theme.of(context).colorScheme.primary),
// ),
// ],
// ),
// ),
// SizedBox(
// width: AppHelper.isMobileDevice(context) ? 25 : 30,
// ),
// if (currentItem is! SearchResultItem &&
// currentItem.isApproveEnabled)
// GestureDetector(
// onTap: () {
// CustomDialog.showApproveDialog(context, currentItem);
// },
// child: Column(
// mainAxisSize: MainAxisSize.min,
// children: <Widget>[
// const Image(
// image: AssetImage("assets/images/approve_new.png"),
// height: 40,
// width: 40,
// ),
//
// // SvgPicture.asset(
// // "assets/images/approve_new.svg",
// // height: 40,
// // width: 40,
// // ),
// // Icon(
// // Icons.verified_outlined,
// // size: 40,
// // color: Theme.of(context).colorScheme.primary,
// // ),
// Text(
// AppLocalizations.of(context)!.approve,
// style: TextStyle(
// color: Theme.of(context).colorScheme.primary),
// ),
// ],
// ),
// ),
// if (currentItem is! SearchResultItem &&
// currentItem.isApproveEnabled)
// SizedBox(
// width: AppHelper.isMobileDevice(context) ? 25 : 30,
// ),
// if ((currentItem is SearchResultItem &&
// currentItem.docSerial.isNotEmpty) ||
// (currentItem is InboxItem &&
// !currentItem.isApproveEnabled))
// GestureDetector(
// onTap: () {
// Routes.moveMultiSend(
// context: context, selectedItem: currentItem);
// },
// child: Column(
// mainAxisSize: MainAxisSize.min,
// children: <Widget>[
// const Image(
// image:
// AssetImage("assets/images/multi_send_new.png"),
// height: 40,
// width: 40,
// ),
//
// // Icon(
// // Icons.double_arrow_outlined,
// // size: 40,
// // color: Theme.of(context).colorScheme.primary,
// // ),
// Text(
// AppLocalizations.of(context)!.multiSend,
// style: TextStyle(
// color: Theme.of(context).colorScheme.primary),
// ),
// ],
// ),
// ),
// if (currentItem is InboxItem && !currentItem.isApproveEnabled)
// SizedBox(
// width: AppHelper.isMobileDevice(context) ? 25 : 30,
// ),
// if (currentItem is! SearchResultItem)
// GestureDetector(
// onTap: () {
// CustomDialog.showTerminateDialog(context, currentItem);
// },
// child: Column(
// mainAxisSize: MainAxisSize.min,
// children: <Widget>[
// // Icon(
// // Icons.indeterminate_check_box_rounded,
// // size: 40,
// // color: Theme.of(context).colorScheme.primary,
// // ),
//
// const Image(
// image:
// AssetImage("assets/images/terminate_new.png"),
// height: 40,
// width: 40,
// ),
//
// Text(
// AppLocalizations.of(context)!.terminate,
// style: TextStyle(
// color: Theme.of(context).colorScheme.primary),
// ),
// ],
// ),
// ),
// ],
// ),
// ),
// BottomNavigationBar(
// type: BottomNavigationBarType.fixed,
// elevation: 0,
// items: <BottomNavigationBarItem>[
// BottomNavigationBarItem(
// icon: GestureDetector(
// child: const Icon(
// Icons.send_outlined,
// size: 40,
// ),
// onTap: () {
// Routes.moveSend(context, currentItem);
// },
// ),
// label: AppLocalizations.of(context)!.send,
// ),
// BottomNavigationBarItem(
// icon: GestureDetector(
// onTap: () {
// CustomDialog.showApproveDialog(context, currentItem);
// },
// child: const Icon(
// Icons.verified_outlined,
// size: 40,
// ),
// ),
// label: AppLocalizations.of(context)!.approve,
// ),
// BottomNavigationBarItem(
// icon: GestureDetector(
// child: const Icon(
// Icons.double_arrow_outlined,
// size: 40,
// ),
// onTap: () {
// Routes.moveMultiSend(context, currentItem);
// },
// ),
// label: AppLocalizations.of(context)!.multiSend,
// ),
// BottomNavigationBarItem(
// icon: GestureDetector(
// onTap: () {
// CustomDialog.showTerminateDialog(context, currentItem);
// },
// child: const Icon(
// Icons.indeterminate_check_box_rounded,
// size: 40,
// ),
// ),
// label: AppLocalizations.of(context)!.terminate,
// ),
// ],
// unselectedItemColor: Theme.of(context).colorScheme.primary,
// ),
// floatingActionButton: isFromTransfer
// ? MyButton(
// onTap: () {
// CustomDialog.showTransferDialog(
// context, currentItem, onTransferCallback);
// },
// btnText: AppLocalizations.of(context)!.transfer,
// btnIconData: CupertinoIcons.arrow_branch,
// )
// : null,
    );
  }
}
