// import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:tawasol/app_models/app_utilities/app_helper.dart';
// import 'package:tawasol/app_models/app_view_models/db_entities/user_comment.dart';
// import 'package:tawasol/custom_controls/my_button.dart';
// import 'package:tawasol/custom_controls/popup_title.dart';
// import 'package:tawasol/theme/theme_provider.dart';
// import '../app_models/app_utilities/app_routes.dart';
// import '../app_models/app_view_models/db_entities/inbox_Item.dart';
// import '../app_models/app_view_models/user_signature.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import '../app_models/service_models/service_handler.dart';

// class TerminateDocument extends StatelessWidget {
//   List selectedInboxItems;

//   TerminateDocument({
//     super.key,
//     required this.selectedInboxItems,
//   });

//   final terminateFormKey = GlobalKey<FormState>();
//   final TextEditingController userCommentController = TextEditingController();

//   Future<List<UserComment>> getUserComments() async {
//     return await ServiceHandler.getUserComments();
//   }

//   // Future onTerminatePressed(BuildContext context) async {
//   //   if (terminateFormKey.currentState!.validate()) {
//   //     AppHelper.showLoaderDialog(context);
//   //     bool isTerminated = await ServiceHandler.terminateDocument(selectedInboxItem.docClassId, selectedInboxItem.wobNumber, userCommentController.text);
//   //     AppHelper.hideLoader(context);

//   //     if (isTerminated) {
//   //       await AppHelper.showCustomAlertDialog(context, null, AppLocalizations.of(context)!.terminateSuccess, AppLocalizations.of(context)!.close, null);
//   //     } else {
//   //       await AppHelper.showCustomAlertDialog(context, null, AppLocalizations.of(context)!.errorMessage, AppLocalizations.of(context)!.close, null);
//   //       return;
//   //     }

//   //     if (isTerminated) {
//   //       Navigator.of(context).pop();
//   //       if (Navigator.of(context).canPop()) {
//   //         Navigator.of(context).pop();
//   //       }
//   //       Routes.moveDashboard(context);
//   //     }
//   //   }
//   // }

//   Future onTerminatePressed2(BuildContext context) async {
//     if (terminateFormKey.currentState!.validate()) {
//       AppHelper.showLoaderDialog(context);

//       List failedTerminantionSubjects = [];
//       for (var selectedInboxItem in selectedInboxItems) {
//         bool isTerminated = await ServiceHandler.terminateDocument(
//           selectedInboxItem.docClassId,
//           selectedInboxItem.wobNumber,
//           userCommentController.text,
//         );
//         if (!isTerminated) failedTerminantionSubjects.add(selectedInboxItem.docSubject);
//       }

//       AppHelper.hideLoader(context);

//       if (failedTerminantionSubjects.isEmpty) {
//         await AppHelper.showCustomAlertDialog(context, null, AppLocalizations.of(context)!.terminateSuccess, AppLocalizations.of(context)!.close, null);
//       } else {
//         String failedSubjects = "";
//         for (var subject in failedTerminantionSubjects) failedSubjects += subject + ", ";
//         failedSubjects = failedSubjects.substring(0, failedSubjects.length - 2);

//         await AppHelper.showCustomAlertDialog(
//           context,
//           null,
//           AppLocalizations.of(context)!.terminationFailedFor + ": " + failedSubjects,
//           AppLocalizations.of(context)!.close,
//           null,
//         );
//         // return;
//       }

//       // if (isTerminated) {
//       Navigator.of(context).pop();
//       if (Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }
//       Routes.moveDashboard(context);
//       // }
//     }
//   }

