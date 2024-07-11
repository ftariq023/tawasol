import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tawasol/actions_pages/print_doc_info.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/inbox_Item.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/search_result_item.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/sent_Item.dart';
import 'package:tawasol/app_models/app_view_models/view_document_model.dart';
import 'package:tawasol/theme/theme_provider.dart';

import '../app_models/service_models/service_urls.dart';
import '../custom_controls/doc_info_row.dart';
import 'package:clipboard/clipboard.dart';

class DocInfo extends StatelessWidget {
  DocInfo({super.key, required this.currentItem});

  final _scrollController = ScrollController();
  final dynamic currentItem;

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    var divider = const Divider(
      height: 2,
      indent: 15,
      endIndent: 15,
      color: Color.fromARGB(41, 0, 0, 0),
    );
    // Color appColor = Theme.of(context).colorScheme.primary;
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          // color: ThemeProvider.isDarkMode ? Colors.black : Colors.white,
          color: ThemeProvider.isDarkModeCheck() ? Colors.black : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(7),
            // Set the desired top-left border radius
            topRight: Radius.circular(7), // Set the desired top-right border radius
          ),
        ),
        // backgroundColor: Colors.white,
        // appBar: PreferredSize(
        //   preferredSize: const Size(650, 50),
        //   child: PopupTitle(
        //     title: AppLocalizations.of(context)!.information,
        //   ),
        // ),
        child: Column(
          children: [
            Container(
              // width: 300,
              // height: 50,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  // Set the desired top-left border radius
                  topRight: Radius.circular(7), // Set the desired top-right border radius
                ),
              ),
              child: Center(
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.documentInfo,
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    IconButton(
                        onPressed: () {
                          PrintDocInfo.printGeneratedDocInfoPdf(currentItem, context, true);
                        },
                        icon: const Icon(
                          CupertinoIcons.share,
                          size: 30,
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                height: 510,
                // width: 200,
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        controller: _scrollController,
                        children: [
                          if (currentItem is! LinkedDocument)
                            DocInfoCustomRow(
                                title: AppLocalizations.of(context)!.serialNumber,
                                value: currentItem.docSerial,
                                isGreyRow: true,
                                isCopy: true,
                                onPressed: () {
                                  _copyToClipboard(currentItem.docSerial, context);
                                }),
                          if (currentItem is! LinkedDocument) divider,
                          DocInfoCustomRow(
                              title: AppLocalizations.of(context)!.docSub,
                              value: currentItem.docSubject,
                              isGreyRow: false,
                              isCopy: true,
                              onPressed: () {
                                _copyToClipboard(currentItem.docSubject, context);
                              }),
                          divider,
                          if (currentItem is! LinkedDocument && (currentItem is! SearchResultItem || (currentItem is SearchResultItem && currentItem.mainSite != '')))
                            Column(
                              children: [
                                DocInfoCustomRow(title: AppLocalizations.of(context)!.mainSite, value: currentItem.mainSite, isGreyRow: true, isCopy: false, onPressed: null),
                                divider,
                              ],
                            ),
                          if (currentItem is! LinkedDocument && (currentItem is! SearchResultItem || (currentItem is SearchResultItem && currentItem.mainSite != '')))
                            Column(
                              children: [
                                DocInfoCustomRow(title: AppLocalizations.of(context)!.subSite, value: currentItem.subSite, isGreyRow: false, isCopy: false, onPressed: null),
                                divider,
                              ],
                            ),
                          DocInfoCustomRow(
                              title: AppLocalizations.of(context)!.docSubType,
                              value: currentItem is LinkedDocument ? currentItem.docClassName : AppHelper.getDocumentType(docType: currentItem is! SearchResultItem ? currentItem.docClassId : AppHelper.getDocumentClassIdByName(currentItem.classDescription.toLowerCase()), context: context, needLocal: true),
                              isGreyRow: true,
                              isCopy: false,
                              onPressed: null),
                          divider,
                          if (currentItem is InboxItem || currentItem is LinkedDocument)
                            Column(
                              children: [
                                DocInfoCustomRow(title: AppLocalizations.of(context)!.docCreatedDate, isDate: true, value: DateFormat().addPattern(AppDefaults.dateFormat).format(currentItem.createdOn), isGreyRow: false, isCopy: false, onPressed: null),
                                divider,
                              ],
                            ),
                          if (currentItem is! SentItem)
                            Column(
                              children: [
                                DocInfoCustomRow(title: AppLocalizations.of(context)!.securityLevel, value: currentItem.securityLevelName, isGreyRow: false, isCopy: false, onPressed: null),
                                divider,
                              ],
                            ),
                          if (currentItem is InboxItem || currentItem is LinkedDocument)
                            Column(
                              children: [
                                DocInfoCustomRow(title: AppLocalizations.of(context)!.priorityLevel, value: currentItem.priorityLevelName, isGreyRow: true, isCopy: false, onPressed: null),
                                divider,
                                // DocInfoCustomRow(
                                //     title: AppLocalizations.of(context)!.folder,
                                //     value: 'Inbox',
                                //     isGreyRow: true),
                                if (currentItem is! LinkedDocument && currentItem.followupDate != null)
                                  Column(
                                    children: [
                                      DocInfoCustomRow(title: AppLocalizations.of(context)!.followupDate, isDate: true, value: DateFormat().addPattern(AppDefaults.dateFormat).format(currentItem.followupDate), isGreyRow: false, isCopy: false, onPressed: null),
                                      divider,
                                    ],
                                  ),
                                if (currentItem is! LinkedDocument) DocInfoCustomRow(title: AppLocalizations.of(context)!.followupStatus, value: currentItem.followupStatus, isGreyRow: false, isCopy: false, onPressed: null),
                                if (currentItem is! LinkedDocument) divider,
                                // DocInfoCustomRow(
                                //     title: AppLocalizations.of(context)!
                                //         .linkedDocumentsCount,
                                //     value: currentItem.linkedDocsNo.toString(),
                                //     isGreyRow: false),
                                // DocInfoCustomRow(
                                //     title: AppLocalizations.of(context)!.attachmentCount,
                                //     value: currentItem.linkedDocsNo.toString(),
                                //     isGreyRow: false),
                                if (currentItem is! LinkedDocument) DocInfoCustomRow(title: AppLocalizations.of(context)!.receivedOn, isDate: true, value: DateFormat().addPattern(AppDefaults.dateFormat).format(currentItem.receivedDate), isGreyRow: false, isCopy: false, onPressed: null),
                              ],
                            ),
                          if (currentItem is! InboxItem && currentItem is! LinkedDocument) DocInfoCustomRow(title: AppLocalizations.of(context)!.actionDate, isDate: true, value: DateFormat().addPattern(AppDefaults.dateFormat).format(currentItem.actionDate), isGreyRow: false, isCopy: false, onPressed: null),
                          if (currentItem is! LinkedDocument) divider,
                          if (currentItem is! LinkedDocument) DocInfoCustomRow(title: AppLocalizations.of(context)!.action, value: currentItem.actionName, isGreyRow: false, isCopy: false, onPressed: null),
                          if (currentItem is! LinkedDocument) divider,
                          if (currentItem is! LinkedDocument) DocInfoCustomRow(title: AppLocalizations.of(context)!.comment, value: currentItem.comment, maxLinesForText: 4, isGreyRow: false, isCopy: false, onPressed: null),
                          if (currentItem is! LinkedDocument) divider,
                          if (currentItem is LinkedDocument)
                            Column(
                              children: [
                                DocInfoCustomRow(title: AppLocalizations.of(context)!.lastModified, value: DateFormat().addPattern(AppDefaults.dateFormat).format(currentItem.lastModified), maxLinesForText: 4, isGreyRow: false, isCopy: false, onPressed: null),
                                divider,
                                DocInfoCustomRow(title: AppLocalizations.of(context)!.creatorOU, value: currentItem.creatorOuName, maxLinesForText: 4, isGreyRow: false, isCopy: false, onPressed: null),
                                divider,
                                DocInfoCustomRow(title: AppLocalizations.of(context)!.docDate, value: DateFormat().addPattern(AppDefaults.dateFormat).format(currentItem.docDate), maxLinesForText: 4, isGreyRow: false, isCopy: false, onPressed: null),
                                divider,
                                DocInfoCustomRow(title: AppLocalizations.of(context)!.createdBy, value: currentItem.creatorName, maxLinesForText: 4, isGreyRow: false, isCopy: false, onPressed: null),
                                divider,
                                DocInfoCustomRow(title: AppLocalizations.of(context)!.lastModifier, value: currentItem.lastModifierName, maxLinesForText: 4, isGreyRow: false, isCopy: false, onPressed: null),
                                divider,
                              ],
                            )
                        ],
                      ),
                    ),
                    FloatingActionButton.small(
                      onPressed: _scrollDown,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      elevation: 0.5,
                      child: const Icon(
                        Icons.arrow_downward,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // bottomNavigationBar: Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 5),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       MyButton(btnText: AppLocalizations.of(context)!.close, onTap: () => Navigator.of(context).pop()),
        //     ],
        //   ),
        // ),

        // bottomNavigationBar: MyButton(
        //     btnText: AppLocalizations.of(context)!.close,
        //     onTap: () => Navigator.of(context).pop()),
      ),
    );
  }

  void _copyToClipboard(String text, BuildContext context) {
    FlutterClipboard.copy(text).then(
      (result) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Text copied to clipboard'),
        //     duration: Duration(seconds: 2),
        //   ),
        // );
      },
    );
  }
}
