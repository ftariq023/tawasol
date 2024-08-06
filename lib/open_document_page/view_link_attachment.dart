import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../actions_pages/print_doc_info.dart';
import '../app_models/app_utilities/app_helper.dart';
import '../app_models/app_utilities/app_routes.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/inbox_Item.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/search_result_item.dart';
import '../app_models/app_view_models/db_entities/sent_Item.dart';
import '../app_models/app_view_models/user_signature.dart';
import '../custom_controls/custom_dialog.dart';

class ViewLinkAttachment extends StatelessWidget {
  final dynamic currentItem;
  final String docSubject;
  final bool isFromTransfer;
  final Uint8List? docContent;

  const ViewLinkAttachment({
    super.key,
    required this.isFromTransfer,
    required this.currentItem,
    required this.docSubject,
    required this.docContent,
  });

  @override
  Widget build(BuildContext context) {
    var mqContext = MediaQuery.of(context);
    var size = mqContext.size;

    var mHeight = size.height - AppBar().preferredSize.height - mqContext.padding.top - mqContext.padding.bottom;
    var mWidth = size.width;

    bool isPortrait = mqContext.orientation == Orientation.portrait;

    var lang = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              if (AppHelper.listOfVIPUsers.contains(AppHelper.currentUserSession.userName.toLowerCase())) {
                await Printing.layoutPdf(onLayout: (_) => docContent!);
              } else {
                PrintDocInfo.printGeneratedDocInfoPdf(currentItem, context, false);
              }
              // PrintDocInfo.printGeneratedDocInfoPdf(
              //     currentItem, context, false);
              //  Routes.movePrint(context: context, docFile: docContent!);
            },
            iconSize: 30,
            icon: const Icon(
              CupertinoIcons.printer,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.close,
                size: 30,
              )),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          docSubject,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SfPdfViewer.memory(docContent!),
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
                            // Routes.moveSend(context: context, selectedItem: currentItem);
                            Routes.moveSend2(
                              ctx: context,
                              selectedItem: currentItem,
                              rHgt: mHeight,
                              rWdt: mWidth,
                              langg: lang,
                            );
                          },
                          child: Text(
                            lang.send,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w200),
                          )),
                    if (currentItem is! SearchResultItem && currentItem is! SentItem && currentItem.isApproveEnabled)
                      TextButton(
                          onPressed: () async {
                            AppHelper.showLoaderDialog(context);
                            List<UserSignature> signatureList = await AppHelper.getUserSignatures(context);
                            // AppHelper.hideLoader(buildContext);
                            if (AppHelper.currentUserSession.userName.toLowerCase() == AppHelper.ministerUser || signatureList.where((sign) => sign.signContent.isNotEmpty).length == 1) {
                              bool isApproved = await AppHelper.onApproveTapped(context: context, inboxItem: currentItem, signatureVsId: signatureList.firstWhere((signature) => signature.signContent.isNotEmpty).vsId, isNeedShowLoader: false);

                              if (isApproved) {
                                Routes.moveDashboard(context: context);
                              }
                            } else {
                              CustomDialog.showApproveDialog(context, currentItem);
                            }
                          },
                          child: Text(
                            lang.approve,
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
                            lang.multiSend,
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
                            lang.terminate,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w200),
                          )),
                  ],
                ),
              ),
            ),
    );
  }
}
