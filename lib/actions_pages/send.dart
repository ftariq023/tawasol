import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/app_user.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/user_comment.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/wf_action.dart';
import 'package:tawasol/app_models/service_models/service_handler.dart';
import 'package:tawasol/custom_controls/dropdown.dart';
import 'package:tawasol/custom_controls/my_button.dart';
import 'package:tawasol/theme/theme_provider.dart';

import '../app_models/app_utilities/app_routes.dart';
import '../app_models/app_view_models/db_entities/inbox_Item.dart';
import '../app_models/app_view_models/db_entities/organization_unit.dart';

class Send extends StatefulWidget {
  Send({super.key, required this.selectedItem, this.isFromSearchShortcut = false});

  dynamic selectedItem;
  final bool isFromSearchShortcut;

  @override
  State<Send> createState() => _SendState();
}

Future<bool> _onWillPop() async {
  return false; //<-- SEE HERE
}

class _SendState extends State<Send> {
  GlobalKey<FormState>? sendFormKey;

  @override
  void initState() {
    sendFormKey = GlobalKey<FormState>();

    _isRelatedDocumentsChecked = isRelatedDocumentEnabled();
    if (widget.selectedItem is InboxItem) {
      InboxItem currentItem = widget.selectedItem;

      _selectedAppUser = AppUser(currentItem.senderId, currentItem.senderDomainName, currentItem.enSenderName, currentItem.arSenderName, -1, -1, -1, -1, null, null, -1, false, currentItem.senderSendSMS, currentItem.senderSendEmail, currentItem.senderOuId, currentItem.regOuId, currentItem.enSenderOuName, currentItem.arSenderOuName, false);
      _isEmailChecked = currentItem.senderSendEmail;
      _isSmsChecked = currentItem.senderSendSMS;
    }
    // TODO: implement initState
    super.initState();
  }

  OrganizationUnit? _selectedOu;
  AppUser? _selectedAppUser;
  UserComment? _selectedComment;
  int _selectedActionId = -1;
  WfAction? _selectedAction;
  bool _isEmailChecked = false;
  bool _isSecureCommentChecked = false;
  bool _isSmsChecked = false;
  bool _isRelatedDocumentsChecked = false;
  final TextEditingController userCommentController = TextEditingController();

