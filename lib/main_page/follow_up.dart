import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:tawasol/app_models/app_view_models/db_entities/followup_ou.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/followup_user.dart';
import 'package:tawasol/app_models/service_models/service_handler.dart';
import 'package:tawasol/custom_controls/dropdown.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../app_models/app_utilities/app_helper.dart';
import '../app_models/app_utilities/app_routes.dart';
import '../app_models/app_view_models/db_entities/app_user.dart';
import '../app_models/app_view_models/db_entities/inbox_Item.dart';
import '../app_models/app_view_models/view_document_model.dart';
import '../app_models/service_models/service_urls.dart';
import '../custom_controls/custom_dialog.dart';
import '../open_document_page/view_document.dart';
import '../theme/theme_provider.dart';

class Followup extends StatefulWidget {
  const Followup({super.key});

  @override
  State<Followup> createState() => _FollowupState();
}

class _FollowupState extends State<Followup> {
  FollowupOu? _selectedOu;
  FollowupUser? _selectFollowupUser;
  List<InboxItem> inboxItems = [];

  void refreshEmployeeInbox() {
    setState(() {});
  }

  void onInboxItemTapped(BuildContext ctx, InboxItem item, int itemIndex) async {
    AppHelper.showLoaderDialog(ctx);
    if (!item.isOpen) {
      await ServiceHandler.markItemAsRead(item.wobNumber);
      inboxItems.elementAt(itemIndex).isOpen = true;
      setState(() {});
    }
    ViewDocumentModel viewDocModel = await ServiceHandler.getDocumentContentWithLinks(vsId: item.vsID, wobNumber: item.wobNumber, docClass: item.docClassId.toString());
    AppHelper.hideLoader(ctx);
    if (viewDocModel.docContent.isEmpty) {
      await AppHelper.showCustomAlertDialog(context, null, AppLocalizations.of(context)!.errorMessage, AppLocalizations.of(context)!.close, null);
    } else {
      Routes.moveViewDocument(
        context: context,
        docItem: item,
        linkedDocument: null,
        viewDocModel: viewDocModel,
        isFromTransfer: true,
        onTransferCallback: refreshEmployeeInbox,
      );
      // Navigator.of(ctx).push(MaterialPageRoute(
      //     builder: (context) => ViewDocument(
      //       currentItem: item,
      //       viewDocModel: viewDocModel,
      //       isFromTransfer: true,onTransferCallback:refreshEmployeeInbox,
      //     )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Scaffold(
        // backgroundColor: Colors.white,
        //backgroundColor: AppHelper.myColor("#f4f4f4"),
        body: Column(
          children: [
            Container(
              // padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: AppHelper.isMobileDevice(context) ? 15 : 30),
              padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 0),
              child: Dropdown(
                isLabel: true,
                listItemType: FollowupOu,
                // isShowBorder: false,
                isShowBorder: true,
                selectedValue: _selectedOu,
                listItemBinding: ServiceHandler.getFollowupOrTransferOUs,
                isValidationRequired: true,
                labelText: AppLocalizations.of(context)!.selectOU,
                isShowTopLabel: false,
                isSearchEnabled: true,
                prefixIconData: Icons.account_balance_outlined,
                onDropdownChange: (dynamic item) {
                  setState(() {
                    _selectedOu = item;
                    _selectFollowupUser = null;
                  });
                },
              ),
            ),
            const Divider(
              thickness: 0.2,
              color: Colors.grey,
            ),
            Container(
              // color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.black,
              padding: EdgeInsets.only(left: 10, right: 10, bottom: AppHelper.isMobileDevice(context) ? 15 : 30),
              child: Dropdown(
                isLabel: true,
                listItemType: FollowupUser,
                isShowBorder: true,
                selectedValue: _selectFollowupUser,
                isShowTopLabel: false,
                listItemBinding: () {
                  return ServiceHandler.getFollowupOrTransferUsers(_selectedOu!.id);
                },
                isValidationRequired: true,
                labelText: AppLocalizations.of(context)!.selectOuUser,
                onDropdownChange: (dynamic item) {
                  setState(() {
                    _selectFollowupUser = item;
                  });
                },
                isSearchEnabled: true,
                isDropdownEnabled: _selectedOu != null,
                prefixIconData: Icons.person_2_outlined,
              ),
            ),
            if (_selectFollowupUser != null)
              Expanded(
                child: FutureBuilder<List<InboxItem>>(
                    future: ServiceHandler.getFollowupUserItems(_selectedOu!.id, _selectFollowupUser!.domainName, _selectedOu!.securityLevels),
                    builder: (BuildContext context, AsyncSnapshot<List<InboxItem>> snapshot) {
                      if (!snapshot.hasData) {
                        // while data is loading:
                        return Center(
                          child: CupertinoActivityIndicator(
                            color: Theme.of(context).colorScheme.primary,
                            animating: true,
                            radius: 15,
                          ),
                        );
                      } else {
                        inboxItems = snapshot.data!;
                        if (inboxItems.isEmpty) {
                          return Center(
                            child: Text(
                              AppLocalizations.of(context)!.noRecordFound,
                              // style: TextStyle(color: ThemeProvider.isDarkMode ? Colors.white : Colors.grey.shade700, fontSize: 18),
                              style: TextStyle(color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.grey.shade700, fontSize: 18),
                            ),
                          );
                        } else {
                          return Container(
                            color: Colors.white, //AppHelper.myColor("#f4f4f4"),
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text(
                                    AppLocalizations.of(context)!.docCount + inboxItems.length.toString(),
                                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                                  ),
                                ),
                                Divider(
                                  color: Colors.grey.shade300,
                                  height: 0.5,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Expanded(
                                  child: ListView.separated(
                                    separatorBuilder: (context, index) {
                                      return Divider(
                                        height: 0.3,
                                        color: Colors.grey.shade300,
                                      );
                                      //return const SizedBox.shrink();
                                      // return const SizedBox(
                                      //   height: 20,
                                      // );
                                    },
                                    itemCount: snapshot.data!.length,
                                    // physics: const AlwaysScrollableScrollPhysics(),
                                    shrinkWrap: false,
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      InboxItem currentInboxItem = inboxItems[index];
                                      return Container(
                                        // margin: const EdgeInsets.symmetric(horizontal: 5),
                                        color: ThemeProvider.isDarkModeCheck() ? Colors.black : Colors.white,
                                        child: Slidable(
                                          closeOnScroll: true,
                                          enabled: false,
                                          startActionPane: ActionPane(
                                            dragDismissible: false,
                                            extentRatio: AppHelper.isMobileDevice(context) ? 0.30 : 0.20,
                                            motion: const StretchMotion(),
                                            children: [
                                              SlidableAction(
                                                onPressed: (context) {
                                                  CustomDialog.showTransferDialog(context, currentInboxItem, refreshEmployeeInbox);
                                                },
                                                // backgroundColor: const Color(0xFF0392CF),
                                                backgroundColor: AppHelper.myColor('#0278AB'),
                                                foregroundColor: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: AppHelper.isCurrentArabic ? const Radius.circular(0) : const Radius.circular(10),
                                                  topRight: AppHelper.isCurrentArabic ? const Radius.circular(10) : const Radius.circular(0),
                                                  bottomRight: AppHelper.isCurrentArabic ? const Radius.circular(10) : const Radius.circular(0),
                                                  bottomLeft: AppHelper.isCurrentArabic ? const Radius.circular(0) : const Radius.circular(10),
                                                ),
                                                icon: CupertinoIcons.arrow_branch,
                                                padding: EdgeInsets.zero,
                                                label: AppLocalizations.of(context)!.transfer,
                                              ),
                                            ],
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              onInboxItemTapped(context, currentInboxItem, index);
                                            },
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
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
                                                            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 20),
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
                                                                  fontSize: 18,
                                                                  // color: Theme.of(context).colorScheme.primary,
                                                                  // color: ThemeProvider.isDarkMode ? Colors.white : Colors.grey.shade700,
                                                                  color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.grey.shade700,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                                            child: Text(
                                                              AppHelper.getDocumentType(docType: currentInboxItem.docClassId, context: context, needLocal: true),
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.w500,
                                                                color: ThemeProvider.isDarkModeCheck() ? Colors.white70 : Theme.of(context).colorScheme.primary,
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
                                                              currentInboxItem.senderOuName,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                fontSize: 17.0,
                                                                // color: ThemeProvider.isDarkMode ? Colors.white : Colors.grey.shade700,
                                                                color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.grey.shade700,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                                            child: GestureDetector(
                                                              onTap: () {
                                                                CustomDialog.showDocHistoryDialog(context, currentInboxItem.vsID, currentInboxItem.docSubject);
                                                              },
                                                              child: Image(
                                                                image: const AssetImage("assets/images/doc_history.png"),
                                                                height: 32,
                                                                width: 32,
                                                                color: Theme.of(context).colorScheme.primary,
                                                              ),
                                                            ),
                                                          )
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
                                                          //
                                                          // const SizedBox(
                                                          //   width: 5,
                                                          // ),
                                                          Expanded(
                                                            child: Text(
                                                              currentInboxItem.actionName,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                fontSize: 17.0,
                                                                // color: ThemeProvider.isDarkMode ? Colors.white : Colors.grey.shade600,
                                                                color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.grey.shade600,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                            child: Text(
                                                              intl.DateFormat().addPattern(AppDefaults.dateFormat).format(currentInboxItem.receivedDate),
                                                              textDirection: TextDirection.ltr,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: 'Arial',
                                                                locale: const Locale('ar'),
                                                                // color: ThemeProvider.isDarkMode ? Colors.white70 : Colors.grey.shade600,
                                                                color: ThemeProvider.isDarkModeCheck() ? Colors.white70 : Colors.grey.shade600,
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
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    }),
              )
          ],
        ),
      ),
    );
  }
}
