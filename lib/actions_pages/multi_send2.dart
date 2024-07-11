// import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/app_user.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/sent_Item.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/user_comment.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/wf_action.dart';
import 'package:tawasol/app_models/app_view_models/send_user.dart';
import 'package:tawasol/app_models/service_models/service_handler.dart';
import 'package:tawasol/custom_controls/my_button.dart';
import '../app_models/app_utilities/app_routes.dart';
import '../app_models/app_view_models/db_entities/inbox_Item.dart';
import '../app_models/app_view_models/db_entities/organization_unit.dart';
import '../custom_controls/dropdown2.dart';
import '../custom_controls/recentActionContainer.dart';
import '../custom_controls/recentRcptContainer.dart';
import '../theme/theme_provider.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
// import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
//
// import 'package:multi_dropdown/enum/app_enums.dart';
// import 'package:multi_dropdown/models/chip_config.dart';
// import 'package:multi_dropdown/models/network_config.dart';
// import 'package:multi_dropdown/models/value_item.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
// import 'package:multi_dropdown/widgets/hint_text.dart';
// import 'package:multi_dropdown/widgets/selection_chip.dart';
// import 'package:multi_dropdown/widgets/single_selected_item.dart';

class MultiSend2 extends StatefulWidget {
  List selectedItems;
  final bool isFromSearchShortcut;

  MultiSend2({
    super.key,
    required this.selectedItems,
    this.isFromSearchShortcut = false,
  });

  @override
  State<MultiSend2> createState() => _MultiSendState();
}

class _MultiSendState extends State<MultiSend2> {
  GlobalKey<FormState>? multiSendFormKey = GlobalKey<FormState>();

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
  TextEditingController userCommentController = TextEditingController();
  // final TextEditingController _userEditTextController = TextEditingController();

  int screen = 1;
  int rcptScreen = 1;
  bool sending = true, successResp = true, loadingDepUsers = true, rcvngDeps = true, checkedValue = true;
  // bool settingSelectedUsersForAction = true;
  // bool preparingUserModelList = true;

  late List<OrganizationUnit> rcvdOrgs;
  List<AppUser> rcvdDepUsers = [];
  final MultiSelectController multiSelectCtrl = MultiSelectController();

  List<ValueItem> setDepUsersForDropdown = [];
  List<ValueItem> unSetselectedUsers = [];
  // List<ValueItem> dropDownSelectedOps = [];
  List<AppUser> selectedRecentUsers = []; // for final check

  List<AppUser> selectedUsers = []; // for final check
  List<Map> actionAndCmntOfSelectedUsers = [];

  // for displays
  List<WfAction?> selectedActions = [];
  List<UserComment?> selectedComments = [];

  // @override
  // void initState() {
  //   if (AppHelper.currentUserSession.ouId != -1) {
  //     _selectedOu = OrganizationUnit(
  //       AppHelper.currentUserSession.ouId,
  //       AppHelper.currentUserSession.arOuName,
  //       AppHelper.currentUserSession.enOuName,
  //       AppHelper.currentUserSession.hasRegistry,
  //       false,
  //       null,
  //       null,
  //       null,
  //     );
  //   }
  //   super.initState();
  // }

  @override
  void initState() {
    callProvs();
    super.initState();
  }

  void callProvs() async {
    rcvdOrgs = await ServiceHandler.getAllOUs();
    for (OrganizationUnit rcvdOrg in rcvdOrgs) {
      if (AppHelper.currentUserSession.arOuName == rcvdOrg.arOuName) {
        _selectedOu = rcvdOrg;
        break;
      }
    }
    setState(() {
      rcvngDeps = false;
    });
  }

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

