// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:tawasol/app_models/app_view_models/db_entities/inbox_Item.dart';

// import './slide_action.dart';
// import './custom_dialog.dart';
// import '../app_models/app_utilities/app_helper.dart';
// import '../app_models/app_utilities/app_routes.dart';
// import '../app_models/app_view_models/user_signature.dart';

// // ignore: must_be_immutable
// class ContentOfSlideable extends StatelessWidget {
//   var rLang;
//   var rBuildContext;
//   double mWdt;
//   double mHgt;
//   bool isPort;
//   InboxItem rCurrentInboxItem;

//   ContentOfSlideable({
//     required this.rLang,
//     required this.rBuildContext,
//     required this.isPort,
//     required this.rCurrentInboxItem,
//     required this.mWdt,
//     required this.mHgt,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ActionPane(
//       dragDismissible: false,
//       // extentRatio: AppHelper.isMobileDevice(context) ? 0.75 : 0.45,
//       extentRatio: AppHelper.isMobileDevice(context)
//           ? 0.5
//           : isPort
//               ? 0.35
//               : 0.3,
//       // motion: const BehindMotion(),
//       motion: const DrawerMotion(),
//       // motion: const StretchMotion(),
//       children: [
//         CustomSlidableAction(
//           padding: EdgeInsets.zero,
//           // borderRadius: BorderRadius.only(
//           //   topLeft: AppHelper.isCurrentArabic ? const Radius.circular(0) : const Radius.circular(10),
//           //   topRight: AppHelper.isCurrentArabic ? const Radius.circular(10) : const Radius.circular(0),
//           //   bottomRight: AppHelper.isCurrentArabic ? const Radius.circular(10) : const Radius.circular(0),
//           //   bottomLeft: AppHelper.isCurrentArabic ? const Radius.circular(0) : const Radius.circular(10),
//           // ),
//           backgroundColor: AppHelper.myColor("#0278AB"),
//           onPressed: (context) {
//             // Routes.moveSend(context: context, selectedItem: rCurrentInboxItem);
//             print("send2");
//             Routes.moveSend2(
//               ctx: context,
//               selectedItem: rCurrentInboxItem,
//               rHgt: mHgt,
//               langg: rLang,
//               rWdt: mWdt,
//             );
//           },
//           child: SlideAction(
//             imageName: "send_shortcut_new",
//             actionName: rLang.send,
//           ),
//         ),
//         if (rCurrentInboxItem.isApproveEnabled)
//           CustomSlidableAction(
//             padding: EdgeInsets.zero,
//             onPressed: (context) async {
//               AppHelper.showLoaderDialog(rBuildContext);
//               List<UserSignature> signatureList = await AppHelper.getUserSignatures(rBuildContext);
//               // signatureList.first.signCount == 1 && AppHelper.hideLoader(rBuildContext);
//               if (AppHelper.currentUserSession.userName.toLowerCase() == AppHelper.ministerUser || signatureList.where((sign) => sign.signContent.isNotEmpty).length == 1) {
//                 bool isApproved = await AppHelper.onApproveTapped(
//                   context: rBuildContext,
//                   inboxItem: rCurrentInboxItem,
//                   signatureVsId: signatureList.firstWhere((signature) => signature.signContent.isNotEmpty).vsId,
//                   isNeedShowLoader: false,
//                 );
//                 // if (isApproved) {
//                 //   Routes.moveDashboard(context: rBuildContext);
//                 // }
//                 //
//                 // if (rCurrentInboxItem.securityLevelId == 4) Routes.moveSend(context: context, selectedItem: rCurrentInboxItem);
//                 //
//                 if (isApproved) {
//                   if (rCurrentInboxItem.securityLevelId == 4)
//                     Routes.moveSend(context: context, selectedItem: rCurrentInboxItem);
//                   else
//                     Routes.moveDashboard(context: rBuildContext);
//                 }
//               } else {
//                 AppHelper.hideLoader(rBuildContext);
//                 CustomDialog.showApproveDialog(rBuildContext, rCurrentInboxItem);
//               }
//               // Routes.moveApprove(context, rCurrentInboxItem);
//             },
//             backgroundColor: AppHelper.myColor("#cb9640"),
//             // backgroundColor: AppHelper.myColor("#419644"),
//             child: SlideAction(
//               imageName: "approve_shortcut_new",
//               actionName: rLang.approve,
//             ),
//           ),
//         if (!rCurrentInboxItem.isApproveEnabled)
//           CustomSlidableAction(
//             padding: EdgeInsets.zero,
//             backgroundColor: AppHelper.myColor("#1054b9"),
//             // backgroundColor: rCurrentInboxItem.isApproveEnabled? AppHelper.myColor('#0278AB'): Colors.blue.shade900,
//             onPressed: (context) {
//               print("multiSend");
//               Routes.moveMultiSend(
//                 context: context,
//                 selectedItems: [rCurrentInboxItem],
//               );
//               // Routes.moveMultiSend2(
//               //   context: context,
//               //   selectedItems: [rCurrentInboxItem],
//               //   ctx: context,
//               //   rWdt: mWdt,
//               // );
//             },
//             child: SlideAction(
//               imageName: "multi_send_shortcut_new",
//               actionName: rLang.multiSend,
//             ),
//           ),
//         CustomSlidableAction(
//           padding: EdgeInsets.zero,
//           // backgroundColor: AppHelper.myColor("#BD332A"),
//           backgroundColor: AppHelper.myColor("#cd2937"),
//           onPressed: (context) {
//             print("terminate");
//             // CustomDialog.showTerminateDialog(context, [rCurrentInboxItem]);
//             CustomDialog.showTerminateDialog2(
//               context,
//               [rCurrentInboxItem],
//               mHgt,
//             );
//           },
//           child: SlideAction(
//             imageName: "terminate_shortcut_new",
//             actionName: rLang.terminate,
//           ),
//         ),
//       ],
//     );
//   }
// }
