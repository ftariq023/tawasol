import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/app_user.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/user_comment.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/wf_action.dart';
import 'package:tawasol/app_models/service_models/service_handler.dart';
// import 'package:tawasol/custom_controls/dropdown.dart';
// import 'package:tawasol/custom_controls/my_button.dart';
import 'package:tawasol/theme/theme_provider.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';

import '../app_models/app_utilities/app_routes.dart';
import '../app_models/app_view_models/db_entities/inbox_Item.dart';
import '../app_models/app_view_models/db_entities/organization_unit.dart';
import '../custom_controls/dropdown2.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

class Send2 extends StatefulWidget {
  Send2({super.key, required this.selectedItem, this.isFromSearchShortcut = false});

  dynamic selectedItem;
  final bool isFromSearchShortcut;

  @override
  State<Send2> createState() => _SendState();
}

class _SendState extends State<Send2> {
  GlobalKey<FormState>? sendFormKey;
  OrganizationUnit? _selectedOu;
  AppUser? _selectedAppUser;
  // AppUser? _selectedAppUser = AppUser();
  // UserComment? _selectedComment;
  UserComment? _selectedComment = UserComment(0, '', '');
  int _selectedActionId = -1;
  WfAction? _selectedAction;
  // WfAction? _selectedAction = WfAction(0, "", "");
  bool _isEmailChecked = false;
  bool _isSecureCommentChecked = false;
  bool _isSmsChecked = false;
  bool _isRelatedDocumentsChecked = false;
  final TextEditingController userCommentController = TextEditingController();

  //

  int screen = 1;
  bool sending = true, successResp = true;
  bool showErr = false, isCmntSelected = false;
  // bool showfield = true;
  late InboxItem currentUserItem;

  //
  // OrganizationUnit? dummyselectedOu;

  @override
  void initState() {
    sendFormKey = GlobalKey<FormState>();

    _isRelatedDocumentsChecked = isRelatedDocumentEnabled();
    if (widget.selectedItem is InboxItem) {
      InboxItem currentItem = widget.selectedItem;
      currentUserItem = currentItem;
      _selectedAppUser = AppUser(currentItem.senderId, currentItem.senderDomainName, currentItem.enSenderName, currentItem.arSenderName, -1, -1, -1, -1, null, null, -1, false, currentItem.senderSendSMS, currentItem.senderSendEmail, currentItem.senderOuId, currentItem.regOuId, currentItem.enSenderOuName, currentItem.arSenderOuName, false);
      _isEmailChecked = currentItem.senderSendEmail;
      _isSmsChecked = currentItem.senderSendSMS;
    }
    // TODO: implement initState
    super.initState();
  }

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

  void goToNextPg() {
    if (screen < 5) {
      if ((screen == 3 && _selectedAction == null) || (screen == 2 && _selectedAppUser == null)) return;
      // setState(() {
      //   showfield = false;
      // });
      setState(() {
        screen++;
      });
      // setState(() {
      //   showfield = true;
      // });
      // if (screen == 4) {
      //   if (!isCmntSelected)
      //     setState(() {
      //       _selectedComment = null;
      //     });
      // }
    }
  }