  Future<void> prepareUserModelListModified() async {
    for (int i = 0; i < selectedUsers.length; i++) {
      SendUserModel userModel = SendUserModel();
      userModel.userComment = actionAndCmntOfSelectedUsers[i]["comment"];
      // print("passed1");
      userModel.actionName = actionAndCmntOfSelectedUsers[i]["action"];
      // print("action name");
      // print(actionAndCmntOfSelectedUsers[i]["action"]);
      // print("passed2");
      userModel.appUserName = selectedUsers[i].appUserName;
      // print("passed3");
      userModel.ouName = selectedUsers[i].ouName;
      // print("passed4");
      userModel.selectedOuId = selectedUsers[i].ouId;
      // print("passed5");
      userModel.isEmailChecked = _isEmailChecked;
      // print("passed6");
      userModel.isSecureCommentChecked = _isSecureCommentChecked;
      // print("passed7");
      userModel.isSMSChecked = _isSmsChecked;
      // print("passed8");
      userModel.isRelatedDocumentChecked = _isRelatedDocumentsChecked;
      // print("passed9");
      userModel.selectedAction = actionAndCmntOfSelectedUsers[i]["actionId"];
      // print("passed10");
      userModel.loginName = selectedUsers[i].loginName;
      // print("passed11");
      userModel.selectedUserId = selectedUsers[i].id;
      // print("passed12");
      sendUserList.add(userModel);
      // print("passed13");
    }
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

  // void setSelectedUsersforSelectingAction() async {
  //   sendUserList.clear();
  //   for (ValueItem selectedUser in unSetselectedUsers) {
  //     // setSelectedUsers.add(
  //     //   // ValueItem(label: rcvdDepUser.appUserName, value: rcvdDepUser.id),
  //     //   _selectedAppUser
  //     // );
  //     SendUserModel userModel = SendUserModel();
  //     userModel.userComment = userCommentController.text;
  //     userModel.actionName = _selectedAction!.actionName;
  //     userModel.appUserName = _selectedAppUser!.appUserName;
  //     userModel.ouName = _selectedAppUser!.ouName;
  //     userModel.selectedOuId = _selectedAppUser!.ouId;
  //     userModel.isEmailChecked = _isEmailChecked;
  //     userModel.isSecureCommentChecked = _isSecureCommentChecked;
  //     userModel.isSMSChecked = _isSmsChecked;
  //     userModel.isRelatedDocumentChecked = _isRelatedDocumentsChecked;
  //     userModel.selectedAction = _selectedAction!.actionID;
  //     userModel.loginName = _selectedAppUser!.loginName;
  //     userModel.selectedUserId = _selectedAppUser!.id;
  //     sendUserList.add(userModel);
  //   }
  //   setState(() {
  //     settingSelectedUsersForAction = false;
  //   });
  // }

  void createListForSavingActionsAndComments() async {
    //
    for (var unSetselectedUser in unSetselectedUsers) {
      int userID = unSetselectedUser.value;
      for (AppUser rcvdDepUser in rcvdDepUsers) {
        if (rcvdDepUser.id == userID) {
          selectedUsers.add(rcvdDepUser);
          break;
        }
      }
    }
    for (AppUser aUser in selectedRecentUsers) {
      unSetselectedUsers.add(ValueItem(label: aUser.arAppUserName, value: aUser.id));
    }
    for (AppUser aUser in selectedRecentUsers) {
      selectedUsers.add(aUser);
    }
    //
    //
    actionAndCmntOfSelectedUsers = [];
    for (ValueItem unSetselectedUser in unSetselectedUsers) {
      actionAndCmntOfSelectedUsers.add({
        "action": "",
        "actionId": "",
        "commment": "",
      });
    }
    // creating lists for action & comments for displaying at ui:
    selectedActions = List<WfAction?>.filled(unSetselectedUsers.length, null);
    selectedComments = List<UserComment?>.filled(unSetselectedUsers.length, null);
  }

  void showSnackBar(String content) {
    AnimatedSnackBar.material(
      content,
      type: AnimatedSnackBarType.info,
      duration: const Duration(seconds: 3),
    ).show(context);
  }

  void handleNextUser() {
    if (_selectedAction == null) {
      showSnackBar("الرجاء تحديد الإجراء§");
      return;
    }
    // print("here");
    _selectedAction = selectedActions[rcptScreen];
    // print("here2");
    userCommentController.text = actionAndCmntOfSelectedUsers[rcptScreen]["comment"] ?? "";
    setState(() {
      rcptScreen++;
    });
  }

  void handlePrevUser() {
    _selectedAction = selectedActions[rcptScreen - 2];
    userCommentController.text = actionAndCmntOfSelectedUsers[rcptScreen - 2]["comment"] ?? "";
    setState(() {
      rcptScreen--;
    });
  }

  void goToPrevPg() {
    // if (loadingDepUsers || rcvngDeps || settingSelectedUsersForAction) return;
    if (screen == 4) return;
    if (rcptScreen != 1) {
      handlePrevUser();
    } else if (screen > 1) {
      setState(() {
        screen--;
      });
    }
  }

  void applyActionAndCmntToAllUsers() {
    if (rcptScreen == 1 && checkedValue && selectedUsers.length > 1) {
      Map actionAndCmnt = actionAndCmntOfSelectedUsers[0];
      for (int i = 1; i < selectedUsers.length; i++) {
        selectedActions[i] = _selectedAction;
        selectedComments[i] = _userComment;
        actionAndCmntOfSelectedUsers[i] = actionAndCmnt;
      }
    }
  }

  void setActionFromRecents(WfAction tappedAction) {
    setState(() {
      _selectedAction = tappedAction;
      _selectedActionId = tappedAction.actionID;
      selectedActions[rcptScreen - 1] = tappedAction;
    });
    actionAndCmntOfSelectedUsers[rcptScreen - 1]["action"] = _selectedAction?.arActionName;
    actionAndCmntOfSelectedUsers[rcptScreen - 1]["actionId"] = _selectedAction?.actionID;
    applyActionAndCmntToAllUsers();
    Haptics.vibrate(HapticsType.light);
  }

  void setUserFromRecents(WfAction tappedAction) {
    setState(() {
      _selectedAction = tappedAction;
      _selectedActionId = tappedAction.actionID;
    });
    Haptics.vibrate(HapticsType.light);
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

    double spaceBwContsinActionScreen = mHeight * 0.01;
    double circularBarWdt = isMob
        ? mWidth * 0.02
        : isPortrait
            ? mWidth * 0.01
            : mWidth * 0.01;

    void multiSend() async {
      // if()
      if (_selectedAction == null) {
        showSnackBar("الرجاء تحديد الإجراء");
        return;
      }
      setState(() {
        screen = 4;
      });
      // print("passed");
      await prepareUserModelListModified();
      // print("passed234");
      // need to prepare userModalList first
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
            isSentItem: selectedItem is SentItem);
        if (!result) failedItemsSubject.add(selectedItem.docSubject);
      }

      AppHelper.isSent = true;

      if (failedItemsSubject.isEmpty) {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //     content: Text(
        //   lang.sendSuccess,
        // )));

        await Haptics.vibrate(HapticsType.success);
        AppHelper.saveRecentlyUsedActions(selectedActions[0]!);
        AppHelper.saveRecentlyUsedUsers(selectedUsers);
      } else {
        successResp = false;
        await Haptics.vibrate(HapticsType.error);
        //
        String failedSubjects = "";
        for (var subject in failedItemsSubject) failedSubjects += subject + ", ";
        failedSubjects = failedSubjects.substring(0, failedSubjects.length - 2);
        showSnackBar(lang.multiSendFailedFor + ": " + failedSubjects);
      }

      setState(() {
        sending = false;
      });
    }

