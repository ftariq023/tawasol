import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/app_user.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/search_result_item.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/sent_Item.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/user_comment.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/wf_action.dart';
import 'package:tawasol/app_models/app_view_models/send_user.dart';
import 'package:tawasol/app_models/service_models/service_handler.dart';
import 'package:badges/badges.dart' as badges;
import 'package:tawasol/custom_controls/my_button.dart';
import '../app_models/app_utilities/app_routes.dart';
import '../app_models/app_view_models/db_entities/inbox_Item.dart';
import '../app_models/app_view_models/db_entities/organization_unit.dart';
import '../custom_controls/dropdown.dart';
import '../theme/theme_provider.dart';

class MultiSend extends StatefulWidget {
  List selectedItems;
  final bool isFromSearchShortcut;

  MultiSend({
    super.key,
    required this.selectedItems,
    this.isFromSearchShortcut = false,
  });

  @override
  State<MultiSend> createState() => _MultiSendState();
}

Future<bool> _onWillPop() async {
  return false; //<-- SEE HERE
}

class _MultiSendState extends State<MultiSend> {
  GlobalKey<FormState>? multiSendFormKey;

  @override
  void initState() {
    multiSendFormKey = GlobalKey<FormState>();

    // _isRelatedDocumentsChecked = isRelatedDocumentEnabled();

    // TODO: implement initState
    super.initState();
  }

  OrganizationUnit? _selectedOu;
  AppUser? _selectedAppUser;
  WfAction? _selectedAction;
  UserComment? _userComment;

  int _selectedActionId = -1;
  bool _isEmailChecked = false;
  bool _isSecureCommentChecked = false;
  bool _isSmsChecked = false;
  bool _isRelatedDocumentsChecked = false;

  Map<String, Object> finalUsers = {};
  List<SendUserModel> sendUserList = [];
  final TextEditingController userCommentController = TextEditingController();
  final TextEditingController _userEditTextController = TextEditingController();

  void prepareUserModelList() {
    SendUserModel userModel = SendUserModel();
    userModel.userComment = userCommentController.text;
    userModel.actionName = _selectedAction!.actionName;
    userModel.appUserName = _selectedAppUser!.appUserName;
    userModel.ouName = _selectedAppUser!.ouName;
    userModel.selectedOuId = _selectedAppUser!.ouId;
    userModel.isEmailChecked = _isEmailChecked;
    userModel.isSecureCommentChecked = _isSecureCommentChecked;
    userModel.isSMSChecked = _isSmsChecked;
    userModel.isRelatedDocumentChecked = _isRelatedDocumentsChecked;
    userModel.selectedAction = _selectedAction!.actionID;
    userModel.loginName = _selectedAppUser!.loginName;
    userModel.selectedUserId = _selectedAppUser!.id;
    setState(() {
      sendUserList.add(userModel);
    });
  }

  Map<String, Object> prepareUserList() {
    List<Object> tempUsers = [];

    for (var sendUser in sendUserList) {
      tempUsers.add({
        'action': sendUser.selectedAction,
        'comments': sendUser.userComment ?? '',
        'toUserDomain': sendUser.loginName,
        'appUserOUID': sendUser.selectedOuId,
        'toUserId': sendUser.selectedUserId,
        'sendEmail': sendUser.isEmailChecked,
        'sendSMS': sendUser.isSMSChecked,
        'isSecureAction': sendUser.isSecureCommentChecked,
        'sendRelatedDocs': sendUser.isRelatedDocumentChecked,
      });
    }
    return {'normalUsers': tempUsers};
  }

