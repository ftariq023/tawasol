import 'package:flutter/material.dart';
import 'package:tawasol/actions_pages/announcements.dart';
import 'package:tawasol/actions_pages/doc_history.dart';
import 'package:tawasol/actions_pages/doc_info.dart';
import 'package:tawasol/actions_pages/proxy_user.dart';
import 'package:tawasol/actions_pages/terminate.dart';
import 'package:tawasol/actions_pages/transfer.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/inbox_Item.dart';
import '../actions_pages/approve.dart';
import '../actions_pages/terminate2.dart';

class CustomDialog {
  static showApproveDialog(BuildContext context, InboxItem currentInboxItem) {
    showDialog(
        context: context,
        // useSafeArea: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
            contentPadding: EdgeInsets.zero,
            scrollable: true,
            titlePadding: EdgeInsets.zero,
            title: null,
            content: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                ),
                height: 500,
                width: 400,
                child: ApproveDocument(selectedInboxItem: currentInboxItem)),
          );
        });
  }

  static showTerminateDialog(BuildContext context, List currentInboxItems) {
    //String comment = '';
    showDialog(
        context: context,
        useSafeArea: true,
        builder: (BuildContext context) {
          return AlertDialog(
            // shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
            contentPadding: EdgeInsets.zero,
            // backgroundColor: Colors.red,
            scrollable: true,
            titlePadding: EdgeInsets.zero,
            title: null,
            content: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              height: 320,
              width: 700,
              child: TerminateDocument(
                selectedInboxItems: currentInboxItems,
              ),
            ),
            actions: null,
          );
        });
  }

  static showTerminateDialog2(BuildContext context, List currentInboxItems, double mHgt) {
    //String comment = '';
    showDialog(
        context: context,
        useSafeArea: true,
        builder: (BuildContext context) {
          return AlertDialog(
            // shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
            contentPadding: EdgeInsets.zero,
            // backgroundColor: Colors.red,
            scrollable: true,
            titlePadding: EdgeInsets.zero,
            title: null,
            content: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              height: mHgt * 0.5,
              width: 700,
              child: TerminateDocument2(
                selectedInboxItems: currentInboxItems,
              ),
            ),
            actions: null,
          );
        });
  }

//=====Note: This was Dialog, it will be changed to Bottom Model Sheet per request===========
  static showDocHistoryDialog(BuildContext context, String docVsId, String subject) {
    // String comment = '';
    // showModalBottomSheet(
    //   isDismissible: false,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.white,
    //   elevation: 5,
    //   enableDrag: false,
    //   showDragHandle: false,
    //   shape: const RoundedRectangleBorder(
    //     borderRadius: BorderRadius.vertical(
    //       top: Radius.circular(15),
    //     ),
    //   ),
    //   context: context,
    //   builder: (context) {
    //     return DocumentHistory(
    //       subject: subject,
    //       vsId: docVsId,
    //     );
    //   },
    // );

    showDialog(
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          scrollable: true,
          insetPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          title: null,
          content: Container(
              height: MediaQuery.of(context).size.height - 250,
              width: MediaQuery.of(context).size.width - (AppHelper.isMobileDevice(context) ? 30 : 100),
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7)),
              ),
              child: DocumentHistory(
                subject: subject,
                vsId: docVsId,
              )),
          actions: null,
        );
      },
    );
  }

  static showDocInfoDialog(BuildContext context, dynamic currentItem) {
    //String comment = '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          scrollable: true,
          actionsPadding: const EdgeInsets.all(5),
          titlePadding: EdgeInsets.zero,
          title: null,
          content: Container(
            height: 450,
            width: 400,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            child: DocInfo(
              currentItem: currentItem,
            ),
          ),
          actions: null,
        );
      },
    );
  }

  static showTransferDialog(BuildContext context, dynamic currentItem, Function? callback) {
    //String comment = '';
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
              contentPadding: EdgeInsets.zero,
              backgroundColor: Colors.white,
              scrollable: true,
              actionsPadding: const EdgeInsets.all(5),
              titlePadding: EdgeInsets.zero,
              title: null,
              content: Container(
                  height: 550,
                  width: 400,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7)),
                  ),
                  child: Transfer(selectedInboxItem: currentItem, transferCallback: callback)),
              actions: null);
        });
  }

  static showProxyDialog(BuildContext context, Function? callback) {
    //String comment = '';
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              // shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
              contentPadding: EdgeInsets.zero,
              // backgroundColor: Colors.white,
              scrollable: true,
              actionsPadding: const EdgeInsets.all(5),
              titlePadding: EdgeInsets.zero,
              title: null,
              content: Container(
                  height: 400,
                  width: 400,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                  ),
                  child: ProxyUser(proxyCallback: callback)),
              actions: null);
        });
  }

  static showAnnouncementsDialog(BuildContext context) {
    //String comment = '';
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
              contentPadding: EdgeInsets.zero,
              backgroundColor: Colors.white,
              scrollable: true,
              actionsPadding: const EdgeInsets.all(5),
              titlePadding: EdgeInsets.zero,
              title: null,
              content: Container(
                  height: AppHelper.isMobileDevice(context) ? 320 : 500,
                  width: AppHelper.isMobileDevice(context) ? 350 : 500,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7)),
                  ),
                  child: const Announcements()),
              actions: null);
        });
  }
}