//   CustomPopupMenuController menuController = CustomPopupMenuController();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: ThemeProvider.isDarkMode ? Colors.black : Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(7), // Set the desired top-left border radius
//           topRight: Radius.circular(7), // Set the desired top-right border radius
//         ),
//       ),
//       //=====================================Body container==============================
//       child: Container(
//         child: Column(
//           children: [
//             //============================Header Container==============================
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.primary,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(7), // Set the desired top-left border radius
//                   topRight: Radius.circular(7), // Set the desired top-right border radius
//                 ),
//               ),
//               width: double.infinity,
//               child: Row(
//                 children: [
//                   Container(
//                     child: Center(
//                       child: Text(
//                         AppLocalizations.of(context)!.terminate,
//                         style: TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   Spacer(),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: Icon(
//                       Icons.close,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             //==============================Body=============================
//             Container(
//               alignment: Alignment.center,
//               child: FutureBuilder<List<UserComment>>(
//                   future: getUserComments(),
//                   builder: (BuildContext context, AsyncSnapshot<List<UserComment>> snapshot) {
//                     if (!snapshot.hasData) {
//                       // while data is loading:
//                       return Container(
//                         alignment: Alignment.center,
//                         child: Center(
//                           child: CupertinoActivityIndicator(
//                             color: Theme.of(context).colorScheme.primary,
//                             animating: true,
//                             radius: 15,
//                           ),
//                         ),
//                       );
//                     } else {
//                       return Form(
//                         key: terminateFormKey,
//                         child: Container(
//                           // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
//                           // color: AppHelper.myColor("#f4f4f4"),
//                           padding: const EdgeInsets.all(5),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               //==================================Commect Container===================================
//                               CustomPopupMenu(
//                                   pressType: PressType.singleClick,
//                                   arrowSize: 20,
//                                   showArrow: true,
//                                   barrierColor: Color.fromARGB(122, 0, 0, 0),
//                                   controller: menuController,
//                                   arrowColor: Theme.of(context).colorScheme.primary,
//                                   position: PreferredPosition.bottom,
//                                   verticalMargin: 0,
//                                   // horizontalMargin: 15,
//                                   child: Container(
//                                     // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
//                                     padding: EdgeInsets.only(top: 5, right: 5, left: 5),
//                                     child: Column(
//                                       children: [
//                                         Row(
//                                           children: [
//                                             Text(
//                                               AppLocalizations.of(context)!.selectComment,
//                                               textAlign: TextAlign.start,
//                                               style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 16),
//                                             ),
//                                             Spacer(),
//                                             Icon(
//                                               Icons.arrow_drop_down,
//                                               color: Theme.of(context).colorScheme.primary,
//                                             )
//                                           ],
//                                         ),
//                                         Container(
//                                           padding: EdgeInsets.only(top: 5, right: 5, left: 5),
//                                           child: Divider(
//                                             color: Theme.of(context).colorScheme.primary,
//                                             height: 0,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   menuBuilder: () {
//                                     return Container(
//                                       width: 300,
//                                       // margin: EdgeInsets.only(bottom: 10),
//                                       // height: 300,
//                                       // color: Theme.of(context).colorScheme.background,
//                                       decoration: BoxDecoration(
//                                         color: Theme.of(context).colorScheme.background,
//                                         borderRadius: BorderRadius.circular(7), // Set the desired border radius
//                                         border: Border.all(color: Theme.of(context).colorScheme.primary, width: 0.5), // Set the border color and width
//                                       ),
//                                       child: ListView.builder(
//                                         itemCount: snapshot.data!.length,
//                                         physics: const AlwaysScrollableScrollPhysics(),
//                                         shrinkWrap: true,
//                                         padding: EdgeInsets.only(top: 10),
//                                         itemBuilder: (context, index) {
//                                           UserComment userComment = snapshot.data![index];
//                                           return GestureDetector(
//                                             onTap: () {
//                                               menuController.hideMenu();
//                                               userCommentController.text = userComment.comment;
//                                             },
//                                             child: Container(
//                                               child: Column(
//                                                 children: [
//                                                   Padding(
//                                                     padding: const EdgeInsets.all(5.0),
//                                                     child: Text(userComment.shortComment, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
//                                                   ),
//                                                   Divider(
//                                                     color: Colors.grey,
//                                                     indent: 10,
//                                                     endIndent: 10,
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             // child: Card(
//                                             //   // shape: RoundedRectangleBorder(side: BorderSide(color: AppHelper.myColor("#d4d4d4")), borderRadius: const BorderRadius.all(Radius.circular(8))),
//                                             //   color: Colors.white,
//                                             //   elevation: 1,
//                                             //   child: Padding(
//                                             //     padding: const EdgeInsets.all(8.0),
//                                             //     child: Text(userComment.shortComment, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
//                                             //   ),
//                                             // ),
//                                           );
//                                         },
//                                       ),
//                                     );
//                                   }),
//                               // Container(
//                               //   // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
//                               //   padding: EdgeInsets.only(top: 5, right: 5, left: 5),
//                               //   child: Row(
//                               //     children: [
//                               //       Text(
//                               //         AppLocalizations.of(context)!.selectComment,
//                               //         textAlign: TextAlign.start,
//                               //         style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 16),
//                               //       ),
//                               //       Spacer(),
//                               //       Icon(
//                               //         Icons.arrow_drop_down,
//                               //         color: Theme.of(context).colorScheme.primary,
//                               //       )
//                               //     ],
//                               //   ),
//                               // ),