  void goToPrevPg() {
    if (screen > 1) {
      setState(() {
        screen--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var mqContext = MediaQuery.of(context);
    var size = mqContext.size;

    var mHeight = size.height - AppBar().preferredSize.height - mqContext.padding.top - mqContext.padding.bottom;
    var mWidth = size.width;

    // bool isPortrait = mqContext.orientation == Orientation.portrait;

    var lang = AppLocalizations.of(context)!;

    Color appPrimaryColor = Theme.of(context).colorScheme.primary;

    void send() async {
      // print("searchign");
      goToNextPg();
      // await Future.delayed(Duration(seconds: 3));
      // setState(() {
      //   sending = false;
      //   successResp = false;
      // });
      // return;
      // if (sendFormKey!.currentState!.validate()) {
      successResp = true;
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
      // AppHelper.showLoaderDialog(context);

      bool result = await ServiceHandler.send(widget.selectedItem.vsID, widget.selectedItem is InboxItem ? AppHelper.getDocumentType(docType: widget.selectedItem.docClassId, needLocal: false) : AppHelper.getDocumentType(docType: AppHelper.getDocumentClassIdByName(widget.selectedItem.classDescription.toLowerCase()), needLocal: false),
          widget.selectedItem is InboxItem ? widget.selectedItem.wobNumber : '', finalUsers);

      // AppHelper.hideLoader(context);
      // if (result) {
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //       content: Text(
      //     lang.sendSuccess,
      //   )));
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text(
      //         lang.errorMessage,
      //       ),
      //     ),
      //   );
      //   return;
      // }

      if (!result) successResp = false;

      setState(() {
        sending = false;
      });

      if (result) {
        AppHelper.isSent = true;
        await Haptics.vibrate(HapticsType.success);
      } else
        await Haptics.vibrate(HapticsType.error);

      // Navigator.of(context).pop();
      // if (Navigator.of(context).canPop() && !widget.isFromSearchShortcut) {
      //   Navigator.of(context).pop();
      // }
      // if (widget.selectedItem is InboxItem && result) Routes.moveDashboard(context: context);
      // }
    }

    Widget getBtnCont(bool isBack) {
      return GestureDetector(
        onTap: isBack ? goToPrevPg : () => Navigator.of(context).pop(),
        child: Container(
          // height: double.infinity,
          width: mHeight * 0.055,
          // decoration: BoxDecoration(
          //   border: Border.all(width: 1, color: Colors.black),
          // ),
          child: Icon(
            isBack ? Icons.arrow_back_ios_new : Icons.close,
            color: isBack && (screen == 1 || screen == 5) ? Colors.transparent : null,
            size: mWidth * 0.0525,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: mHeight * 0.4,
        width: double.infinity,
        // color: const Color(0XFFFFFFFF),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(mWidth * 0.05),
          color: const Color(0XFFFFFFFF),
        ),
        // padding: EdgeInsets.symmetric(horizontal: mWidth * 0.1),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: mHeight * 0.02),
            Container(
              // width: double.infinity,
              // margin: EdgeInsets.symmetric(
              //   // horizontal: mWidth * 0.05,
              //   vertical: mHeight * 0.01,
              // ),
              // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
              padding: EdgeInsets.symmetric(horizontal: mWidth * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getBtnCont(true),
                  Text(
                    lang.send,
                    style: TextStyle(
                      fontSize: mWidth * 0.045,
                      color: ThemeProvider.isDarkModeCheck() ? Colors.white : Theme.of(context).colorScheme.primary,
                      // fontFamily: Theme.of(context).textTheme.bodyText1!.fontFamily,
                    ),
                  ),
                  getBtnCont(false),
                ],
              ),
            ),
            SwipeDetector(
              behavior: HitTestBehavior.opaque,
              onSwipeLeft: (offset) {
                // _addSwipe(SwipeDirection.left);
                // print("left");
                if (screen == 5) return;
                goToPrevPg();
              },
              onSwipeRight: (offset) {
                // _addSwipe(SwipeDirection.right);
                // print("right");
                if (screen != 4) goToNextPg();
              },
              child: Container(
                height: mHeight * 0.34,
                // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
                padding: EdgeInsets.symmetric(horizontal: mWidth * 0.08),
                child: Column(
                  children: [
                    if (screen != 5) // progress bar
                      Container(
                        margin: EdgeInsets.symmetric(vertical: mHeight * 0.03),
                        child: StepProgressIndicator(
                          totalSteps: 4,
                          currentStep: screen,
                          size: 8,
                          padding: 0,
                          // selectedColor: Colors.yellow,
                          // unselectedColor: Colors.cyan,
                          // roundedEdges: Radius.circular(10),
                          selectedGradientColor: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF323232), Color(0xFFA29475)],
                          ),
                          unselectedGradientColor: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0XFFDFDFDF), Color(0XFFDFDFDF)],
                          ),
                        ),
                      ),
                    //
                    if (screen == 1)
                      Dropdown2(
                        isLabel: true,
                        listItemType: OrganizationUnit,
                        selectedValue: _selectedOu,
                        isShowBorder: false,
                        isShowTopLabel: false,
                        listItemBinding: ServiceHandler.getAllOUs,
                        isValidationRequired: _selectedAppUser == null ? true : false,
                        labelText: lang.selectOU,
                        // onDropdownChange: (dynamic item) {
                        //   setState(() {
                        //     _selectedOu = item;
                        //     _selectedAppUser = null;
                        //     _isSmsChecked = _isEmailChecked = false;
                        //     // screen++;
                        //   });
                        //   // _selectedAppUser = null;
                        //   // _isSmsChecked = _isEmailChecked = false;
                        //   if (_selectedOu != null) {
                        //     goToNextPg();
                        //   }
                        // },
                        // onDropdownChange: (dynamic item) async {
                        //   // setState(() {
                        //   // goToNextPg();
                        //   _selectedOu = item;
                        //   _selectedAppUser = null;
                        //   _isSmsChecked = _isEmailChecked = false;
                        //   // });
                        //   // if (_selectedOu != null) {
                        //   //   goToNextPg();
                        //   //   goToPrevPg();
                        //   //   goToNextPg();
                        //   // }
                        //   await Future.delayed(Duration(seconds: 1));
                        //   goToNextPg();
                        // },
                        // onDropdownChange: (dynamic item) async {
                        //   // _selectedOu = item;
                        //   // _selectedAppUser = null;
                        //   // _isSmsChecked = _isEmailChecked = false;
                        //   // setState(() {
                        //   //   screen++;
                        //   // });
                        //   // });
                        //   // if (_selectedOu != null) {
                        //   //   goToNextPg();
                        //   //   goToPrevPg();
                        //   //   goToNextPg();
                        //   // }
                        //   // await Future.delayed(Duration(seconds: 1));
                        //   goToNextPg();
                        // },
                        onDropdownChange: (dynamic item) async {
                          // setState(() {
                          //   showfield = false;
                          // });
                          // _selectedAppUser = null;
                          goToNextPg();
                          await Future.delayed(const Duration(milliseconds: 500));
                          // setState(() {
                          _selectedOu = item;
                          _selectedAppUser = null;
                          _isSmsChecked = _isEmailChecked = false;
                          // });
                          print("moved");
                        },
                        isSearchEnabled: true,
                        prefixIconData: null, // Icons.account_balance_outlined,
                        onCrossPressed: () {
                          _selectedAppUser = AppUser(currentUserItem.senderId, currentUserItem.senderDomainName, currentUserItem.enSenderName, currentUserItem.arSenderName, -1, -1, -1, -1, null, null, -1, false, currentUserItem.senderSendSMS, currentUserItem.senderSendEmail, currentUserItem.senderOuId, currentUserItem.regOuId,
                              currentUserItem.enSenderOuName, currentUserItem.arSenderOuName, false);
                          setState(() {
                            _selectedOu = null;
                          });
                          // print("moved2");
                        },
                      )
                    else if (screen == 2)
                      Dropdown2(
                        refresh: true,
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
                          _selectedAppUser = item;
                          if (_selectedAppUser != null) {
                            _isSmsChecked = _selectedAppUser!.isSMSNotificationsOn;
                            _isEmailChecked = _selectedAppUser!.isEmailNotificationsOn;
                          } else {
                            _isSmsChecked = _isEmailChecked = false;
                          }
                          // if (_selectedAppUser != null) goToNextPg();
                          // setState(() {
                          //   if (_selectedAppUser != null) goToNextPg();
                          // });
                        },
                        isSearchEnabled: true,
                        isDropdownEnabled: _selectedOu != null,
                        prefixIconData: null, // Icons.person_2_outlined,
                        onCrossPressed: () {
                          print("cross pressed");
                          setState(() {
                            _selectedAppUser = null;
                          });
                        },
                      )
                    else if (screen == 3)
                      Dropdown2(
                        isLabel: true,
                        isShowBorder: false,
                        listItemType: WfAction,
                        selectedValue: _selectedAction,
                        listItemBinding: ServiceHandler.getWfActions,
                        isValidationRequired: true,
                        isShowTopLabel: false,
                        labelText: lang.selectWfAction,
                        // onDropdownChange: (dynamic item) {
                        //   _selectedAction = item;
                        //   if (item != null) {
                        //     setState(() {
                        //       _selectedActionId = item.actionID;
                        //       screen++;
                        //     });
                        //   }
                        // },
                        onDropdownChange: (dynamic item) async {
                          if (item == null) return;
                          _selectedAction = item;
                          // if (item != null)
                          _selectedActionId = item.actionID;
                          if (!isCmntSelected) UserComment(0, '', '');
                          goToNextPg();
                          // setState(() {
                          //   screen++;
                          // });
                          // await Future.delayed(const Duration(seconds: 1));
                        },
                        isSearchEnabled: false,
                        prefixIconData: null, // Icons.domain_verification_outlined,
                        onCrossPressed: () => setState(() {
                          _selectedAction = null;
                        }),
                      )
                    else if (screen == 4) ...[
                      Dropdown2(
                        isLabel: true,
                        isShowBorder: false,
                        listItemType: UserComment,
                        selectedValue: _selectedComment,
                        isShowTopLabel: false,
                        listItemBinding: ServiceHandler.getUserComments,
                        isValidationRequired: false,
                        labelText: lang.selectComment,
                        onDropdownChange: (dynamic item) {
                          isCmntSelected = true;
                          _selectedComment = item;
                          userCommentController.text = item != null ? item.comment : '';
                        },
                        onCrossPressed: () {
                          if (isCmntSelected) {
                            isCmntSelected = false;
                            setState(() {
                              _selectedComment = null;
                              userCommentController.clear();
                            });
                          }
                        },
                        isSearchEnabled: false,
                        prefixIconData: null, // Icons.comment_outlined,
                      ),
                      SizedBox(height: mHeight * 0.02),
                      Container(
                        height: mHeight * 0.162,
                        // width: double.infinity,
                        // decoration: BoxDecoration(
                        //   border: Border.all(
                        //     width: 1,
                        //     color: Colors.black,
                        //   ),
                        // ),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                // border: Border.all(color: appPrimaryColor, width: 0.5),
                                color: Color(0XFFF1F1F1), //AppHelper.myColor('#ededed'),
                              ),
                              child: TextFormField(
                                controller: userCommentController,
                                maxLines: AppHelper.isMobileDevice(context) ? 4 : 5,
                                decoration: InputDecoration.collapsed(
                                  enabled: true,
                                  // hintStyle: TextStyle(color: ThemeProvider.isDarkMode ? Colors.white54 : Colors.grey.shade400),
                                  hintStyle: TextStyle(color: ThemeProvider.isDarkModeCheck() ? Colors.white54 : Colors.grey.shade400),
                                  hintText: lang.writeComment,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: GestureDetector(
                                onTap: send,
                                child: Container(
                                  height: mHeight * 0.05,
                                  width: mWidth * 0.22,
                                  decoration: BoxDecoration(
                                    color: appPrimaryColor,
                                    borderRadius: BorderRadius.circular(mWidth * 0.05),
                                  ),
                                  child: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else
                      Container(
                        height: mHeight * 0.162,
                        width: mHeight * 0.2,
                        // width: double.infinity,
                        margin: EdgeInsets.only(top: mHeight * 0.067),
                        // decoration: BoxDecoration(
                        //   border: Border.all(
                        //     width: 1,
                        //     color: Colors.red,
                        //   ),
                        // ),
                        child: sending
                            ? Transform.scale(
                                scale: 0.5,
                                child: CircularProgressIndicator(
                                  strokeWidth: mWidth * 0.02,
                                ),
                              )
                            : Column(
                                children: [
                                  Icon(
                                    successResp ? Icons.check_circle_outline : Icons.cancel_schedule_send_rounded,
                                    color: appPrimaryColor,
                                    size: mWidth * 0.18,
                                  ),
                                  SizedBox(
                                    height: mHeight * 0.01,
                                  ),
                                  Text(successResp ? "أرسل بنجاح" : "فشل فى الارسال")
                                ],
                              ),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
