import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tawasol/actions_pages/approve.dart';
import 'package:tawasol/actions_pages/multi_send.dart';
import 'package:tawasol/actions_pages/search_result_view.dart';
import 'package:tawasol/actions_pages/send2.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/app_models/app_utilities/app_ui_helper.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/inbox_Item.dart';
import 'package:tawasol/app_models/app_view_models/view_document_model.dart';
import 'package:tawasol/custom_controls/print.dart';
import 'package:tawasol/landing_page/login.dart';
import 'package:tawasol/main_page/dashboard.dart';
import '../../actions_pages/multi_send2.dart';
import '../../actions_pages/print_doc_info.dart';
import '../../actions_pages/send.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../actions_pages/send3.dart';
import '../../custom_controls/dropdown.dart';
import '../../open_document_page/view_document.dart';
import '../../open_document_page/view_link_attachment.dart';
import '../../theme/theme_provider.dart';
import '../app_view_models/db_entities/search_result_item.dart';
import 'package:tawasol/actions_pages/proxy_user.dart' as pf;

class Routes {
  static moveDashboard({required BuildContext context, int? index}) => Navigator.of(context).push(
        AppUIHelper.pageBuilder(Dashboard(
          passedIndex: index,
        )),
      );

  static moveLogin(BuildContext context) => Navigator.pushReplacement(
        context,
        AppUIHelper.pageBuilder(Login()),
      );

  static moveViewDocument({required BuildContext context, dynamic docItem, required ViewDocumentModel viewDocModel, dynamic linkedDocument, bool isFromTransfer = false, VoidCallback? onTransferCallback}) => Navigator.of(context).push(
        AppUIHelper.pageBuilder(
          ViewDocument(
            currentItem: docItem,
            viewDocModel: viewDocModel,
            isFromTransfer: isFromTransfer,
            linkedDocument: linkedDocument,
            onTransferCallback: onTransferCallback,
          ),
        ),
      );

  static moveSend({required BuildContext context, required dynamic selectedItem, bool isFromSearchShortcut = false}) => Navigator.of(context).push(
        AppUIHelper.pageBuilder(
          Send(
            selectedItem: selectedItem,
            isFromSearchShortcut: isFromSearchShortcut,
          ),
        ),
      );

  static moveSend2({
    required BuildContext ctx,
    required dynamic selectedItem,
    required double rHgt,
    required double rWdt,
    required var langg,
    bool isFromSearchShortcut = false,
  }) {
    showModalBottomSheet<void>(
      context: ctx,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(rWdt * 0.05),
        ),
      ),
      builder: (BuildContext context) {
        // return Send2(
        //   selectedItem: selectedItem,
        //   isFromSearchShortcut: isFromSearchShortcut,
        // );
        return Send3(
          selectedItem: selectedItem,
          isFromSearchShortcut: isFromSearchShortcut,
        );
      },
    ).then((value) {
      if (AppHelper.isSent) {
        // print('object');
        AppHelper.isSent = false;
        Routes.moveDashboard(context: ctx);
        // Navigator.pushNamed(context, routeName)
      }
    });
  }

  static moveProxyUser({required BuildContext context, Function? callback}) => Navigator.of(context).push(
        AppUIHelper.pageBuilder(
          pf.ProxyUser(
            proxyCallback: callback,
          ),
        ),
      );

  static movePrint({required BuildContext context, required Uint8List docFile}) => Navigator.of(context).push(
        AppUIHelper.pageBuilder(
          PreviewScreen(
            doc: docFile,
          ),
        ),
      );

  static movePrintDocInfo({required BuildContext context, required dynamic currentItem}) => Navigator.of(context).push(
        AppUIHelper.pageBuilder(
          PrintDocInfo(
            currentItem,
          ),
        ),
      );

  static moveSearchResultView(BuildContext context, List<SearchResultItem> searchResultItems, bool isShowSites) => Navigator.of(context).push(
        AppUIHelper.pageBuilder(SearchResultView(
          searchResultItems: searchResultItems,
          isShowSites: isShowSites,
        )),
      );

  static moveMultiSend({required BuildContext context, required List selectedItems, bool isFromSearchShortcut = false}) => Navigator.of(context).push(
        AppUIHelper.pageBuilder(MultiSend(
          selectedItems: selectedItems,
          isFromSearchShortcut: isFromSearchShortcut,
        )),
      );

  static moveMultiSend2({
    required List selectedItems,
    required BuildContext ctx,
    required double rWdt,
    bool isFromSearchShortcut = false,
  }) {
    showModalBottomSheet<void>(
      context: ctx,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(rWdt * 0.05),
        ),
      ),
      builder: (BuildContext context) {
        return MultiSend2(
          selectedItems: selectedItems,
          isFromSearchShortcut: isFromSearchShortcut,
        );
      },
    ).then((value) {
      if (AppHelper.isSent) {
        AppHelper.isSent = false;
        Routes.moveDashboard(context: ctx);
      }
    });
  }

  static moveApprove(BuildContext context, InboxItem selectedInboxItem) => Navigator.of(context).push(
        AppUIHelper.pageBuilder(ApproveDocument(selectedInboxItem: selectedInboxItem)),
      );

  static moveViewLinkAttachment(BuildContext context, bool isFromTransfer, dynamic currentItem, String docSubject, Uint8List? docContent) => Navigator.of(context).push(
        AppUIHelper.pageBuilder(ViewLinkAttachment(isFromTransfer: isFromTransfer, currentItem: currentItem, docSubject: docSubject, docContent: docContent)),
      );
}
