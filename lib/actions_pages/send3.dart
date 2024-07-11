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
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

import '../app_models/app_view_models/db_entities/inbox_Item.dart';
import '../app_models/app_view_models/db_entities/organization_unit.dart';
import '../custom_controls/dropdown2.dart';

import '../custom_controls/recentActionContainer.dart';

class Send3 extends StatefulWidget {
  dynamic selectedItem;
  final bool isFromSearchShortcut;

  Send3({
    super.key,
    required this.selectedItem,
    this.isFromSearchShortcut = false,
  });

  @override
  State<Send3> createState() => _SendState();
}

class _SendState extends State<Send3> {
  GlobalKey<FormState>? sendFormKey;
  OrganizationUnit? _selectedOu;
  AppUser? _selectedAppUser;
  // AppUser? _selectedAppUser = AppUser();
  UserComment? _selectedComment;
  // UserComment? _selectedComment = UserComment(0, '', '');
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
  // late InboxItem currentUserItem;

  @override
  void initState() {
    sendFormKey = GlobalKey<FormState>();

    _isRelatedDocumentsChecked = isRelatedDocumentEnabled();
    if (widget.selectedItem is InboxItem) {
      InboxItem currentItem = widget.selectedItem;
      // currentUserItem = currentItem;
      _selectedAppUser = AppUser(
        currentItem.senderId,
        currentItem.senderDomainName,
        currentItem.enSenderName,
        currentItem.arSenderName,
        -1,
        -1,
        -1,
        -1,
        null,
        null,
        -1,
        false,
        currentItem.senderSendSMS,
        currentItem.senderSendEmail,
        currentItem.senderOuId,
        currentItem.regOuId,
        currentItem.enSenderOuName,
        currentItem.arSenderOuName,
        false,
      );
      _selectedOu = OrganizationUnit(
        currentItem.senderOuId,
        currentItem.arSenderOuName,
        currentItem.enSenderOuName,
        false,
        false,
        null,
        null,
        null,
      );
      if (AppHelper.recentActions.isNotEmpty) {
        _selectedAction = AppHelper.recentActions[0];
        _selectedActionId = AppHelper.recentActions[0].actionID;
      }
      _isEmailChecked = currentItem.senderSendEmail;
      _isSmsChecked = currentItem.senderSendSMS;
    }
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

  bool fieldsAreNotFilled() {
    return (_selectedAppUser == null || _selectedAction == null);
  }

  void showFillAllFieldsSnackBar() {
    AnimatedSnackBar.material(
      "املأ جميع الحقول",
      type: AnimatedSnackBarType.info,
      duration: const Duration(seconds: 3),
    ).show(context);
  }

  void goToNextPg() {
    if (screen == 3) return;
    if (screen == 1 && fieldsAreNotFilled()) {
      showFillAllFieldsSnackBar();
      return;
    }
    setState(() {
      screen++;
    });
  }

  void goToPrevPg() {
    if (screen == 3) return;
    setState(() {
      screen--;
    });
  }

  @override
  Widget build(BuildContext context) {
    var mqContext = MediaQuery.of(context);
    var size = mqContext.size;

    var mHeight = size.height - AppBar().preferredSize.height - mqContext.padding.top - mqContext.padding.bottom;
    var mWidth = size.width;

    bool isMob = AppHelper.isMobileDevice(context);
    bool isPortrait = mqContext.orientation == Orientation.portrait;

    var lang = AppLocalizations.of(context)!;

    Color appPrimaryColor = Theme.of(context).colorScheme.primary;

    SizedBox spaceBwDropdowns = SizedBox(height: mHeight * 0.02);

    double mainBtnsHgt = isMob
        ? mHeight * 0.065
        : isPortrait
            ? mHeight * 0.05
            : mHeight * 0.07;
    double mainBtnsWdt = isMob
        ? mWidth * 0.37
        : isPortrait
            ? mWidth * 0.25
            : mWidth * 0.19;
    double mainBtnsTextSize = isMob
        ? mWidth * 0.028
        : isPortrait
            ? mWidth * 0.02
            : mWidth * 0.016;

    void send() async {
      // print("searchign");
      if (screen == 1 && fieldsAreNotFilled()) {
        showFillAllFieldsSnackBar();
        return;
      }
      if (screen != 3) goToNextPg();
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

      bool result = await ServiceHandler.send(
        widget.selectedItem.vsID,
        widget.selectedItem is InboxItem ? AppHelper.getDocumentType(docType: widget.selectedItem.docClassId, needLocal: false) : AppHelper.getDocumentType(docType: AppHelper.getDocumentClassIdByName(widget.selectedItem.classDescription.toLowerCase()), needLocal: false),
        widget.selectedItem is InboxItem ? widget.selectedItem.wobNumber : '',
        finalUsers,
      );

      if (!result) successResp = false;

      setState(() {
        sending = false;
      });

      if (result) {
        AppHelper.isSent = true;
        await Haptics.vibrate(HapticsType.success);
        AppHelper.saveRecentlyUsedActions(_selectedAction!);
      } else
        await Haptics.vibrate(HapticsType.error);
    }

    Widget getHeaderIconBtn(bool isBack) {
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
            color: isBack && (screen == 1 || screen == 3) ? Colors.transparent : null,
            size: isMob
                ? mWidth * 0.0525
                : isPortrait
                    ? mWidth * 0.045
                    : mWidth * 0.04,
          ),
        ),
      );
    }

    void setActionFromRecents(WfAction tappedAction) {
      setState(() {
        _selectedAction = tappedAction;
        _selectedActionId = tappedAction.actionID;
      });
      Haptics.vibrate(HapticsType.light);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: mHeight * 0.65,
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
                  getHeaderIconBtn(true),
                  Text(
                    lang.send,
                    style: TextStyle(
                      fontSize: isMob
                          ? mWidth * 0.045
                          : isPortrait
                              ? mWidth * 0.04
                              : mWidth * 0.035,
                      color: ThemeProvider.isDarkModeCheck() ? Colors.white : Theme.of(context).colorScheme.primary,
                      // fontFamily: Theme.of(context).textTheme.bodyText1!.fontFamily,
                    ),
                  ),
                  getHeaderIconBtn(false),
                ],
              ),
            ),
            SwipeDetector(
              behavior: HitTestBehavior.opaque,
              onSwipeLeft: (offset) {
                // print("left");
                if (screen == 1) return;
                goToPrevPg();
              },
              onSwipeRight: (offset) {
                // print("right");
                if (screen == 2) return;
                goToNextPg();
              },
              child: Container(
                // height: mHeight * 0.34,
                // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
                padding: EdgeInsets.symmetric(horizontal: mWidth * 0.08),
                child: Column(
                  children: [
                    if (screen != 3) // progress bar
                      Container(
                        margin: EdgeInsets.symmetric(vertical: mHeight * 0.03),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(mWidth * 0.05),
                          child: StepProgressIndicator(
                            totalSteps: 2,
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
                      ),
                    //
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        // return ScaleTransition(scale: animation, child: child);
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: screen == 1
                          ? Column(
                              key: const ValueKey<int>(1),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Dropdown2(
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
                                spaceBwDropdowns,
                                Dropdown2(
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
                                spaceBwDropdowns,
                                Dropdown2(
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
                                spaceBwDropdowns,
                                for (WfAction anAction in AppHelper.recentActions)
                                  if (anAction != AppHelper.recentActions[0])
                                    RecentActionContainer(
                                      anAction.arActionName,
                                      mHeight,
                                      mWidth,
                                      () => setActionFromRecents(anAction),
                                    ),
                                // spaceBwDropdowns,
                                Container(
                                  width: mWidth * 0.8,
                                  // margin: EdgeInsets.only(top: mHeight * 0.02),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppHelper.getRoundedBtn(
                                        "إرسال بدون إضافة تعليق",
                                        appPrimaryColor,
                                        () {
                                          if (fieldsAreNotFilled()) {
                                            showFillAllFieldsSnackBar();
                                            return;
                                          }
                                          setState(() {
                                            screen = 3;
                                          });
                                          send();
                                        },
                                        mainBtnsHgt,
                                        mainBtnsWdt,
                                        mainBtnsTextSize,
                                      ),
                                      AppHelper.getRoundedBtn(
                                        "إضافة تعليق وإرسال",
                                        const Color(0XFFA19576),
                                        goToNextPg,
                                        mainBtnsHgt,
                                        mainBtnsWdt,
                                        mainBtnsTextSize,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : (screen == 2)
                              ? Column(
                                  key: const ValueKey<int>(2),
                                  children: [
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
                                      height: isMob
                                          ? mHeight * 0.162
                                          : isPortrait
                                              ? mHeight * 0.15
                                              : mHeight * 0.18,
                                      // width: double.infinity,
                                      // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: isMob
                                                ? mHeight * 0.162
                                                : isPortrait
                                                    ? mHeight * 0.13
                                                    : mHeight * 0.162,
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                              // border: Border.all(color: Colors.black, width: 1),
                                              color: Color(0XFFF1F1F1), //AppHelper.myColor('#ededed'),
                                            ),
                                            child: TextFormField(
                                              controller: userCommentController,
                                              maxLines: isMob ? 4 : 5,
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
                                  ],
                                )
                              : Container(
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
                                  key: const ValueKey<int>(3),
                                  child: sending
                                      ? Transform.scale(
                                          scale: isMob
                                              ? 0.5
                                              : isPortrait
                                                  ? 0.5
                                                  : 0.5,
                                          child: CircularProgressIndicator(strokeWidth: mWidth * 0.02),
                                        )
                                      : Column(
                                          children: [
                                            Icon(
                                              successResp ? Icons.check_circle_outline : Icons.cancel_schedule_send_rounded,
                                              color: appPrimaryColor,
                                              // size: mWidth * 0.18,
                                              size: isMob
                                                  ? mWidth * 0.18
                                                  : isPortrait
                                                      ? mWidth * 0.15
                                                      : mWidth * 0.1,
                                            ),
                                            SizedBox(
                                              height: mHeight * 0.01,
                                            ),
                                            Text(successResp ? "أرسل بنجاح" : "فشل فى الارسال")
                                          ],
                                        ),
                                ),
                    ),
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