//                               // Container(
//                               //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//                               //   color: AppHelper.myColor('#d4d4d4'),
//                               //   alignment: AppHelper.isCurrentArabic ? Alignment.centerRight : Alignment.centerLeft,
//                               //   child: Text(
//                               //     AppLocalizations.of(context)!.selectComment,
//                               //     // "",
//                               //     textAlign: TextAlign.start,
//                               //     style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 16),
//                               //   ),
//                               // ),
//                               //============================================List View Builder======================================
//                               // SizedBox(
//                               //   height: 180,
//                               //   child: ListView.builder(
//                               //     itemCount: snapshot.data!.length,
//                               //     physics: const AlwaysScrollableScrollPhysics(),
//                               //     shrinkWrap: true,
//                               //     padding: EdgeInsets.zero,
//                               //     itemBuilder: (context, index) {
//                               //       UserComment userComment = snapshot.data![index];
//                               //       return GestureDetector(
//                               //         onTap: () {
//                               //           userCommentController.text = userComment.comment;
//                               //         },
//                               //         child: Card(
//                               //           shape: RoundedRectangleBorder(side: BorderSide(color: AppHelper.myColor("#d4d4d4")), borderRadius: const BorderRadius.all(Radius.circular(8))),
//                               //           color: Colors.white,
//                               //           elevation: 0,
//                               //           child: Padding(
//                               //             padding: const EdgeInsets.all(8.0),
//                               //             child: Text(userComment.shortComment, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
//                               //           ),
//                               //         ),
//                               //       );
//                               //     },
//                               //   ),
//                               // ),
//                               //================================Text Form field with validation===================================
//                               Container(
//                                 padding: const EdgeInsets.all(8.0),
//                                 margin: const EdgeInsets.symmetric(horizontal: 5),
//                                 decoration: BoxDecoration(
//                                   borderRadius: const BorderRadius.all(Radius.circular(5)),
//                                   border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
//                                 ),
//                                 child: TextFormField(
//                                   style: TextStyle(color: Colors.black),
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return AppLocalizations.of(context)!.requireField;
//                                     } else {
//                                       return null;
//                                     }
//                                   },
//                                   controller: userCommentController,
//                                   maxLines: 3,
//                                   decoration: InputDecoration.collapsed(hintStyle: TextStyle(color: Colors.grey.shade400), hintText: AppLocalizations.of(context)!.writeComment),
//                                 ),
//                               ),
//                               // const SizedBox(height: 100),
//                               //=======================================Terminate button=====================================
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   MyButton(btnText: AppLocalizations.of(context)!.terminate, onTap: () => onTerminatePressed2(context)),
//                                   // const SizedBox(
//                                   //   width: 20,
//                                   // ),
//                                   // MyButton(
//                                   //   btnText: AppLocalizations.of(context)!.back,
//                                   //   textColor: AppHelper.myColor('#FFFFFF'),
//                                   //   backgroundColor: AppHelper.myColor("#757575"),
//                                   //   onTap: () => Navigator.of(context).pop(),
//                                   // )
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }
//                   }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/user_comment.dart';
import 'package:tawasol/custom_controls/my_button.dart';
import 'package:tawasol/custom_controls/popup_title.dart';
import 'package:tawasol/theme/theme_provider.dart';
import '../app_models/app_utilities/app_routes.dart';
import '../app_models/app_view_models/db_entities/inbox_Item.dart';
import '../app_models/app_view_models/user_signature.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_models/service_models/service_handler.dart';

