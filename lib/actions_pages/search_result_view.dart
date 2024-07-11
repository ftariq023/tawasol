import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:tawasol/theme/theme_provider.dart';
import '../app_models/app_utilities/app_helper.dart';
import '../app_models/app_utilities/app_routes.dart';
import '../app_models/app_view_models/db_entities/search_result_item.dart';
import '../app_models/app_view_models/view_document_model.dart';
import '../app_models/service_models/service_handler.dart';
import '../app_models/service_models/service_urls.dart';
import '../custom_controls/custom_dialog.dart';
import '../custom_controls/slide_action.dart';
import '../open_document_page/view_document.dart';

class SearchResultView extends StatefulWidget {
  const SearchResultView({super.key, required this.searchResultItems, required this.isShowSites});

  final List<SearchResultItem> searchResultItems;
  final bool isShowSites;

  @override
  State<SearchResultView> createState() => _SearchResultViewState();
}

class _SearchResultViewState extends State<SearchResultView> {
  void onSearchResultItemTapped(BuildContext ctx, SearchResultItem item, int itemIndex) async {
    AppHelper.showLoaderDialog(ctx);

    ViewDocumentModel viewDocModel = await ServiceHandler.getDocumentContentWithLinks(vsId: item.vsID, docClass: AppHelper.getDocumentClassIdByName(item.classDescription).toString());
    AppHelper.hideLoader(ctx);

    Routes.moveViewDocument(context: context, linkedDocument: null, docItem: item, viewDocModel: viewDocModel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: AppHelper.myColor("#f4f4f4"),
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, 80),
          child: AppBar(
            // backgroundColor: AppHelper.myColor("#f4f4f4"),
            title: Text(
              AppLocalizations.of(context)!.searchResults,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white, overflow: TextOverflow.ellipsis),
            ),
            // flexibleSpace: Container(
            //   decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/header_moi.png'), fit: BoxFit.fill)),
            // ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                // borderRadius: BorderRadius.only(
                //   bottomLeft: Radius.circular(20),
                //   // Adjust the border radius for left bottom
                //   bottomRight: Radius.circular(20), // Adjust the border radius for right bottom
                // ),
              ),
            ),
            // backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            leadingWidth: 50,
            leading: const Icon(
              Icons.search_outlined,
              color: Colors.white,
              size: 32,
            ),
            titleSpacing: 5,
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                iconSize: 32,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 15.0, right: 0, left: 0, bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  AppLocalizations.of(context)!.docCount + widget.searchResultItems.length.toString(),
                  // style: TextStyle(fontSize: 16, color: ThemeProvider.isDarkMode ? Colors.white : Colors.grey.shade600),
                  style: TextStyle(fontSize: 16, color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.grey.shade600),
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
                    //return const SizedBox.shrink();
                    return Divider(
                      height: 0.3,
                      color: Colors.grey.shade300,
                    );
                  },
                  itemCount: widget.searchResultItems.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    SearchResultItem currentSearchResultItem = widget.searchResultItems[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Slidable(
                        closeOnScroll: true,
                        // The start action pane is the one at the left or the top side.
                        // startActionPane: ActionPane(
                        //   extentRatio: 0.40,
                        //   // A motion is a widget used to control how the pane animates.
                        //   motion: const ScrollMotion(),
                        //
                        //   // A pane can dismiss the Slidable.
                        //
                        //   // All actions are defined in the children parameter.
                        //   children: [
                        //     // A SlidableAction can have an icon and/or a label.
                        //
                        //     SlidableAction(
                        //       onPressed: doNothing,
                        //       backgroundColor: const Color(0xFF21B7CA),
                        //       foregroundColor: Colors.white,
                        //       icon: Icons.mark_email_read,
                        //       label: 'Read/UnRead',
                        //     ),
                        //   ],
                        // ),
                        // The end action pane is the one at the right or the bottom side.
                        startActionPane: ActionPane(
                          dragDismissible: false,
                          extentRatio: AppHelper.isMobileDevice(context) ? 0.50 : 0.35,
                          motion: const BehindMotion(),
                          children: [
                            CustomSlidableAction(
                                padding: EdgeInsets.zero,
                                borderRadius: BorderRadius.only(
                                  topLeft: AppHelper.isCurrentArabic ? const Radius.circular(0) : const Radius.circular(10),
                                  topRight: AppHelper.isCurrentArabic ? const Radius.circular(10) : const Radius.circular(0),
                                  bottomRight: AppHelper.isCurrentArabic ? const Radius.circular(10) : const Radius.circular(0),
                                  bottomLeft: AppHelper.isCurrentArabic ? const Radius.circular(0) : const Radius.circular(10),
                                ),
                                backgroundColor: AppHelper.myColor("#0278AB"),
                                onPressed: (context) {
                                  Routes.moveSend(context: context, selectedItem: currentSearchResultItem);
                                },
                                child: SlideAction(
                                  imageName: "send_shortcut_new",
                                  actionName: AppLocalizations.of(context)!.send,
                                )),
                            if (currentSearchResultItem.docSerial.isNotEmpty)
                              CustomSlidableAction(
                                  padding: EdgeInsets.zero,
                                  //  backgroundColor: Colors.blue.shade900,
                                  backgroundColor: AppHelper.myColor("#1054b9"),
                                  onPressed: (context) {
                                    Routes.moveMultiSend(
                                      context: context,
                                      selectedItems: [currentSearchResultItem],
                                    );
                                  },
                                  child: SlideAction(imageName: "multi_send_shortcut_new", actionName: AppLocalizations.of(context)!.multiSend)),

                            // SlidableAction(
                            //   onPressed: (context) {
                            //     Routes.moveSend(
                            //         context: context,
                            //         selectedItem: currentInboxItem);
                            //   },
                            //   // backgroundColor: const Color(0xFF0392CF),
                            //   backgroundColor:
                            //       AppHelper.myColor('#0278AB'),
                            //   foregroundColor: Colors.white,
                            //   borderRadius: BorderRadius.only(
                            //     topLeft: AppHelper.isCurrentArabic
                            //         ? const Radius.circular(0)
                            //         : const Radius.circular(10),
                            //     topRight: AppHelper.isCurrentArabic
                            //         ? const Radius.circular(10)
                            //         : const Radius.circular(0),
                            //     bottomRight: AppHelper.isCurrentArabic
                            //         ? const Radius.circular(10)
                            //         : const Radius.circular(0),
                            //     bottomLeft: AppHelper.isCurrentArabic
                            //         ? const Radius.circular(0)
                            //         : const Radius.circular(10),
                            //   ),
                            //   icon: Icons.send_outlined,
                            //   padding: EdgeInsets.zero,
                            //   label: AppLocalizations.of(context)!.send,
                            // ),
                            // if (currentInboxItem.isApproveEnabled)
                            //   SlidableAction(
                            //     // An action can be bigger than the others.
                            //     onPressed: (context) {
                            //       CustomDialog.showApproveDialog(
                            //           context, currentInboxItem);
                            //       //  Routes.moveApprove(context, currentInboxItem);
                            //     },
                            //     backgroundColor:
                            //         AppHelper.myColor('#419644'),
                            //     //backgroundColor: Colors.green,
                            //     foregroundColor: Colors.white,
                            //     padding: EdgeInsets.zero,
                            //     //  borderRadius: BorderRadius.circular(5),
                            //     icon: Icons.verified_outlined,
                            //     label:
                            //         AppLocalizations.of(context)!.approve,
                            //   ),
                            // if (!currentInboxItem.isApproveEnabled)
                            //   SlidableAction(
                            //     onPressed: (context) {
                            //       Routes.moveMultiSend(
                            //           context: context,
                            //           selectedItem: currentInboxItem);
                            //     },
                            //     padding: EdgeInsets.zero,
                            //     // backgroundColor: const Color(0xFF0392CF),
                            //     backgroundColor:
                            //         currentInboxItem.isApproveEnabled
                            //             ? AppHelper.myColor('#0278AB')
                            //             : Colors.blue.shade900,
                            //     foregroundColor: Colors.white,
                            //
                            //     icon: Icons.double_arrow_outlined,
                            //
                            //     //  borderRadius: BorderRadius.circular(5),
                            //     label: AppLocalizations.of(context)!
                            //         .multiSend,
                            //   ),
                            // SlidableAction(
                            //   onPressed: (context) {
                            //     CustomDialog.showTerminateDialog(
                            //         context, currentInboxItem);
                            //   },
                            //   backgroundColor:
                            //       AppHelper.myColor('#BD332A'),
                            //   padding: EdgeInsets.zero,
                            //   // backgroundColor: Colors.red,
                            //   foregroundColor: Colors.white,
                            //   icon: Icons.indeterminate_check_box_rounded,
                            //   //  borderRadius: BorderRadius.circular(5),
                            //   label:
                            //       AppLocalizations.of(context)!.terminate,
                            // )
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            onSearchResultItemTapped(context, currentSearchResultItem, index);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3),
                            child: Column(
                              children: <Widget>[
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    // const Image(
                                    //   image: AssetImage(
                                    //       "assets/images/document_list_view_new.png"),
                                    //   height: 32,
                                    //   width: 32,
                                    // ),
                                    // const SizedBox(
                                    //   width: 5,
                                    // ),
                                    Expanded(
                                      child: Tooltip(
                                        message: currentSearchResultItem.docSubject.toUpperCase(),
                                        child: Text(
                                          currentSearchResultItem.docSubject.toUpperCase(),
                                          maxLines: 10,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 18,
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
                                        AppHelper.getDocumentType(docType: AppHelper.getDocumentClassIdByName(currentSearchResultItem.classDescription.toLowerCase()), context: context, needLocal: true),
                                        style: TextStyle(fontSize: 18, color: ThemeProvider.primaryColor, fontWeight: FontWeight.w500),
                                      ),
                                    ),
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
                                    //   color: Theme.of(context).colorScheme.primary,
                                    //   opacity: const AlwaysStoppedAnimation(.8),
                                    // ),
                                    //
                                    // const SizedBox(
                                    //   width: 5,
                                    // ),
                                    Expanded(
                                      child: Text(
                                        currentSearchResultItem.actionName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 17.0,
                                          // color: ThemeProvider.isDarkMode ? Colors.white : Colors.grey.shade600,
                                          color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: GestureDetector(
                                        onTap: () {
                                          CustomDialog.showDocHistoryDialog(context, currentSearchResultItem.vsID, currentSearchResultItem.docSubject);
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
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                        child: Text(
                                          intl.DateFormat().addPattern(AppDefaults.dateFormat).format(currentSearchResultItem.actionDate),
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
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