  // selected: _isSelected,
  Widget inputChips(SendUserModel sendUser) {
    return InputChip(
      padding: const EdgeInsets.all(2.0),
      color: const MaterialStatePropertyAll(Colors.white),
      deleteIconColor: AppHelper.myColor('#676767'),
      // side: BorderSide(color: Colors.black26,style: BorderStyle.solid,width: 2),
      // avatar: CircleAvatar(
      //   backgroundColor: Colors.blue.shade600,
      //   child: const Text('JW'),
      // ),
      label: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Text(
              sendUser.appUserName,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
          ),
          // Text(
          //   sendUser.ouName,
          //   style: TextStyle(
          //        color: Colors.grey.shade700),
          // ),

          RichText(
              text: TextSpan(children: [
            WidgetSpan(
                child: Icon(
                  Icons.account_balance_outlined,
                  color: Colors.grey.shade700,
                  size: 18,
                ),
                alignment: PlaceholderAlignment.middle),
            TextSpan(
              text: '  ${sendUser.ouName}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ]))
        ],
      ),

      selectedColor: Colors.green,
      onSelected: (bool selected) {
        setState(() {
          //  _isSelected = selected;
        });
      },
      // onPressed: () {
      //   //
      // },
      onDeleted: () {
        setState(() {
          sendUserList.remove(sendUser);
        });
      },
    );
  }

  resetAllFields() {
    setState(() {
      userCommentController.text = '';
      _selectedAppUser = null;
      _isSecureCommentChecked = _isEmailChecked = _isSmsChecked = _isRelatedDocumentsChecked = false;
      _selectedAction = _userComment = _selectedAction = _selectedOu = null;
      _selectedActionId = -1;
    });
  }

  // bool isRelatedDocumentEnabled() {
  //   if (widget.selectedItem is InboxItem) {
  //     if (AppHelper.currentUserSession.relatedBooksStatus == 0) {
  //       return false;
  //     } else if (AppHelper.currentUserSession.relatedBooksStatus == 1) {
  //       return true;
  //     } else {
  //       return AppHelper.currentUserSession.relatedBooksStatus == 2 && AppHelper.currentUserSession.regOuId == widget.selectedItem.fromRegOuId;
  //     }
  //   } else {
  //     return false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    Color appPrimaryColor = Theme.of(context).colorScheme.primary;
    var lang = AppLocalizations.of(context)!;

    void multiSendAction() async {
      AppHelper.showLoaderDialog(context);
      // late bool result;
      List failedItemsSubject = [];
      for (var selectedItem in widget.selectedItems) {
        bool result = await ServiceHandler.send(
          selectedItem.vsID,
          (selectedItem is InboxItem || selectedItem is SentItem)
              ? AppHelper.getDocumentType(docType: selectedItem.docClassId, needLocal: false)
              : AppHelper.getDocumentType(
                  docType: AppHelper.getDocumentClassIdByName(selectedItem.classDescription.toLowerCase()),
                  needLocal: false,
                ),
          selectedItem is InboxItem ? selectedItem.wobNumber : '',
          prepareUserList(),
          isSentItem: selectedItem is SentItem,
        );
        if (!result) failedItemsSubject.add(selectedItem.docSubject);
      }

      AppHelper.hideLoader(context);

      if (failedItemsSubject.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          lang.sendSuccess,
        )));

        // await AppHelper.showCustomAlertDialog(
        //     context,
        //     null,
        //     lang.sendSuccess,
        //     lang.close,
        //     null);
      } else {
        String failedSubjects = "";
        for (var subject in failedItemsSubject) failedSubjects += subject + ", ";
        failedSubjects = failedSubjects.substring(0, failedSubjects.length - 2);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang.multiSendFailedFor + ": " + failedSubjects,
            ),
          ),
        );

        // await AppHelper.showCustomAlertDialog(
        //   context,
        //   null,
        //   lang.multiSendFailedFor +
        //       ": " +
        //       failedSubjects,
        //   lang.close,
        //   null,
        // );
        // return;
      }

      // if (result) {
      Navigator.of(context).pop();
      if (Navigator.of(context).canPop() && !widget.isFromSearchShortcut) {
        Navigator.of(context).pop();
      }
      if (widget.selectedItems[0] is InboxItem) {
        Routes.moveDashboard(context: context);
      } else if (widget.selectedItems[0] is SentItem) {
        Routes.moveDashboard(context: context, index: 1);
      }
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, 80),
          child: AppBar(
            // backgroundColor: null,
            centerTitle: true,
            title: Text(
              lang.multiSend,
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
            leadingWidth: 90,
            leading: TextButton(
              onPressed: sendUserList.isEmpty
                  ? null
                  : () async {
                      multiSendAction();
                    },
              child: Text(
                lang.send,
                style: TextStyle(color: sendUserList.isEmpty ? Colors.grey.shade500 : Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            actions: <Widget>[
              IconButton(
                onPressed: () async {
                  if (sendUserList.isNotEmpty) {
                    String selectedAction = await AppHelper.showCustomAlertDialog(context, null, lang.sendWarning, lang.yes, lang.no);
                    if (selectedAction == lang.yes) {
                      Navigator.pop(context);
                    }
                  } else {
                    Navigator.pop(context);
                  }
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
        body: SingleChildScrollView(
          child: Form(
            key: multiSendFormKey,
            child: Container(
              padding: EdgeInsets.all(AppHelper.isMobileDevice(context) ? 15 : 20),
              margin: const EdgeInsets.only(top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              lang.selectOU,
                              style: TextStyle(color: appPrimaryColor, fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ),
                          Expanded(
                            child: Dropdown(
                              isLabel: true,
                              isShowBorder: false,
                              listItemType: OrganizationUnit,
                              selectedValue: _selectedOu,
                              isShowTopLabel: false,
                              listItemBinding: ServiceHandler.getAllOUs,
                              isValidationRequired: true,
                              labelText: lang.selectOU,
                              onDropdownChange: (dynamic item) {
                                setState(() {
                                  _selectedOu = item;
                                  _selectedAppUser = null;
                                  _isSmsChecked = _isEmailChecked = false;
                                });
                              },
                              isSearchEnabled: true,
                              prefixIconData: null, // Icons.account_balance_outlined,
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 0.2,
                        color: Colors.grey,
                      ),
                      // SizedBox(
                      //   height: AppHelper.isMobileDevice(context) ? 15 : 30,
                      // ),
                      Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              lang.selectOuUser,
                              style: TextStyle(color: appPrimaryColor, fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ),
                          // const SizedBox(
                          //   width: 7,
                          // ),
                          Expanded(
                            child: Dropdown(
                              isLabel: true,
                              isShowBorder: false,
                              listItemType: AppUser,
                              selectedValue: _selectedAppUser,
                              listItemBinding: () {
                                return ServiceHandler.getAllUsersByOUs(_selectedOu!.ouID, _selectedOu!.ouID == _selectedOu!.regOuID);
                              },
                              isValidationRequired: true,
                              isShowTopLabel: false,
                              labelText: lang.selectOuUser,
                              onDropdownChange: (dynamic item) {
                                setState(() {
                                  _selectedAppUser = item;
                                  if (_selectedAppUser != null) {
                                    _isSmsChecked = _selectedAppUser!.isSMSNotificationsOn;
                                    _isEmailChecked = _selectedAppUser!.isEmailNotificationsOn;
                                  } else {
                                    _isSmsChecked = _isEmailChecked = false;
                                  }
                                });
                              },
                              isSearchEnabled: true,
                              isDropdownEnabled: _selectedOu != null,
                              prefixIconData: null, //Icons.person_2_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Divider(
                    thickness: 0.2,
                    color: Colors.grey,
                  ),
                  // SizedBox(
                  //   height: AppHelper.isMobileDevice(context) ? 15 : 30,
                  // ),
                  // Text(lang.bookActions,style: TextStyle(color: appPrimaryColor,fontWeight: FontWeight.bold,fontSize: 16),),
                  // const SizedBox(height: 5,),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Expanded(
                    //         child: Divider(
                    //       thickness: 1,
                    //       color: Colors.grey.shade400,
                    //     )),
                    //     Padding(
                    //       padding:
                    //           const EdgeInsets.symmetric(horizontal: 5.0),
                    //       child: Text(
                    //           lang.docActions,
                    //           style: TextStyle(
                    //               color: Colors.grey.shade600,
                    //               fontWeight: FontWeight.w700,
                    //               fontSize: 15)),
                    //     ),
                    //     Expanded(
                    //         child: Divider(
                    //       thickness: 1,
                    //       color: Colors.grey.shade400,
                    //     )),
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: AppHelper.isMobileDevice(context) ? 0 : 15,
                    // ),
                    // if (false)
                    //   Row(
                    //     mainAxisAlignment: AppHelper.isMobileDevice(context) ? MainAxisAlignment.start : MainAxisAlignment.spaceAround,
                    //     children: <Widget>[
                    //       GestureDetector(
                    //         onTap: () {
                    //           setState(() {
                    //             _isEmailChecked = !_isEmailChecked;
                    //           });
                    //         },
                    //         child: RichText(
                    //           textAlign: TextAlign.start,
                    //           text: TextSpan(
                    //             children: [
                    //               WidgetSpan(
                    //                 alignment: PlaceholderAlignment.middle,
                    //                 child: Checkbox(
                    //                   side: BorderSide(color: AppHelper.myColor("#707070"), width: 1.5),
                    //                   shape: RoundedRectangleBorder(
                    //                     borderRadius: BorderRadius.circular(3),
                    //                   ),
                    //                   value: _isEmailChecked,
                    //                   onChanged: (bool? value) {
                    //                     setState(() {
                    //                       _isEmailChecked = value ?? false;
                    //                     });
                    //                   },
                    //                 ),
                    //               ),
                    //               TextSpan(text: lang.email, style: TextStyle(fontSize: 16, fontFamily: 'Arial', color: _isEmailChecked ? appPrimaryColor : AppHelper.myColor("#707070"), fontWeight: FontWeight.w500))
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //       SizedBox(
                    //         width: AppHelper.isMobileDevice(context) ? 50 : null,
                    //       ),
                    //       GestureDetector(
                    //         onTap: () {
                    //           setState(() {
                    //             _isSecureCommentChecked = !_isSecureCommentChecked;
                    //           });
                    //         },
                    //         child: RichText(
                    //           textAlign: TextAlign.start,
                    //           text: TextSpan(
                    //             children: [
                    //               WidgetSpan(
                    //                 alignment: PlaceholderAlignment.middle,
                    //                 child: Checkbox(
                    //                   side: BorderSide(color: AppHelper.myColor("#707070"), width: 1.5),
                    //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                    //                   value: _isSecureCommentChecked,
                    //                   onChanged: (bool? value) {
                    //                     setState(() {
                    //                       _isSecureCommentChecked = value ?? false;
                    //                     });
                    //                   },
                    //                 ),
                    //               ),
                    //               TextSpan(text: lang.secureComment, style: TextStyle(fontSize: AppHelper.isMobileDevice(context) ? 14 : 18, fontFamily: 'Arial', color: _isSecureCommentChecked ? appPrimaryColor : AppHelper.myColor("#707070"), fontWeight: FontWeight.w500))
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //       if (!AppHelper.isMobileDevice(context))
                    //         GestureDetector(
                    //           onTap: () {
                    //             setState(() {
                    //               _isSmsChecked = !_isSmsChecked;
                    //             });
                    //           },
                    //           child: RichText(
                    //             textAlign: TextAlign.start,
                    //             text: TextSpan(
                    //               children: [
                    //                 WidgetSpan(
                    //                   alignment: PlaceholderAlignment.middle,
                    //                   child: Checkbox(
                    //                     side: BorderSide(color: AppHelper.myColor("#707070"), width: 1.5),
                    //                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                    //                     value: _isSmsChecked,
                    //                     onChanged: (bool? value) {
                    //                       setState(() {
                    //                         _isSmsChecked = value ?? false;
                    //                       });
                    //                     },
                    //                   ),
                    //                 ),
                    //                 TextSpan(text: lang.sms, style: TextStyle(fontSize: AppHelper.isMobileDevice(context) ? 14 : 18, fontFamily: 'Arial', color: _isSmsChecked ? appPrimaryColor : AppHelper.myColor("#707070"), fontWeight: FontWeight.w500))
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //     ],
                    //   ),
                    // // if (AppHelper.isMobileDevice(context))
                    // if (false)
                    //   Row(
                    //     mainAxisAlignment: AppHelper.isMobileDevice(context) ? MainAxisAlignment.start : MainAxisAlignment.start,
                    //     children: <Widget>[
                    //       GestureDetector(
                    //         onTap: () {
                    //           setState(() {
                    //             _isSmsChecked = !_isSmsChecked;
                    //           });
                    //         },
                    //         child: RichText(
                    //           textAlign: TextAlign.start,
                    //           text: TextSpan(
                    //             children: [
                    //               WidgetSpan(
                    //                 alignment: PlaceholderAlignment.middle,
                    //                 child: Checkbox(
                    //                   side: BorderSide(color: AppHelper.myColor("#707070"), width: 1.5),
                    //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                    //                   value: _isSmsChecked,
                    //                   onChanged: (bool? value) {
                    //                     setState(() {
                    //                       _isSmsChecked = value ?? false;
                    //                     });
                    //                   },
                    //                 ),
                    //               ),
                    //               TextSpan(text: lang.sms, style: TextStyle(fontSize: AppHelper.isMobileDevice(context) ? 14 : 18, fontFamily: 'Arial', color: _isSmsChecked ? appPrimaryColor : AppHelper.myColor("#707070"), fontWeight: FontWeight.w500))
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //       // if (widget.selectedItem is! SearchResultItem)
                    //       if (false)
                    //         GestureDetector(
                    //           onTap: _isRelatedDocumentsChecked
                    //               ? () {
                    //                   setState(() {
                    //                     _isRelatedDocumentsChecked = !_isRelatedDocumentsChecked;
                    //                   });
                    //                 }
                    //               : null,
                    //           child: RichText(
                    //             textAlign: TextAlign.start,
                    //             text: TextSpan(
                    //               children: [
                    //                 WidgetSpan(
                    //                   alignment: PlaceholderAlignment.middle,
                    //                   child: Checkbox(
                    //                     side: BorderSide(color: AppHelper.myColor("#707070"), width: 1.5),
                    //                     shape: RoundedRectangleBorder(
                    //                       borderRadius: BorderRadius.circular(3),
                    //                     ),
                    //                     value: _isRelatedDocumentsChecked,
                    //                     onChanged: isRelatedDocumentEnabled()
                    //                         ? (bool? value) {
                    //                             setState(() {
                    //                               _isRelatedDocumentsChecked = value ?? false;
                    //                             });
                    //                           }
                    //                         : null,
                    //                   ),
                    //                 ),
                    //                 TextSpan(
                    //                     text: lang.sendRelatedDocuments,
                    //                     style: TextStyle(
                    //                         color: isRelatedDocumentEnabled()
                    //                             ? _isRelatedDocumentsChecked
                    //                                 ? appPrimaryColor
                    //                                 : AppHelper.myColor("#707070")
                    //                             : Colors.grey,
                    //                         fontFamily: AppHelper.isCurrentArabic ? 'Lusail Medium' : null,
                    //                         fontSize: AppHelper.isMobileDevice(context) ? 14 : 18,
                    //                         fontWeight: FontWeight.w500))
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //     ],
                    //   ),
                    // const SizedBox(
                    //   height: 15,
                    // ),
                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            lang.selectWfAction,
                            style: TextStyle(color: appPrimaryColor, fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ),
                        // const SizedBox(
                        //   width: 4,
                        // ),
                        Expanded(
                          child: Dropdown(
                            isLabel: true,
                            isShowBorder: false,
                            listItemType: WfAction,
                            selectedValue: _selectedAction,
                            listItemBinding: ServiceHandler.getWfActions,
                            isValidationRequired: true,
                            isShowTopLabel: false,
                            labelText: lang.selectWfAction,
                            onDropdownChange: (dynamic item) {
                              _selectedAction = item;
                              if (item != null) {
                                setState(() {
                                  _selectedActionId = item.actionID;
                                });
                              }
                            },
                            isSearchEnabled: false,
                            prefixIconData: null, //Icons.domain_verification_outlined,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      thickness: 0.2,
                      color: Colors.grey,
                    ),

                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            lang.selectComment,
                            style: TextStyle(color: appPrimaryColor, fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ),
                        // const SizedBox(
                        //   width: 8,
                        // ),
                        Expanded(
                          child: Dropdown(
                            isLabel: true,
                            listItemType: UserComment,
                            selectedValue: _userComment,
                            isShowBorder: false,
                            isShowTopLabel: false,
                            listItemBinding: ServiceHandler.getUserComments,
                            isValidationRequired: false,
                            labelText: lang.selectComment,
                            onDropdownChange: (dynamic item) {
                              _userComment = item;
                              userCommentController.text = item != null ? item.comment : '';
                            },
                            isSearchEnabled: false,
                            prefixIconData: null, //Icons.comment_outlined,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      thickness: 0.2,
                      color: Colors.grey,
                    ),
                    // const SizedBox(
                    //   height: 10,
                    // ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSecureCommentChecked = !_isSecureCommentChecked;
                        });
                      },
                      child: RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Checkbox(
                                side: BorderSide(color: AppHelper.myColor("#707070"), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                value: _isSecureCommentChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isSecureCommentChecked = value ?? false;
                                  });
                                },
                              ),
                            ),
                            TextSpan(
                              text: lang.secureComment,
                              style: TextStyle(
                                fontSize: AppHelper.isMobileDevice(context) ? 14 : 18,
                                // fontFamily:  'AlMajd',
                                color: _isSecureCommentChecked ? appPrimaryColor : AppHelper.myColor("#707070"),
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   height: AppHelper.isMobileDevice(context) ? 15 : 30,
                    // ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: appPrimaryColor, width: 0.5),
                        color: null, //AppHelper.myColor('#ededed'),
                      ),
                      child: TextFormField(
                        controller: userCommentController,
                        maxLines: AppHelper.isMobileDevice(context) ? 4 : 5,
                        //or null
                        decoration: InputDecoration.collapsed(
                          enabled: true,
                          // hintStyle: TextStyle(color: ThemeProvider.isDarkMode ? Colors.white54 : Colors.grey.shade400),
                          hintStyle: TextStyle(color: ThemeProvider.isDarkModeCheck() ? Colors.white54 : Colors.grey.shade400),
                          hintText: lang.writeComment,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyButton(
                          btnText: lang.add,
                          onTap: () {
                            if (multiSendFormKey!.currentState!.validate()) {
                              if (sendUserList.any((user) => user.selectedOuId == _selectedOu!.ouID && user.selectedUserId == _selectedAppUser!.ouId)) {
                                var snackBar = SnackBar(
                                  content: Text(lang.userExist),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              } else {
                                prepareUserModelList();
                                resetAllFields();
                              }
                            }
                          },
                          btnIconData: Icons.add_circle_outline_outlined,
                        ),
                        const SizedBox(width: 40),
                        MyButton(
                          btnText: lang.clearAll,
                          backgroundColor: Colors.red,
                          onTap: () {
                            resetAllFields();
                          },
                          btnIconData: null,
                        ),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     resetAllFields();
                        //     // Add your button click logic here
                        //   },
                        //   style: ElevatedButton.styleFrom(
                        //     primary: Colors.red,
                        //     // Set the button color
                        //     onPrimary: Colors.white,
                        //     // Set the text color
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(
                        //           10.0), // Set the border radius
                        //     ),
                        //   ),
                        //   child: Text(
                        //     lang.clearAll,
                        //     style: const TextStyle(
                        //       fontSize: 18.0,
                        //       color: Colors.white,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ]),
                  SizedBox(
                    height: AppHelper.isMobileDevice(context) ? 10 : 20,
                  ),
                  if (sendUserList.isNotEmpty)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Divider(
                              thickness: 1,
                              color: Colors.grey.shade400,
                            )),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text(lang.selectedUsers, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700, fontSize: 15)),
                            ),
                            Expanded(
                                child: Divider(
                              thickness: 1,
                              color: Colors.grey.shade400,
                            )),
                          ],
                        ),
                        SizedBox(
                          height: AppHelper.isMobileDevice(context) ? 0 : 15,
                        ),
                        SizedBox(
                          height: AppHelper.isMobileDevice(context) ? 110 : 160,
                          width: double.infinity,
                          child: Card(
                            color: AppHelper.myColor('#ededed'),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.all(AppHelper.isMobileDevice(context) ? 5.0 : 10.0),
                                child: Wrap(direction: Axis.horizontal, spacing: 8, children: [
                                  ...sendUserList.map((sendUser) => inputChips(sendUser)),
                                ]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        // bottomNavigationBar: Container(
        //   color: Colors.transparent,
        //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        //   child: Row(
        //     children: [
        //       const Spacer(),
        //       ElevatedButton.icon(
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: appPrimaryColor,
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(8.0),
        //           ),
        //           disabledBackgroundColor: Colors.grey.shade500,
        //           disabledForegroundColor: Colors.grey.shade700,
        //           foregroundColor: Colors.white,
        //         ),
        //         onPressed: sendUserList.isEmpty
        //             ? null
        //             : () async {
        //                 multiSendAction();
        //                 //add users
        //                 // prepareUserList();
        //                 // AppHelper.showLoaderDialog(context);
        //                 // bool result = await ServiceHandler.send(
        //                 //   widget.selectedItem.vsID,
        //                 //   widget.selectedItem is InboxItem
        //                 //       ? AppHelper.getDocumentType(docType: widget.selectedItem.docClassId, needLocal: false)
        //                 //       : AppHelper.getDocumentType(
        //                 //           docType: AppHelper.getDocumentClassIdByName(widget.selectedItem.classDescription.toLowerCase()),
        //                 //           needLocal: false,
        //                 //         ),
        //                 //   widget.selectedItem is InboxItem ? widget.selectedItem.wobNumber : '',
        //                 //   prepareUserList(),
        //                 // );
        //                 // AppHelper.hideLoader(context);
        //
        //                 // if (result) {
        //                 //   await AppHelper.showCustomAlertDialog(context, null, lang.sendSuccess, lang.close, null);
        //                 // } else {
        //                 //   await AppHelper.showCustomAlertDialog(context, null, lang.errorMessage, lang.close, null);
        //                 //   return;
        //                 // }
        //
        //                 // if (result) {
        //                 //   Navigator.of(context).pop();
        //                 //   if (Navigator.of(context).canPop() && !widget.isFromSearchShortcut) {
        //                 //     Navigator.of(context).pop();
        //                 //   }
        //                 //   if (widget.selectedItem is InboxItem) {
        //                 //     Routes.moveDashboard(context);
        //                 //   }
        //                 // }
        //                 //
        //                 // modified:
        //
        //                 // }
        //               },
        //         label: RichText(
        //           overflow: TextOverflow.ellipsis,
        //           text: TextSpan(
        //             children: [
        //               TextSpan(
        //                   text: '${lang.multiSend}  ',
        //                   style: TextStyle(
        //                       color: sendUserList.isEmpty
        //                           ? Colors.grey.shade700
        //                           : Colors.white)),
        //               if (sendUserList.isNotEmpty)
        //                 WidgetSpan(
        //                     alignment: PlaceholderAlignment.middle,
        //                     child: Center(
        //                       child: Container(
        //                         width: 20.0,
        //                         height: 20.0,
        //                         decoration: BoxDecoration(
        //                           color: Colors.red.shade600,
        //                           shape: BoxShape.circle,
        //                           border: Border.all(
        //                             color: Colors.transparent,
        //                             width: 2.0,
        //                             style: BorderStyle.solid,
        //                           ),
        //                         ),
        //                         child: Center(
        //                           child: Text(
        //                             sendUserList.length.toString(),
        //                             style: const TextStyle(
        //                               color: Colors.white,
        //                               fontSize: 12.0,
        //                               fontWeight: FontWeight.w800,
        //                             ),
        //                           ),
        //                         ),
        //                       ),
        //                     ))
        //             ],
        //           ),
        //         ),
        //         icon: SvgPicture.asset(
        //           "assets/images/multi_send_shortcut_new.svg",
        //           theme: SvgTheme(
        //               currentColor: sendUserList.isEmpty
        //                   ? Colors.grey.shade700
        //                   : Colors.white),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