class TerminateDocument extends StatelessWidget {
  List selectedInboxItems;

  TerminateDocument({
    super.key,
    required this.selectedInboxItems,
  });

  final terminateFormKey = GlobalKey<FormState>();
  final TextEditingController userCommentController = TextEditingController();

  CustomPopupMenuController menuController = CustomPopupMenuController();

  Future<List<UserComment>> getUserComments() async {
    return await ServiceHandler.getUserComments();
  }

  Future onTerminatePressed2(BuildContext context) async {
    if (terminateFormKey.currentState!.validate()) {
      AppHelper.showLoaderDialog(context);

      List failedTerminationSubjects = [];

      for (var selectedInboxItem in selectedInboxItems) {
        bool isTerminated = await ServiceHandler.terminateDocument(
          selectedInboxItem.docClassId,
          selectedInboxItem.wobNumber,
          userCommentController.text,
        );

        if (!isTerminated) failedTerminationSubjects.add(selectedInboxItem.docSubject);
      }

      AppHelper.hideLoader(context);

      if (failedTerminationSubjects.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.terminateSuccess)));

        // await AppHelper.showCustomAlertDialog(
        //     context,
        //     null,
        //     AppLocalizations.of(context)!.terminateSuccess,
        //     AppLocalizations.of(context)!.close,
        //     null);
      } else {
        String failedSubjects = "";
        for (var subject in failedTerminationSubjects) failedSubjects += subject + ", ";
        failedSubjects = failedSubjects.substring(0, failedSubjects.length - 2);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "${AppLocalizations.of(context)!.terminationFailedFor}: $failedSubjects",
        )));

        // await AppHelper.showCustomAlertDialog(
        //   context,
        //   null,
        //   AppLocalizations.of(context)!.terminationFailedFor +
        //       ": " +
        //       failedSubjects,
        //   AppLocalizations.of(context)!.close,
        //   null,
        // );
      }

      Navigator.of(context).pop();
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      Routes.moveDashboard(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color: ThemeProvider.isDarkMode ? Colors.black : Colors.white,
        color: ThemeProvider.isDarkModeCheck() ? Colors.black : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(7),
          topRight: Radius.circular(7),
        ),
      ),
      //===================================================Main Container=======================================
      child: Column(
        children: [
          //=============================================Header============================================
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            width: double.infinity,
            child: Row(
              children: [
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.terminate,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          //================================================Body==============================================
          Container(
            // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.red)),
            alignment: Alignment.center,
            child: FutureBuilder<List<UserComment>>(
              future: getUserComments(),
              builder: (BuildContext context, AsyncSnapshot<List<UserComment>> snapshot) {
                if (!snapshot.hasData) {
                  //==============================Loader=======================================
                  return Container(
                    // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.red)),
                    // height: 300,
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 270,
                      child: Center(
                        child: CupertinoActivityIndicator(
                          color: Theme.of(context).colorScheme.primary,
                          animating: true,
                          radius: 15,
                        ),
                      ),
                    ),
                  );
                } else {
                  //======================================Body of Container=================================
                  return Form(
                    key: terminateFormKey,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //===================================Comment Pop up===========================================
                          CustomPopupMenu(
                            pressType: PressType.singleClick,
                            arrowSize: 20,
                            showArrow: true,
                            barrierColor: const Color.fromARGB(122, 0, 0, 0),
                            controller: menuController,
                            arrowColor: Theme.of(context).colorScheme.primary,
                            position: PreferredPosition.bottom,
                            verticalMargin: 0,
                            // verticalMargin: -50,
                            // horizontalMargin: 50,
                            child: Container(
                              padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.selectComment,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          // color: ThemeProvider.isDarkMode ? Colors.white : Theme.of(context).colorScheme.primary,
                                          color: ThemeProvider.isDarkModeCheck() ? Colors.white : Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        // color: ThemeProvider.isDarkMode ? Colors.white : Theme.of(context).colorScheme.primary,
                                        color: ThemeProvider.isDarkModeCheck() ? Colors.white : Theme.of(context).colorScheme.primary,
                                      )
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                                    child: Divider(
                                      // color: ThemeProvider.isDarkMode ? Colors.white : Theme.of(context).colorScheme.primary,
                                      color: ThemeProvider.isDarkModeCheck() ? Colors.white : Theme.of(context).colorScheme.primary,
                                      height: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            menuBuilder: () {
                              return Container(
                                height: 300,
                                width: 350,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.background,
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 0.5),
                                ),
                                child: ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.only(top: 10),
                                  itemBuilder: (context, index) {
                                    UserComment userComment = snapshot.data![index];
                                    return GestureDetector(
                                      onTap: () {
                                        menuController.hideMenu();
                                        userCommentController.text = userComment.comment;
                                      },
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              userComment.shortComment,
                                              // style: TextStyle(color: ThemeProvider.isDarkMode ? Colors.white : Theme.of(context).colorScheme.primary),
                                              style: TextStyle(color: ThemeProvider.isDarkModeCheck() ? Colors.white : Theme.of(context).colorScheme.primary),
                                            ),
                                          ),
                                          const Divider(
                                            color: Colors.grey,
                                            indent: 10,
                                            endIndent: 10,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          //======================================Text Form for Comments=======================================
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(5)),
                              border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
                            ),
                            child: TextFormField(
                              decoration: InputDecoration.collapsed(
                                enabled: true,
                                // hintStyle: TextStyle(color: ThemeProvider.isDarkMode ? Colors.white54 : Colors.grey.shade400),
                                hintStyle: TextStyle(color: ThemeProvider.isDarkModeCheck() ? Colors.white54 : Colors.grey.shade400),
                                hintText: AppLocalizations.of(context)!.writeComment,
                              ),
                              // style: TextStyle(color: ThemeProvider.isDarkMode ? Colors.white : ThemeProvider.primaryColor),
                              style: TextStyle(color: ThemeProvider.isDarkModeCheck() ? Colors.white : ThemeProvider.primaryColor),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return AppLocalizations.of(context)!.requireField;
                                } else {
                                  return null;
                                }
                              },
                              controller: userCommentController,
                              maxLines: 3,
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          //=======================================Termination Button====================================================
                          SizedBox(
                              width: 230,
                              child: MyButton(
                                btnText: AppLocalizations.of(context)!.terminate,
                                onTap: () => onTerminatePressed2(context),
                              )

                              // ElevatedButton(
                              //   onPressed: () => onTerminatePressed2(context),
                              //   style: ElevatedButton.styleFrom(
                              //     primary:
                              //         Theme.of(context).colorScheme.primary,
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(
                              //           0), // Set the desired border radius
                              //     ),
                              //     padding: EdgeInsets.symmetric(
                              //         horizontal:
                              //             10), // Adjust horizontal padding
                              //   ),
                              //   child: Text(
                              //     AppLocalizations.of(context)!.terminate,
                              //     style: const TextStyle(color: Colors.white),
                              //   ),
                              // ),
                              ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
                          //     MyButton(btnText: AppLocalizations.of(context)!.terminate, onTap: () => onTerminatePressed2(context)),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