  bool isRelatedDocumentEnabled() {
    if (widget.selectedItem is InboxItem) {
      if (AppHelper.currentUserSession.relatedBooksStatus == 0) {
        _isRelatedDocumentsChecked = false;
        return false;
      } else if (AppHelper.currentUserSession.relatedBooksStatus == 1) {
        // _isRelatedDocumentsChecked = true;
        return true;
      } else {
        //  _isRelatedDocumentsChecked =
        return AppHelper.currentUserSession.relatedBooksStatus == 2 && AppHelper.currentUserSession.regOuId == widget.selectedItem.fromRegOuId;
      }
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color appPrimaryColor = Theme.of(context).colorScheme.primary;

    var lang = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, 80),
          child: AppBar(
            // backgroundColor: null,
            //appPrimaryColor,
            centerTitle: true,
            leading: GestureDetector(
              onTap: () async {
                if (sendFormKey!.currentState!.validate()) {
                  //add users
                  List<Object> tempUsers = [];
                  Map<String, Object> tempUser = {
                    'action': _selectedActionId,
                    'comments': userCommentController.text,
                    'toUserDomain': _selectedAppUser!.loginName,
                    'appUserOUID': _selectedAppUser!.ouId,
                    'toUserId': _selectedAppUser!.id,
                    'sendEmail': _isEmailChecked,
                    'sendSMS': _isSmsChecked,
                    'isSecureAction': _isSecureCommentChecked,
                    'sendRelatedDocs': _isRelatedDocumentsChecked,
                  };
                  tempUsers.add(tempUser);

                  var finalUsers = {'normalUsers': tempUsers};
                  AppHelper.showLoaderDialog(context);

                  bool result = await ServiceHandler.send(widget.selectedItem.vsID, widget.selectedItem is InboxItem ? AppHelper.getDocumentType(docType: widget.selectedItem.docClassId, needLocal: false) : AppHelper.getDocumentType(docType: AppHelper.getDocumentClassIdByName(widget.selectedItem.classDescription.toLowerCase()), needLocal: false),
                      widget.selectedItem is InboxItem ? widget.selectedItem.wobNumber : '', finalUsers);
                  AppHelper.hideLoader(context);

                  if (result) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          lang.sendSuccess,
                        ),
                      ),
                    );
                    // await AppHelper.showCustomAlertDialog(
                    //     context,
                    //     null,
                    //     lang.sendSuccess,
                    //     lang.close,
                    //     null);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(lang.errorMessage),
                      ),
                    );
                    // await AppHelper.showCustomAlertDialog(
                    //     context,
                    //     null,
                    //     lang.errorMessage,
                    //     lang.close,
                    //     null);
                    return;
                  }

                  Navigator.of(context).pop();
                  if (Navigator.of(context).canPop() && !widget.isFromSearchShortcut) {
                    Navigator.of(context).pop();
                  }
                  if (widget.selectedItem is InboxItem && result) Routes.moveDashboard(context: context);
                }
              },
              child: Container(
                child: Center(
                  child: Text(
                    lang.send,
                    style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 18, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
            ),
            title: Text(
              lang.send,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white, overflow: TextOverflow.ellipsis),
            ),
            // flexibleSpace: Container(
            //   decoration: const BoxDecoration(
            //       image: DecorationImage(
            //           image: AssetImage('assets/images/header_moi.png'),
            //           fit: BoxFit.fill)),
            // ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                // borderRadius: BorderRadius.only(
                // bottomLeft: Radius.circular(20),
                // Adjust the border radius for left bottom
                // bottomRight: Radius.circular(20), // Adjust the border radius for right bottom
                // ),
              ),
            ),
            // backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
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
        body: Form(
          key: sendFormKey,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(AppHelper.isMobileDevice(context) ? 15 : 20),
              margin: const EdgeInsets.only(top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Text(
                  //   lang.sendingInfo,
                  //   style: TextStyle(
                  //       color: appPrimaryColor,
                  //       fontWeight: FontWeight.bold,
                  //       fontSize: 16),
                  // ),
                  // const SizedBox(
                  //   height: 5,
                  // ),
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
                          // const SizedBox(
                          //   width: 10,
                          // ),
                          Expanded(
                            child: Dropdown(
                              isLabel: true,
                              listItemType: OrganizationUnit,
                              selectedValue: _selectedOu,
                              isShowBorder: false,
                              isShowTopLabel: false,
                              listItemBinding: ServiceHandler.getAllOUs,
                              isValidationRequired: _selectedAppUser == null ? true : false,
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
                      Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              lang.selectOuUser,
                              style: TextStyle(color: appPrimaryColor, fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ),
                          Expanded(
                            child: Dropdown(
                              isLabel: true,
                              listItemType: AppUser,
                              selectedValue: _selectedAppUser,
                              listItemBinding: () {
                                return ServiceHandler.getAllUsersByOUs(_selectedOu!.ouID, _selectedOu!.ouID == _selectedOu!.regOuID);
                              },
                              isValidationRequired: true,
                              isShowTopLabel: false,
                              isShowBorder: false,
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
                              prefixIconData: null, // Icons.person_2_outlined,
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
                  // Text(
                  //   lang.bookActions,
                  //   style: TextStyle(
                  //       color: appPrimaryColor,
                  //       fontWeight: FontWeight.bold,
                  //       fontSize: 16),
                  // ),
                  // const SizedBox(
                  //   height: 5,
                  // ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
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
                      SizedBox(
                        height: AppHelper.isMobileDevice(context) ? 0 : 15,
                      ),
                      if (false)
                        Row(
                          mainAxisAlignment: AppHelper.isMobileDevice(context) ? MainAxisAlignment.start : MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            if (false)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isEmailChecked = !_isEmailChecked;
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
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          value: _isEmailChecked,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _isEmailChecked = value ?? false;
                                            });
                                          },
                                        ),
                                      ),
                                      TextSpan(text: lang.email, style: TextStyle(fontSize: 16, fontFamily: 'Arial', color: _isEmailChecked ? appPrimaryColor : AppHelper.myColor("#707070"), fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                ),
                              ),
                            SizedBox(
                              width: AppHelper.isMobileDevice(context) ? 50 : null,
                            ),
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
                                    TextSpan(text: lang.secureComment, style: TextStyle(fontSize: AppHelper.isMobileDevice(context) ? 14 : 18, fontFamily: 'Arial', color: _isSecureCommentChecked ? appPrimaryColor : AppHelper.myColor("#707070"), fontWeight: FontWeight.w500))
                                  ],
                                ),
                              ),
                            ),
                            //  if (!AppHelper.isMobileDevice(context))
                            if (false)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isSmsChecked = !_isSmsChecked;
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
                                          value: _isSmsChecked,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _isSmsChecked = value ?? false;
                                            });
                                          },
                                        ),
                                      ),
                                      TextSpan(text: lang.sms, style: TextStyle(fontSize: AppHelper.isMobileDevice(context) ? 14 : 18, fontFamily: 'Arial', color: _isSmsChecked ? appPrimaryColor : AppHelper.myColor("#707070"), fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),

                      //     if (AppHelper.isMobileDevice(context))
                      if (false)
                        Row(
                          mainAxisAlignment: AppHelper.isMobileDevice(context) ? MainAxisAlignment.start : MainAxisAlignment.start,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isSmsChecked = !_isSmsChecked;
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
                                        value: _isSmsChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _isSmsChecked = value ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    TextSpan(text: lang.sms, style: TextStyle(fontSize: AppHelper.isMobileDevice(context) ? 14 : 18, fontFamily: 'Arial', color: _isSmsChecked ? appPrimaryColor : AppHelper.myColor("#707070"), fontWeight: FontWeight.w500))
                                  ],
                                ),
                              ),
                            ),
                            // if (widget.selectedItem is! SearchResultItem)

                            if (false)
                              GestureDetector(
                                onTap: _isRelatedDocumentsChecked
                                    ? () {
                                        setState(() {
                                          _isRelatedDocumentsChecked = !_isRelatedDocumentsChecked;
                                        });
                                      }
                                    : null,
                                child: RichText(
                                  textAlign: TextAlign.start,
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Checkbox(
                                          side: BorderSide(color: AppHelper.myColor("#707070"), width: 1.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          value: _isRelatedDocumentsChecked,
                                          onChanged: isRelatedDocumentEnabled()
                                              ? (bool? value) {
                                                  setState(() {
                                                    _isRelatedDocumentsChecked = value ?? false;
                                                  });
                                                }
                                              : null,
                                        ),
                                      ),
                                      TextSpan(
                                          text: lang.sendRelatedDocuments,
                                          style: TextStyle(
                                              color: isRelatedDocumentEnabled()
                                                  ? _isRelatedDocumentsChecked
                                                      ? appPrimaryColor
                                                      : AppHelper.myColor("#707070")
                                                  : Colors.grey,
                                              fontFamily: AppHelper.isCurrentArabic ? 'Lusail Medium' : null,
                                              fontSize: AppHelper.isMobileDevice(context) ? 14 : 18,
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),

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
                              prefixIconData: null, // Icons.domain_verification_outlined,
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
                          Expanded(
                            child: Dropdown(
                              isLabel: true,
                              isShowBorder: false,
                              listItemType: UserComment,
                              selectedValue: _selectedComment,
                              isShowTopLabel: false,
                              listItemBinding: ServiceHandler.getUserComments,
                              isValidationRequired: false,
                              labelText: lang.selectComment,
                              onDropdownChange: (dynamic item) {
                                _selectedComment = item;
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
                      // const SizedBox(height: 10,),
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
                                  //   fontFamily: 'AlMajd',
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
                    ],
                  ),
                  // Center(
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(top: 25.0),
                  //     child: MyButton(
                  //       onTap: () async {
                  //         {
                  //           if (sendFormKey!.currentState!.validate()) {
                  //             //add users
                  //             List<Object> tempUsers = [];
                  //             Map<String, Object> tempUser = {
                  //               'action': _selectedActionId,
                  //               'comments': userCommentController.text,
                  //               'toUserDomain': _selectedAppUser!.loginName,
                  //               'appUserOUID': _selectedAppUser!.ouId,
                  //               'toUserId': _selectedAppUser!.id,
                  //               'sendEmail': _isEmailChecked,
                  //               'sendSMS': _isSmsChecked,
                  //               'isSecureAction': _isSecureCommentChecked,
                  //               'sendRelatedDocs': _isRelatedDocumentsChecked,
                  //             };
                  //             tempUsers.add(tempUser);

                  //             var finalUsers = {'normalUsers': tempUsers};
                  //             AppHelper.showLoaderDialog(context);

                  //             bool result = await ServiceHandler.send(
                  //                 widget.selectedItem.vsID,
                  //                 widget.selectedItem is InboxItem ? AppHelper.getDocumentType(docType: widget.selectedItem.docClassId, needLocal: false) : AppHelper.getDocumentType(docType: AppHelper.getDocumentClassIdByName(widget.selectedItem.classDescription.toLowerCase()), needLocal: false),
                  //                 widget.selectedItem is InboxItem ? widget.selectedItem.wobNumber : '',
                  //                 finalUsers);
                  //             AppHelper.hideLoader(context);

                  //             if (result) {
                  //               await AppHelper.showCustomAlertDialog(context, null, lang.sendSuccess, lang.close, null);
                  //             } else {
                  //               await AppHelper.showCustomAlertDialog(context, null, lang.errorMessage, lang.close, null);
                  //               return;
                  //             }

                  //             Navigator.of(context).pop();
                  //             if (Navigator.of(context).canPop() && !widget.isFromSearchShortcut) {
                  //               Navigator.of(context).pop();
                  //             }
                  //             if (widget.selectedItem is InboxItem && result) Routes.moveDashboard(context);
                  //           }
                  //         }
                  //       },
                  //       btnText: lang.send,
                  //       isWhiteColor: true,
                  //       btnIconData: null,
                  //       svgPicturePath: "assets/images/send_shortcut_new.svg",
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        //  floatingActionButton: MyButton(
        //    onTap: () async {
        //      {
        //        if (sendFormKey!.currentState!.validate()) {
        //          //add users
        //          List<Object> tempUsers = [];
        //          Map<String, Object> tempUser = {
        //            'action': _selectedActionId,
        //            'comments': userCommentController.text,
        //            'toUserDomain': _selectedAppUser!.loginName,
        //            'appUserOUID': _selectedAppUser!.ouId,
        //            'toUserId': _selectedAppUser!.id,
        //            'sendEmail': _isEmailChecked,
        //            'sendSMS': _isSmsChecked,
        //            'isSecureAction': _isSecureCommentChecked,
        //            'sendRelatedDocs': _isRelatedDocumentsChecked,
        //          };
        //          tempUsers.add(tempUser);
        //
        //          var finalUsers = {'normalUsers': tempUsers};
        //          AppHelper.showLoaderDialog(context);
        //
        //          bool result = await ServiceHandler.send(
        //              widget.selectedItem.vsID,
        //              widget.selectedItem is InboxItem
        //                  ? AppHelper.getDocumentType(
        //                      docType: widget.selectedItem.docClassId,
        //                      needLocal: false)
        //                  : AppHelper.getDocumentType(
        //                      docType: AppHelper.getDocumentClassIdByName(widget
        //                          .selectedItem.classDescription
        //                          .toLowerCase()),
        //                      needLocal: false),
        //              widget.selectedItem is InboxItem
        //                  ? widget.selectedItem.wobNumber
        //                  : '',
        //              finalUsers);
        //          AppHelper.hideLoader(context);
        //
        //          if (result) {
        //            await AppHelper.showCustomAlertDialog(
        //                context,
        //                null,
        //                lang.sendSuccess,
        //                lang.close,
        //                null);
        //          } else {
        //            await AppHelper.showCustomAlertDialog(
        //                context,
        //                null,
        //                lang.errorMessage,
        //                lang.close,
        //                null);
        //            return;
        //          }
        //
        //          Navigator.of(context).pop();
        //          if (Navigator.of(context).canPop() &&
        //              !widget.isFromSearchShortcut) {
        //            Navigator.of(context).pop();
        //          }
        //          if (widget.selectedItem is InboxItem && result)
        //            Routes.moveDashboard(context);
        //        }
        //      }
        //    },
        //    btnText: lang.send,
        //    isWhiteColor: true,
        //    btnIconData: null,
        //    svgPicturePath:  "assets/images/send_shortcut_new.svg",
        //  ),
      ),
    );
  }
}
// disabledItemFn: (String s) => s.startsWith('I'),
//   disabledItemFn: (String s) => s.startsWith('I'),
// ),
