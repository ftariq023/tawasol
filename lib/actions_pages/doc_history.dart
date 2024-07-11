import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readmore/readmore.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/app_models/service_models/service_handler.dart';
import 'package:tawasol/custom_controls/popup_title.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tawasol/theme/theme_provider.dart';

import '../app_models/app_view_models/db_entities/inbox_Item.dart';
import '../app_models/app_view_models/document_log.dart';
import '../app_models/service_models/service_urls.dart';

class DocumentHistory extends StatelessWidget {
  DocumentHistory({super.key, required this.vsId, required this.subject});

  final String vsId;
  final String subject;
  final _scrollController = ScrollController();

  Future<List<DocumentLog>> getDocumentLogs() async {
    return await ServiceHandler.getDocumentHistory(docVsId: vsId, isFullHistory: false);
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;
    var commonMargin = const EdgeInsets.symmetric(horizontal: 10, vertical: 0);

    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: _scrollDown,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0.5,
        child: const Icon(
          Icons.arrow_downward,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size(650, 50),
        child: PopupTitle(
          title: lang.documentHistory,
        ),
      ),
      body: FutureBuilder<List<DocumentLog>>(
        future: getDocumentLogs(),
        builder: (BuildContext context, AsyncSnapshot<List<DocumentLog>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Container(
                // color: ThemeProvider.isDarkMode ? Colors.black : Colors.white,
                color: ThemeProvider.isDarkModeCheck() ? Colors.black : Colors.white,
                height: MediaQuery.of(context).size.height - 250,
                width: MediaQuery.of(context).size.width - (AppHelper.isMobileDevice(context) ? 30 : 100),
                child: CupertinoActivityIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  animating: true,
                  radius: 15,
                ),
              ),
            );
          } else {
            return Container(
              padding: const EdgeInsets.only(bottom: 60),
              height: MediaQuery.of(context).size.height - 250,
              width: MediaQuery.of(context).size.width - (AppHelper.isMobileDevice(context) ? 30 : 100),
              // color: ThemeProvider.isDarkMode ? Colors.black : Colors.white,
              color: ThemeProvider.isDarkModeCheck() ? Colors.black : Colors.white,
              child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    DocumentLog docLog = snapshot.data![index];
                    return Container(
                      // color: ThemeProvider.isDarkMode ? Colors.black : Colors.white,
                      color: ThemeProvider.isDarkModeCheck() ? Colors.black : Colors.white,
                      child: Column(
                        children: [
                          //=======Recipient Row===========
                          Container(
                            margin: commonMargin,
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "${lang.recipient}: ",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                                // const SizedBox(
                                //   width: 5,
                                // ),
                                Expanded(
                                  child: Text(
                                    // reciverStatic,
                                    docLog.receiver.isNotEmpty ? docLog.receiver : "-",
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                )
                              ],
                            ),
                          ),
                          //=======Sender Row===========
                          if (docLog.sender.isNotEmpty)
                            Container(
                              margin: commonMargin,
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    lang.sender + ": ",
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                    ),
                                  ),
                                  // const SizedBox(
                                  //   width: 5,
                                  // ),
                                  Expanded(
                                    child: Text(
                                      docLog.sender.isNotEmpty ? docLog.sender : "-",
                                      maxLines: 10,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          //==========Comments==========
                          // if(docLog.comment.isNotEmpty)
                          Container(
                            margin: commonMargin,
                            child: Row(
                              children: <Widget>[
                                Text(
                                  lang.comment + ":",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                docLog.comment.isEmpty
                                    ? const Expanded(
                                        child: Text(
                                          "-",
                                          maxLines: 2,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      )
                                    : Expanded(
                                        child: ReadMoreText(
                                          docLog.comment,
                                          trimMode: TrimMode.Line,
                                          style: const TextStyle(fontSize: 16),
                                          moreStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                          lessStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                          trimCollapsedText: '  ${lang.showMore}  ',
                                          trimExpandedText: '  ${lang.showLess}  ',
                                        ),
                                      )
                                // Expanded(
                                //         child: Text(
                                //           docLog.comment,
                                //           maxLines: 50,
                                //           style: const TextStyle(
                                //               fontSize: 16),
                                //         ),
                                //       )
                              ],
                            ),
                          ),
                          //===========Action and Date (ROW)===========
                          if (docLog.actionAndDate.isNotEmpty)
                            Container(
                              margin: commonMargin,
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    lang.action + ":",
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Text(
                                      docLog.actionName,
                                      maxLines: 10,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Text(
                                    docLog.actionDate,
                                    maxLines: 2,
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          //===========Divider after each WF===========
                          Divider(
                            height: 20,
                            color: Colors.grey[300],
                            endIndent: 11,
                          ),
                        ],
                      ),
                    );
                  }),
            );
          }
        },
      ),
    );
    // return Scaffold(
    //   backgroundColor: Colors.transparent,
    //   appBar: PreferredSize(
    //     preferredSize: const Size(650, 50),
    //     child: PopupTitle(
    //       title: lang.documentHistory,
    //     ),
    //   ),
    //   body: FutureBuilder<List<DocumentLog>>(
    //     future: getDocumentLogs(),
    //     builder: (BuildContext context, AsyncSnapshot<List<DocumentLog>> snapshot) {
    //       if (!snapshot.hasData) {
    //         return Center(
    //           child: CupertinoActivityIndicator(
    //             color: Theme.of(context).colorScheme.primary,
    //             animating: true,
    //             radius: 15,
    //           ),
    //         );
    //       } else {
    //         // CheckboxListTile(
    //         //     value: true,
    //         //     title: const Text('Full History'),
    //         //     onChanged: (value) {});
    //         return Container(
    //           color: AppHelper.myColor("#f4f4f4"),
    //           padding: const EdgeInsets.symmetric(vertical: 8.0),
    //           child: ListView.builder(
    //               itemCount: snapshot.data!.length,
    //               physics: const AlwaysScrollableScrollPhysics(),
    //               shrinkWrap: true,
    //               controller: _scrollController,
    //               padding: EdgeInsets.zero,
    //               itemBuilder: (context, index) {
    //                 DocumentLog docLog = snapshot.data![index];
    //                 return Container(
    //                   margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
    //                   color: Colors.transparent,
    //                   child: Card(
    //                     shape: RoundedRectangleBorder(side: BorderSide(color: AppHelper.myColor("#d4d4d4")), borderRadius: const BorderRadius.all(Radius.circular(8))),
    //                     shadowColor: Colors.black,
    //                     color: Colors.white,
    //                     surfaceTintColor: Colors.white,
    //                     elevation: 0,
    //                     borderOnForeground: false,
    //                     child: Padding(
    //                       padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
    //                       child: Column(
    //                         children: <Widget>[
    //                           if (docLog.sender.isNotEmpty)
    //                             Row(
    //                               children: <Widget>[
    //                                 Image.asset(
    //                                   "assets/images/sender_history.png",
    //                                   height: 30,
    //                                   width: 30,
    //                                   color: Theme.of(context).colorScheme.primary,
    //                                 ),
    //                                 // Icon(
    //                                 //   Icons.send_outlined,
    //                                 //   textDirection: AppHelper.isCurrentArabic
    //                                 //       ? TextDirection.ltr
    //                                 //       : TextDirection.rtl,
    //                                 //   color:
    //                                 //       Theme.of(context).colorScheme.primary,
    //                                 // ),
    //                                 const SizedBox(
    //                                   width: 5,
    //                                 ),
    //                                 Expanded(
    //                                   child: Text(
    //                                     docLog.sender,
    //                                     maxLines: 2,
    //                                     style: TextStyle(color: Theme.of(context).colorScheme.primary, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w500, fontSize: 16),
    //                                   ),
    //                                 )
    //                               ],
    //                             ),
    //                           const SizedBox(
    //                             height: 5,
    //                           ),
    //                           if (docLog.receiver.isNotEmpty)
    //                             Row(
    //                               children: <Widget>[
    //                                 Image.asset(
    //                                   "assets/images/receiver_history.png",
    //                                   height: 30,
    //                                   width: 30,
    //                                   color: Theme.of(context).colorScheme.primary,
    //                                 ),
    //                                 const SizedBox(
    //                                   width: 5,
    //                                 ),
    //                                 Expanded(
    //                                   child: Text(
    //                                     docLog.receiver,
    //                                     maxLines: 2,
    //                                     overflow: TextOverflow.ellipsis,
    //                                     style: const TextStyle(fontSize: 16),
    //                                   ),
    //                                 )
    //                               ],
    //                             ),
    //                           const SizedBox(
    //                             height: 5,
    //                           ),
    //                           if (docLog.actionAndDate.isNotEmpty)
    //                             Row(
    //                               children: <Widget>[
    //                                 Image.asset(
    //                                   "assets/images/date_history.png",
    //                                   height: 30,
    //                                   width: 30,
    //                                   color: Theme.of(context).colorScheme.primary,
    //                                 ),
    //                                 const SizedBox(
    //                                   width: 5,
    //                                 ),
    //                                 Expanded(
    //                                   child: Text(
    //                                     docLog.actionName,
    //                                     maxLines: 10,
    //                                     style: TextStyle(color: Theme.of(context).colorScheme.primary, overflow: TextOverflow.ellipsis, fontSize: 16),
    //                                   ),
    //                                 ),
    //                                 Padding(
    //                                   padding: const EdgeInsets.symmetric(horizontal: 10.0),
    //                                   child: Text(
    //                                     docLog.actionDate,
    //                                     maxLines: 2,
    //                                     textDirection: TextDirection.ltr,
    //                                     style: TextStyle(color: Theme.of(context).colorScheme.primary, overflow: TextOverflow.ellipsis, fontFamily: 'Arial', fontSize: 14),
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                           const SizedBox(
    //                             height: 5,
    //                           ),
    //                           if (docLog.comment.isNotEmpty)
    //                             Row(
    //                               children: <Widget>[
    //                                 Icon(
    //                                   Icons.comment_outlined,
    //                                   color: Theme.of(context).colorScheme.primary,
    //                                 ),
    //                                 const SizedBox(
    //                                   width: 5,
    //                                 ),
    //                                 Expanded(
    //                                   child: Tooltip(
    //                                     message: docLog.comment,
    //                                     child: Text(
    //                                       docLog.comment,
    //                                       maxLines: 4,
    //                                       style: const TextStyle(overflow: TextOverflow.ellipsis, fontSize: 16),
    //                                     ),
    //                                   ),
    //                                 )
    //                               ],
    //                             ),
    //                           const SizedBox.shrink()
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                 );
    //               }),
    //         );
    //       }
    //     },
    //   ),

    // );
  }
}