    Widget getBtnCont(bool isBack) {
      return GestureDetector(
        onTap: isBack ? goToPrevPg : () => Navigator.of(context).pop(),
        child: Container(
          // height: double.infinity,
          width: mHeight * 0.055,
          // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
          child: Icon(
            isBack ? Icons.arrow_back_ios_new : Icons.close,
            color: isBack && (screen == 1 || screen == 4) ? Colors.transparent : null,
            size: isMob
                ? mWidth * 0.0525
                : isPortrait
                    ? mWidth * 0.045
                    : mWidth * 0.037,
          ),
        ),
      );
    }

    void goToNextPg() async {
      if (screen < 3) {
        // if ((screen == 1 && _selectedOu == null) || (screen == 2 && unSetselectedUsers.isEmpty) || (screen == 3 && actionAndCmntOfSelectedUsers[rcptScreen]["action"].isEmpty)) return;
        if ((screen == 1 && _selectedOu == null) || (screen == 2 && (unSetselectedUsers.isEmpty && selectedRecentUsers.isEmpty)) || (screen == 3 && actionAndCmntOfSelectedUsers[rcptScreen]["action"].isEmpty)) return;
        if (screen == 1) loadingDepUsers = true;
        setState(() {
          screen++;
        });
        if (screen == 2) {
          // print("2nd");
          // List rcvdDepUsers = await ServiceHandler.getAllUsersByOUs(_selectedOu!.ouID, _selectedOu!.ouID == _selectedOu!.regOuID);
          // print(_selectedOu!.ouID);
          rcvdDepUsers = await ServiceHandler.getAllUsersByOUs(_selectedOu!.ouID, true);
          // List rcvdDepUsers = await ServiceHandler.getAllUsersByOUs(3, true);
          // print("rcvdDepUsers");
          // print(rcvdDepUsers);
          for (AppUser rcvdDepUser in rcvdDepUsers) {
            bool addd = true;
            // for (AppUser aUser in AppHelper.recentUsers) {
            //   if (aUser.id == rcvdDepUser.id) {
            //     addd = false;
            //     break;
            //   }
            // }
            for (int i = 0; i < AppHelper.recentUsers.length; i++) {
              if (AppHelper.recentUsers[i].id == rcvdDepUser.id) {
                AppHelper.recentUsers[i] = rcvdDepUser;
                addd = false;
                break;
              }
            }
            if (addd)
              setDepUsersForDropdown.add(
                ValueItem(label: rcvdDepUser.appUserName, value: rcvdDepUser.id),
              );
          }
          setState(() {
            loadingDepUsers = false;
          });
        } else if (screen == 3) {
          // setSelectedUsersforSelectingAction();
          createListForSavingActionsAndComments();
        }
      } else {
        // if (actionAndCmntOfSelectedUsers[rcptScreen]["action"].isEmpty) return;
        // if (rcptScreen == selectedUsers.length) {
        if ((rcptScreen == selectedUsers.length) || (rcptScreen == 1 && checkedValue)) {
          multiSend();
        } else {
          handleNextUser();
        }
      }
    }

