import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/sent_Item.dart';
import 'package:tawasol/app_models/app_view_models/view_document_model.dart';
import 'package:tawasol/app_models/service_models/service_handler.dart';
import '../app_models/app_utilities/app_helper.dart';
import '../app_models/app_utilities/app_routes.dart';
import '../app_models/service_models/service_urls.dart';
import '../custom_controls/custom_dialog.dart';
import '../custom_controls/expandableDialog.dart';
import '../custom_controls/slide_action.dart';
import '../open_document_page/view_document.dart';
import '../theme/theme_provider.dart';

class SentItemView extends StatefulWidget {
  const SentItemView({super.key});

  @override
  State<SentItemView> createState() => _SentItemState();
}

List<SentItem> sentItems = [];

class _SentItemState extends State<SentItemView> {
  Future<List<SentItem>> getSentItems() async {
    return await ServiceHandler.getSentItems();
  }

  Future<void> pullRefresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var mqContext = MediaQuery.of(context);
    var size = mqContext.size;

    var mHeight = size.height - AppBar().preferredSize.height - mqContext.padding.top - mqContext.padding.bottom;
    var mWidth = size.width;

    bool isPortrait = mqContext.orientation == Orientation.portrait;

    var lang = AppLocalizations.of(context)!;

    void onSentItemTapped(BuildContext ctx, SentItem item, int itemIndex) async {
      AppHelper.showLoaderDialog(ctx);

      ViewDocumentModel viewDocModel = await ServiceHandler.getDocumentContentWithLinks(vsId: item.vsID, docClass: item.docClassId.toString());
      AppHelper.hideLoader(ctx);

      if (viewDocModel.docContent.isEmpty) {
        // ignore: use_build_context_synchronously
        await AppHelper.showCustomAlertDialog(
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
        Routes.moveViewDocument(context: context, linkedDocument: null, docItem: item, viewDocModel: viewDocModel);
      }

      // Navigator.of(ctx).push(MaterialPageRoute(
      //     builder: (context) => ViewDocument(
      //           currentItem: item,
      //           viewDocModel: viewDocModel
      //
      //         )));
    }

    return Scaffold(
        // backgroundColor: Colors.white,//AppHelper.myColor("#f4f4f4"),
        body: RefreshIndicator(
      onRefresh: pullRefresh,
      child: FutureBuilder<List<SentItem>>(
          future: getSentItems(),
          builder: (BuildContext context, AsyncSnapshot<List<SentItem>> snapshot) {
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
              sentItems = snapshot.data!;
              if (sentItems.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context)!.noRecordFound,
                    // style: TextStyle(color: ThemeProvider.isDarkMode ? Colors.white : Colors.grey.shade700, fontSize: 18),
                    style: TextStyle(color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.grey.shade700, fontSize: 18),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(top: 5.0, right: 0, left: 0, bottom: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          AppLocalizations.of(context)!.docCount + sentItems.length.toString(),
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
                          itemCount: snapshot.data!.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          separatorBuilder: (context, index) {
                            //return const SizedBox.shrink();
                            return Divider(
                              height: 0.3,
                              color: Colors.grey.shade300,
                            );
                          },
                          itemBuilder: (context, index) {
                            SentItem currentSentItem = sentItems[index];
                            return Slidable(
                              closeOnScroll: true,
                              enabled: currentSentItem.docSerial.isNotEmpty,
                              startActionPane: ActionPane(
                                dragDismissible: false,
                                extentRatio: AppHelper.isMobileDevice(context) ? 0.30 : 0.25,
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
                                      backgroundColor: AppHelper.myColor("#1054b9"),
                                      onPressed: (context) {
                                        // Routes.moveMultiSend(
                                        //   context: context,
                                        //   selectedItems: [currentSentItem],
                                        // );
                                        Routes.moveMultiSend2(
                                          ctx: context,
                                          selectedItems: [currentSentItem],
                                          rWdt: mWidth,
                                        );
                                      },
                                      child: SlideAction(
                                        imageName: "multi_send_shortcut_new",
                                        actionName: AppLocalizations.of(context)!.multiSend,
                                      )),
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
                                  onSentItemTapped(context, currentSentItem, index);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3),
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
                                            currentSentItem.receiverName,
                                            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 20),
                                          ),
                                          Spacer(),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Text(
                                              AppHelper.getDocumentType(docType: currentSentItem.docClassId, context: context, needLocal: true),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          ),
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
                                              message: currentSentItem.docSubject.toUpperCase(),
                                              child: Text(
                                                currentSentItem.docSubject.toUpperCase(),
                                                // "",
                                                maxLines: 10,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 18, color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: GestureDetector(
                                              onTap: () {
                                                CustomDialog.showDocHistoryDialog(context, currentSentItem.vsID, currentSentItem.docSubject);
                                              },
                                              child: Image(
                                                image: const AssetImage("assets/images/doc_history.png"),
                                                height: 32,
                                                width: 32,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          )
                                          // Padding(
                                          //   padding: const EdgeInsets.symmetric(horizontal: 10),
                                          //   child: Text(
                                          //     AppHelper.getDocumentType(docType: currentSentItem.docClassId, context: context, needLocal: true),
                                          //     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                      // Row(
                                      // children: <Widget>[
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
                                      //===================================Department name=============================
                                      // Expanded(
                                      //   child: Text(
                                      //     currentSentItem.receiverOuName,
                                      //     // "",
                                      //     overflow: TextOverflow.ellipsis,
                                      //     style: TextStyle(fontSize: 17.0, color: Colors.grey.shade700),
                                      //   ),
                                      // ),

                                      //   ],
                                      // ),
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
                                              currentSentItem.actionName,
                                              overflow: TextOverflow.ellipsis,
                                              // style: TextStyle(fontSize: 17.0, color: ThemeProvider.isDarkMode ? Colors.white70 : Colors.grey.shade700),
                                              style: TextStyle(fontSize: 17.0, color: ThemeProvider.isDarkModeCheck() ? Colors.white70 : Colors.grey.shade700),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                            child: Text(
                                              intl.DateFormat().addPattern(AppDefaults.dateFormat).format(currentSentItem.actionDate),
                                              // "",
                                              textDirection: TextDirection.ltr,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 14, fontFamily: 'Arial', locale: const Locale('ar'), color: ThemeProvider.isDarkModeCheck() ? Colors.white70 : Colors.grey.shade700),
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
    ));
  }
}