    // void handleButtonPress() {
    //   if (screen < 3 || rcptScreen < selectedUsers.length)
    //     goToNextPg();
    //   else {
    //     multiSend();
    //   }
    // }

    bool isRecentUserSelected(AppUser userr) {
      if (selectedRecentUsers.contains(userr)) return true;
      return false;
    }

    void handleRecentUserPress(AppUser userr) {
      if (selectedRecentUsers.contains(userr))
        selectedRecentUsers.remove(userr);
      else
        selectedRecentUsers.add(userr);
      setState(() {});
      Haptics.vibrate(HapticsType.light);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: isMob
            ? mHeight * 0.88
            : isPortrait
                ? mHeight * 0.65
                : mHeight * 0.75,
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
                    lang.multiSend,
                    style: TextStyle(
                      // fontSize: mWidth * 0.045,
                      fontSize: isMob
                          ? mWidth * 0.045
                          : isPortrait
                              ? mWidth * 0.04
                              : mWidth * 0.03,
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
                // print("left");
                if (screen == 1) return;
                goToPrevPg();
              },
              onSwipeRight: (offset) {
                // print("right");
                if (screen == 3) return;
                goToNextPg();
              },
              child: Container(
                // height: mHeight * 0.45,
                // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
                padding: EdgeInsets.symmetric(horizontal: mWidth * 0.08),
                child: Column(
                  children: [
                    if (screen != 4)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: mHeight * 0.03),
                        // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
                        // color: Colors.brown,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(mWidth * 0.05),
                          child: StepProgressIndicator(
                            totalSteps: 3,
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
                            // customStep: (index, color, _) => Container(
                            //   width: 2,
                            //   decoration: BoxDecoration(
                            //     color: color,
                            //     borderRadius: BorderRadius.circular(10),
                            //   ),
                            // ),
                          ),
                        ),
                      ),
                    //
                    Container(
                      height: AppHelper.isMobileDevice(context)
                          ? mHeight * 0.65
                          : isPortrait
                              ? mHeight * 0.42
                              : mHeight * 0.48,
                      // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          // return ScaleTransition(scale: animation, child: child);
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: screen == 1
                            ? Column(
                                key: const ValueKey<int>(1),
                                children: [
                                  rcvngDeps
                                      ? Transform.scale(
                                          scale: 0.5,
                                          child: CircularProgressIndicator(strokeWidth: circularBarWdt),
                                        )
                                      : Dropdown2(
                                          isLabel: true,
                                          isShowBorder: false,
                                          listItemType: OrganizationUnit,
                                          selectedValue: _selectedOu,
                                          isShowTopLabel: false,
                                          listItemBinding: ServiceHandler.getAllOUs,
                                          isValidationRequired: true,
                                          labelText: lang.selectOU,
                                          onDropdownChange: (dynamic item) {
                                            // setState(() {
                                            _selectedOu = item;
                                            _selectedAppUser = null;
                                            _isSmsChecked = _isEmailChecked = false;
                                            // });
                                          },
                                          isSearchEnabled: true,
                                          prefixIconData: null, // Icons.account_balance_outlined,
                                        )
                                ],
                              )
                            : screen == 2
                                ? Align(
                                    alignment: Alignment.topCenter,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        key: const ValueKey<int>(2),
                                        // mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          if (loadingDepUsers)
                                            Transform.scale(
                                              scale: 0.5,
                                              child: CircularProgressIndicator(strokeWidth: circularBarWdt),
                                            )
                                          else ...[
                                            MultiSelectDropDown(
                                              // showClearIcon: true,
                                              // selectedOptions: dropDownSelectedOps,
                                              // selectedOptions: [setDepUsersForDropdown[0]],
                                              // selectedOptions: const <ValueItem>[
                                              //   ValueItem(label: 'Option 1', value: '1'),
                                              //   ValueItem(label: 'Option 2', value: '2'),
                                              //   ValueItem(label: 'Option 3', value: '3'),
                                              //   ValueItem(label: 'Option 4', value: '4'),
                                              //   ValueItem(label: 'Option 5', value: '5'),
                                              //   ValueItem(label: 'Option 6', value: '6'),
                                              //   ValueItem(label: 'Option 6', value: '7'),
                                              //   ValueItem(label: 'Option 6', value: '8'),
                                              //   ValueItem(label: 'Option 6', value: '9'),
                                              //   ValueItem(label: 'Option 6', value: '10'),
                                              //   ValueItem(label: 'Option 6', value: '11'),
                                              //   ValueItem(label: 'Option 6', value: '12'),
                                              //   ValueItem(label: 'Option 6', value: '13'),
                                              //   ValueItem(label: 'Option 6', value: '14'),
                                              //   ValueItem(label: 'Option 6', value: '15'),
                                              //   ValueItem(label: 'Option 6', value: '16'),
                                              //   ValueItem(label: 'Option 6', value: '17'),
                                              //   ValueItem(label: 'Option 6', value: '18'),
                                              //   ValueItem(label: 'Option 6', value: '19'),
                                              //   ValueItem(label: 'Option 6', value: '20'),
                                              //   ValueItem(label: 'Option 6', value: '21'),
                                              //   ValueItem(label: 'Option 6', value: '22'),
                                              //   ValueItem(label: 'Option 6', value: '23'),
                                              // ],
                                              controller: multiSelectCtrl,
                                              onOptionSelected: (options) {
                                                // mySelectedItems = options;
                                                // debugPrint(options.toString());
                                                unSetselectedUsers = options;
                                                actionAndCmntOfSelectedUsers.clear();
                                              },
                                              // options: const <ValueItem>[
                                              //   ValueItem(label: 'Option 1', value: '1'),
                                              //   ValueItem(label: 'Option 2', value: '2'),
                                              //   ValueItem(label: 'Option 3', value: '3'),
                                              //   ValueItem(label: 'Option 4', value: '4'),
                                              //   ValueItem(label: 'Option 5', value: '5'),
                                              //   ValueItem(label: 'Option 6', value: '6'),
                                              //   ValueItem(label: 'Option 6', value: '7'),
                                              //   ValueItem(label: 'Option 6', value: '8'),
                                              //   ValueItem(label: 'Option 6', value: '9'),
                                              //   ValueItem(label: 'Option 6', value: '10'),
                                              //   ValueItem(label: 'Option 6', value: '11'),
                                              //   ValueItem(label: 'Option 6', value: '12'),
                                              //   ValueItem(label: 'Option 6', value: '13'),
                                              //   ValueItem(label: 'Option 6', value: '14'),
                                              //   ValueItem(label: 'Option 6', value: '15'),
                                              //   ValueItem(label: 'Option 6', value: '16'),
                                              //   ValueItem(label: 'Option 6', value: '17'),
                                              //   ValueItem(label: 'Option 6', value: '18'),
                                              //   ValueItem(label: 'Option 6', value: '19'),
                                              //   ValueItem(label: 'Option 6', value: '20'),
                                              //   ValueItem(label: 'Option 6', value: '21'),
                                              //   ValueItem(label: 'Option 6', value: '22'),
                                              //   ValueItem(label: 'Option 6', value: '23')
                                              // ],
                                              options: setDepUsersForDropdown,
                                              // options: [],
                                              // maxItems: 2,
                                              // disabledOptions: [setDepUsersForDropdown[0]],
                                              selectionType: SelectionType.multi,
                                              chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                                              // dropdownHeight: 300,
                                              optionTextStyle: const TextStyle(
                                                fontSize: 16,
                                                // color: Colors.red,
                                              ),
                                              selectedOptionIcon: const Icon(
                                                Icons.check_circle,
                                                // color: Colors.red,
                                              ),
                                              selectedOptionBackgroundColor: appPrimaryColor,
                                              hint: lang.selectOuUser,
                                              // selectedOptionTextColor: Colors.red,
                                              fieldBackgroundColor: const Color(0XFFF1F1F1),
                                              // fieldBackgroundColor: Colors.amber,
                                              // optionsBackgroundColor: Colors.red,
                                              // inputDecoration: BoxDecoration(
                                              //   color: appPrimaryColor,
                                              //   borderRadius: BorderRadius.circular(12.0),
                                              //   border: Border.all(
                                              //     color: appPrimaryColor,
                                              //     width: 0.4,
                                              //   ),
                                              // ),
                                              // dropdownBackgroundColor: Colors.purple,
                                              // selectedItemBuilder: (p0, p1) {
                                              //   return GestureDetector(
                                              //     onTap: () {
                                              //       mySelectedItems.remove(p1);
                                              //     },
                                              //     child: Container(
                                              //       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              //       margin: EdgeInsets.symmetric(horizontal: 4),
                                              //       decoration: BoxDecoration(
                                              //         color: appPrimaryColor,
                                              //         borderRadius: BorderRadius.circular(8),
                                              //       ),
                                              //       child: Text(
                                              //         p1.label,
                                              //         style: TextStyle(color: Colors.white),
                                              //       ),
                                              //     ),
                                              //   );
                                              // },
                                            ),
                                            SizedBox(height: spaceBwContsinActionScreen),
                                            for (AppUser aUser in AppHelper.recentUsers)
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: RecentRcptContainer(
                                                  aUser.arAppUserName,
                                                  mHeight,
                                                  mWidth,
                                                  () => handleRecentUserPress(aUser),
                                                  isRecentUserSelected(aUser),
                                                  appPrimaryColor,
                                                ),
                                              ),
                                          ]
                                        ],
                                      ),
                                    ),
                                  )
                                : screen == 3
                                    ? Column(
                                        key: const ValueKey<int>(3),
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(unSetselectedUsers[rcptScreen - 1].label),
                                          Dropdown2(
                                            isLabel: true,
                                            isShowBorder: false,
                                            listItemType: WfAction,
                                            // selectedValue: _selectedAction,
                                            selectedValue: selectedActions[rcptScreen - 1],
                                            listItemBinding: ServiceHandler.getWfActions,
                                            isValidationRequired: true,
                                            isShowTopLabel: false,
                                            labelText: lang.selectWfAction,
                                            onDropdownChange: (dynamic item) {
                                              selectedActions[rcptScreen - 1] = item;
                                              _selectedAction = item;
                                              if (item != null) {
                                                setState(() {
                                                  _selectedActionId = item.actionID;
                                                });
                                              }
                                              actionAndCmntOfSelectedUsers[rcptScreen - 1]["action"] = _selectedAction?.arActionName;
                                              actionAndCmntOfSelectedUsers[rcptScreen - 1]["actionId"] = _selectedAction?.actionID;
                                              applyActionAndCmntToAllUsers();
                                            },
                                            isSearchEnabled: false,
                                            prefixIconData: null, //Icons.domain_verification_outlined,
                                          ),
                                          SizedBox(height: spaceBwContsinActionScreen),
                                          for (WfAction anAction in AppHelper.recentActions)
                                            if (anAction != AppHelper.recentActions[0])
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: RecentActionContainer(
                                                  anAction.arActionName,
                                                  mHeight,
                                                  mWidth,
                                                  () => setActionFromRecents(anAction),
                                                ),
                                              ),
                                          SizedBox(height: spaceBwContsinActionScreen),
                                          Dropdown2(
                                            isLabel: true,
                                            listItemType: UserComment,
                                            // selectedValue: _userComment,
                                            selectedValue: selectedComments[rcptScreen - 1],
                                            isShowBorder: false,
                                            isShowTopLabel: false,
                                            listItemBinding: ServiceHandler.getUserComments,
                                            isValidationRequired: false,
                                            labelText: lang.selectComment,
                                            onDropdownChange: (dynamic item) {
                                              selectedComments[rcptScreen - 1] = item;
                                              _userComment = item;
                                              userCommentController.text = item != null ? item.comment : '';
                                              actionAndCmntOfSelectedUsers[rcptScreen - 1]["comment"] = item != null ? item.comment : '';
                                              applyActionAndCmntToAllUsers();
                                            },
                                            isSearchEnabled: false,
                                            prefixIconData: null, //Icons.comment_outlined,
                                          ),
                                          SizedBox(height: spaceBwContsinActionScreen),
                                          Container(
                                            height: mHeight * 0.162,
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                              // border: Border.all(color: appPrimaryColor, width: 0.5),
                                              color: Color(0XFFF1F1F1), //AppHelper.myColor('#ededed'),
                                            ),
                                            child: TextFormField(
                                              controller: userCommentController,
                                              maxLines: AppHelper.isMobileDevice(context) ? 4 : 5,
                                              textInputAction: TextInputAction.done,
                                              decoration: InputDecoration.collapsed(
                                                enabled: true,
                                                // hintStyle: TextStyle(color: ThemeProvider.isDarkMode ? Colors.white54 : Colors.grey.shade400),
                                                hintStyle: TextStyle(color: ThemeProvider.isDarkModeCheck() ? Colors.white54 : Colors.grey.shade400),
                                                hintText: lang.writeComment,
                                              ),
                                              onChanged: (value) {
                                                // print(value);
                                                actionAndCmntOfSelectedUsers[rcptScreen - 1]["comment"] = value;
                                              },
                                            ),
                                          ),
                                          SizedBox(height: spaceBwContsinActionScreen),
                                          if (unSetselectedUsers.length > 1 && rcptScreen == 1)
                                            CheckboxListTile(
                                              title: Text(
                                                "قم بتطبيق هذا الإجراء والتعليق على جميع المستلمين",
                                                style: TextStyle(
                                                  fontSize: isMob
                                                      ? mWidth * 0.028
                                                      : isPortrait
                                                          ? mWidth * 0.024
                                                          : mWidth * 0.017,
                                                ),
                                              ),
                                              value: checkedValue,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  checkedValue = newValue!;
                                                });
                                              },
                                              controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
                                            )
                                        ],
                                      )
                                    : Container(
                                        key: const ValueKey<int>(4),
                                        height: mHeight * 0.162,
                                        width: mHeight * 0.2,
                                        // width: double.infinity,
                                        margin: EdgeInsets.only(top: mHeight * 0.067),
                                        // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.red)),
                                        child: sending
                                            ? Transform.scale(
                                                scale: 0.5,
                                                child: CircularProgressIndicator(strokeWidth: mWidth * 0.02),
                                              )
                                            : Column(
                                                children: [
                                                  Icon(
                                                    successResp ? Icons.check_circle_outline : Icons.cancel_schedule_send_rounded,
                                                    color: appPrimaryColor,
                                                    size: isMob
                                                        ? mWidth * 0.18
                                                        : isPortrait
                                                            ? mWidth * 0.15
                                                            : mWidth * 0.1,
                                                  ),
                                                  SizedBox(height: mHeight * 0.01),
                                                  Text(
                                                    successResp ? "أرسل بنجاح" : "فشل فى الارسال",
                                                  )
                                                ],
                                              ),
                                      ),
                      ),
                    ),
                    if (screen != 4) ...[
                      // if (screen != 3) SizedBox(height: mHeight * 0.35),
                      MyButton(
                        // btnText: screen == 3 && checkedValue ? "يرسل" : "التالي",
                        btnText: screen == 3 && (unSetselectedUsers.length == 1 || checkedValue) ? "يرسل" : "التالي",
                        horizontalPadding: isMob
                            ? mWidth * 0.3
                            : isPortrait
                                ? mWidth * 0.2
                                : mWidth * 0.08,
                        //
                        verticalPadding: isMob
                            ? mHeight * 0.02
                            : isPortrait
                                ? mHeight * 0.02
                                : mHeight * 0.03,
                        isLoginButton: true,
                        borderColor: appPrimaryColor,
                        backgroundColor: appPrimaryColor,
                        textColor: Colors.white,
                        onTap: goToNextPg,
                        // onTap: handleButtonPress,
                      ),
                    ]
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
