import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/organization_unit.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/search_result_item.dart';
import 'package:tawasol/app_models/app_view_models/securityLevel.dart';
import 'package:tawasol/app_models/app_view_models/site_bind.dart';
import 'package:tawasol/app_models/service_models/my_service_response.dart';
import 'package:tawasol/app_models/service_models/service_handler.dart';
import 'package:tawasol/app_models/service_models/service_urls.dart';
import 'package:tawasol/app_models/versionProvider.dart';
import 'package:tawasol/main_page/sent.dart';
import 'package:tawasol/main_page/settings.dart';
import 'package:tawasol/theme/theme_provider.dart';
import '../app_models/app_utilities/app_routes.dart';
import './search.dart';
import 'follow_up.dart';
import 'inbox.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';

import 'search2.dart';

class Dashboard extends StatefulWidget {
  Dashboard({super.key, this.passedIndex});

  int? passedIndex;

  // Function(int index) rEnableMultiSelect;

  // Dashboard({
  //   required this.rEnableMultiSelect,
  // });

  // final Search? searchScreen;

  // Dashboard(Search: searchScreen);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  _DashboardState() {
    bindLists();
  }

  int _selectedIndex = 0;
  String pageTitle = '';

  // late var department;
  List userDepartmentsList = AppHelper.currentUserSession.userDepartments.where((department) => department.arOuName != AppHelper.currentUserSession.arOuName).toList();

  // Department? department;
  //============For Inbox Screen=============
  bool multiSelectMode = false;
  List selectedMailIndexes = [];

  //=========================================
  //============For Search Screen============
  SiteBind? siteType;
  SiteBind? mainSite;
  SiteBind? subSite;
  String? selectedYear;
  SecurityLevel? selectedSecurityLevel;
  TextEditingController subjectController = TextEditingController();
  TextEditingController serialNumberController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  List<String> yearList = [];
  final searchFormKey = GlobalKey<FormState>();
  late int currentSelectedYear;
  late bool isSelectedYearCurrent;
  OrganizationUnit? selectedSearchOu = AppHelper.getCurrentUserOuList()[0];
  GroupButtonController topBarController = GroupButtonController(selectedIndex: 0);
  bool isShowSites = true;
  String? selectedApproveYear;
  DateTime? approveStartDate;
  DateTime? docDateFrom;
  bool isCurrentDepartment = false;
  DateTime? approveEndDate;
  DateTime? docDateTo;
  TextEditingController docDateFromController = TextEditingController();
  TextEditingController docDateToController = TextEditingController();
  TextEditingController approveStartDateController = TextEditingController();
  TextEditingController approveEndDateController = TextEditingController();

  //=========================================

  //============For Inbox Screen=============
  void enableMultiSelect() {
    if (!multiSelectMode) {
      setState(() {
        // selectedMailIndexes.add(index);
        multiSelectMode = true;
      });
    }
  }

  //=========================================

  //============For Inbox Screen=============
  void disableMultiSelect() {
    setState(() {
      selectedMailIndexes = [];
      // selectedMailIndexes.clear();
      multiSelectMode = false;
    });
  }

  void disableMultiSelectWithoutSetState() {
    selectedMailIndexes = [];
    multiSelectMode = false;
  }

  // Color lightenClr(Color c, [int percent = 10]) {
  //   assert(1 <= percent && percent <= 100);
  //   var p = percent / 100;
  //   return Color.fromARGB(
  //     c.alpha,
  //     c.red + ((255 - c.red) * p).round(),
  //     c.green + ((255 - c.green) * p).round(),
  //     c.blue + ((255 - c.blue) * p).round(),
  //   );
  // }

  //=========================================

  //============For Search Screen============
  List<String> bindLists() {
    for (int i = 0; i < 25; i++) {
      yearList.add((DateTime.now().year - i).toString());
    }
    selectedYear = yearList[0];
    selectedApproveYear = yearList[0];
    return yearList;
  }

  void resetAllFields() {
    setState(() {
      siteType = null;
      serialNumberController.text = '';
      subjectController.text = '';
      selectedYear = yearList[0];
      selectedSecurityLevel = null;
      subSite = null;
      mainSite = null;
      startDate = null;
      endDate = null;
      startDateController.text = '';
      endDateController.text = '';
      //============Add the new four fields==========
      docDateFromController.text = '';
      docDateToController.text = '';
      approveStartDateController.text = '';
      approveEndDateController.text = '';
      approveStartDate = null;
      approveEndDate = null;
    });
  }

  String getSearchTypeByIndex(int index) {
    switch (index) {
      case 0:
        return AppDefaultKeys.searchTypeGeneral;
      case 1:
        return AppDefaultKeys.searchTypeOutgoing;
      case 2:
        return AppDefaultKeys.searchTypeIncoming;
      case 3:
        return AppDefaultKeys.searchTypeInternal;
      // case 4:
      //   return AppDefaultKeys.searchTypeGeneral;
    }
    return AppDefaultKeys.searchTypeGeneral;
  }

  DateTime convertStringToDateTime(String strDateTime) {
    String strYear = strDateTime.split('/')[2];
    String strMonth = strDateTime.split('/')[1];
    String strDate = strDateTime.split('/')[1];
    return DateTime(int.parse(strYear), int.parse(strMonth), int.parse(strDate));
  }

  int convertStringToDateTimeStamp(String strDateTime) {
    return convertStringToDateTime(strDateTime).millisecondsSinceEpoch;
  }

  void searchForInbox() async {
    try {
      if (searchFormKey.currentState!.validate()) {
        AppHelper.showLoaderDialog(context);
        DateTime finalStartDate;
        DateTime finalEndDate;
        if (startDate != null) {
          finalStartDate = startDate!;
        } else {
          finalStartDate = DateTime(int.parse(selectedYear.toString()), 1, 1);
        }

        if (endDate != null) {
          finalEndDate = endDate!;
        } else {
          finalEndDate = DateTime(int.parse(selectedYear.toString()), isSelectedYearCurrent ? DateTime.now().month : 12, isSelectedYearCurrent ? DateTime.now().day : 31);
        }
        List<SearchResultItem> searchItemList = await ServiceHandler.getSearchResultItems(
          DateFormat("yyyy-MM-dd").format(finalStartDate),
          DateFormat("yyyy-MM-dd").format(finalEndDate),
          selectedSearchOu!.regOuID!.toString(),
          subjectController.text,
          serialNumberController.text == "" ? null : serialNumberController.text,
          getSearchTypeByIndex(topBarController.selectedIndex!),
          selectedSecurityLevel != null ? selectedSecurityLevel!.lookupKey : null,
          siteType != null && isShowSites ? siteType!.siteId : null,
          mainSite != null && isShowSites ? mainSite!.siteId : null,
          subSite != null && isShowSites ? subSite!.siteId : null,
          topBarController.selectedIndex != 1
              ? null
              : approveStartDateController.text.isEmpty
                  ? null
                  : convertStringToDateTimeStamp(approveStartDateController.text),
          topBarController.selectedIndex != 1
              ? null
              : approveEndDateController.text.isEmpty
                  ? null
                  : convertStringToDateTimeStamp(approveEndDateController.text),
          topBarController.selectedIndex != 2
              ? null
              : docDateFromController.text.isEmpty
                  ? null
                  : DateFormat("yyyy-MM-dd").format(convertStringToDateTime(docDateFromController.text)),
          topBarController.selectedIndex != 2
              ? null
              : docDateToController.text.isEmpty
                  ? null
                  : DateFormat("yyyy-MM-dd").format(convertStringToDateTime(docDateToController.text)),
        );
        AppHelper.hideLoader(context);
        if (searchItemList.isEmpty) {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.error,
                  textAlign: TextAlign.center,
                ),
                content: Text(AppLocalizations.of(context)!.noSearchResult),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text(AppLocalizations.of(context)!.ok),
                  ),
                ],
              );
            },
          );
        } else {
          Routes.moveSearchResultView(context, searchItemList, isShowSites);
        }
      }
    } catch (e) {
      AppHelper.hideLoader(context);
      var snackBar = SnackBar(
        content: Text(e.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  //=========================================

  Widget displaySelectedTabContent(BuildContext context) {
    int activateTabContent = _selectedIndex;
    // if (widget.passedIndex != null) {
    //   activateTabContent = _selectedIndex = widget.passedIndex!;
    //   widget.passedIndex = null;
    // }
    if (!AppHelper.currentUserSession.isEmployeeFollowupEnabled && activateTabContent > 1) {
      activateTabContent += 1;
    }
    switch (activateTabContent) {
      case 0:
        {
          return Inbox(
            multiSelectMode: multiSelectMode,
            selectedMailIndexes: selectedMailIndexes,
            enableMultiSelect: enableMultiSelect,
            disableMultiSelect: disableMultiSelect,
          );
          // statements;
        }
      case 1:
        {
          disableMultiSelectWithoutSetState();
          return const SentItemView();
        }
      case 2:
        {
          disableMultiSelectWithoutSetState();
          return const Followup();
        }
      case 3:
        {
          disableMultiSelectWithoutSetState();
          // return const Search();
          return const Search2();
        }
      case 4:
        {
          disableMultiSelectWithoutSetState();
          return const AppSettings();
        }
    }
    return const Center(child: Text('Inbox Clicked'));
  }

  Widget _buildLeadingIcon() {
    if (_selectedIndex == 0) {
      // Show three dots in the Inbox screen
      // return GestureDetector(
      //   // onTap: () {
      //   //   setState(() {
      //   //     multiSelectMode = !multiSelectMode;
      //   //   });
      //   // },
      //   onTap: multiSelectMode ? disableMultiSelect : enableMultiSelect,
      //   child: multiSelectMode
      //       ? Container(
      //           // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
      //           alignment: Alignment.center,
      //           child: Text(
      //             AppLocalizations.of(context)!.cancel,
      //             style: const TextStyle(
      //               fontSize: 16,
      //               color:
      //                   Colors.white,
      //             ),
      //           ),
      //         )
      //       : const Icon(
      //           Icons.more_vert,
      //           color: Colors.white,// ThemeProvider.isDarkMode ? Colors.white : Colors.white,
      //           // Customize the color if needed
      //         ),
      // );
      return multiSelectMode
          ?
          // Container(
          //     margin: const EdgeInsets.only(right: 7),
          //     decoration: BoxDecoration(
          //       border: Border.all(
          //         width: 1,
          //         color: Colors.red,
          //       ),
          //     ),
          //     child: TextButton(
          //       onPressed: disableMultiSelect,
          //       child: Expanded(
          //         child: Container(
          //           // height: 0,
          //           // width: 40,
          //           // padding: const EdgeInsets.all(3),
          //           // padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
          //           decoration: BoxDecoration(
          //             color: ThemeProvider.lightenClr(ThemeProvider.primaryColor, 30),
          //             borderRadius: BorderRadius.circular(12.0),
          //             // border: Border.all(width: 1, color: Colors.red),
          //           ),
          //           child: Text(
          //             AppLocalizations.of(context)!.cancel,
          //             style: const TextStyle(
          //               fontSize: 16,
          //               color: Colors.white,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   )
          GestureDetector(
              onTap: disableMultiSelect,
              child: FittedBox(
                child: Container(
                  height: 28,
                  // width: AppHelper.isCurrentArabic ? 45 : 45,
                  width: 45,
                  // padding: const EdgeInsets.all(3),
                  // padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                  margin: AppHelper.isCurrentArabic ? EdgeInsets.only(right: 7) : EdgeInsets.only(left: 7),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ThemeProvider.lightenClr(ThemeProvider.primaryColor, 12),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: TextStyle(
                      fontSize: AppHelper.isCurrentArabic ? 14 : 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          : IconButton(
              onPressed: enableMultiSelect,
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
            );
    } else if (_selectedIndex == 1) {
      // Show text in the Followup screen
      return const SizedBox.shrink();
      // return Icon(
      //   Icons.search,
      //   color: ThemeProvider.isDarkMode ? Colors.black : Colors.white,
      // Customize the color if needed
      //  );
    } else if (((AppHelper.currentUserSession.isEmployeeFollowupEnabled && _selectedIndex == 3) || (!AppHelper.currentUserSession.isEmployeeFollowupEnabled && _selectedIndex == 2))) {
      return GestureDetector(
        onTap: () {
          // print("search tapped");
          searchForInbox();
        },
        child: Container(
          alignment: Alignment.bottomCenter,
          child: Text(
            AppLocalizations.of(context)!.search1,
            style: TextStyle(fontSize: 18, color: ThemeProvider.isDarkMode ? Colors.black : Colors.white),
          ),
        ),
      );
    } else {
      // For other screens, show an empty container
      return Container();
    }
  }

  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  // final _selectedItemColor = Colors.white;

  //a09275
  // final _unselectedBgColor = Colors.white; // AppHelper.myColor('#ededed');
  int activateTabContent = -1;

  String getPageTitle(BuildContext context, int index) {
    activateTabContent = index;

    if (!AppHelper.currentUserSession.isEmployeeFollowupEnabled && index > 1) {
      activateTabContent += 1;
    }

    switch (activateTabContent) {
      case 0:
        return AppLocalizations.of(context)!.inbox;
      case 1:
        return AppLocalizations.of(context)!.sent;
      case 2:
        return AppLocalizations.of(context)!.followUp;
      case 3:
        return AppLocalizations.of(context)!.search;
      case 4:
        return AppLocalizations.of(context)!.settings;
    }
    return AppLocalizations.of(context)!.noRecordFound;
  }

  // List items = [
  //   "a",
  //   "b",
  //   "c",
  //   "d",
  //   "d",
  //   "d",
  //   "d",
  //   "d",
  //   "d",
  //   "d",
  //   "d",
  //   "d",
  //   "d",
  //   "d",
  //   "d",
  //   "d",
  //   "d",
  //   "d",
  //   "d",
  //   "d",
  //   "d",
  //   "i",
  // ];

  CustomPopupMenuController _menuController = CustomPopupMenuController();

  @override
  Widget build(BuildContext context) {
    // final selectedBgColor = Theme.of(context).colorScheme.primary;
    // final unselectedItemColor = Theme.of(context).colorScheme.primary;
    if (widget.passedIndex != null) {
      _selectedIndex = widget.passedIndex!;
      widget.passedIndex = null;
    }

    Matrix4 transformAll = AppHelper.currentUserSession.isEmployeeFollowupEnabled ? Matrix4.translationValues(-20, 0, 0) : Matrix4.translationValues(-40, 0, 0);
    Matrix4 transformSearch = AppHelper.currentUserSession.isEmployeeFollowupEnabled ? Matrix4.translationValues(-45, 0, 0) : Matrix4.translationValues(-50, 0, 0);
    //==========================================For Search Button===========================================
    currentSelectedYear = int.parse(selectedYear.toString());
    isSelectedYearCurrent = DateTime.now().year == currentSelectedYear;
    //======================================================================================================

    pageTitle = getPageTitle(context, _selectedIndex);
    final double navItemSize = AppHelper.isMobileDevice(context) ? 32 : 25;
    final double navNormalSize = AppHelper.isMobileDevice(context) ? 28 : 25;
    // Color getBgColor(int index) =>
    //     _selectedIndex == index ? selectedBgColor : _unselectedBgColor;
    //

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // backgroundColor: Colors.grey.shade200,
        // backgroundColor: Colors.amber,
        appBar: activateTabContent == 3
            ? null
            : PreferredSize(
                preferredSize: const Size(double.infinity, 75),
                child: AppBar(
                  centerTitle: true,
                  title: Text(
                    pageTitle,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: Colors.white,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  leading: _buildLeadingIcon(),
                  shape: const OvalBorder(side: BorderSide.none),
                  automaticallyImplyLeading: false,
                  actions: <Widget>[
                    // =================================================Pop Up menu button start=============================================
                    if (_selectedIndex == 0)
                      CustomPopupMenu(
                        pressType: PressType.singleClick,
                        arrowSize: 20,
                        showArrow: true,
                        barrierColor: const Color.fromARGB(122, 0, 0, 0),
                        controller: _menuController,
                        arrowColor: Theme.of(context).colorScheme.primary,
                        position: PreferredPosition.bottom,
                        verticalMargin: -10,
                        // horizontalMargin: 15,
                        child: IconButton(
                          icon: const Icon(
                            CupertinoIcons.person_alt_circle,
                            size: 32,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _menuController.showMenu();
                          },
                        ),
                        menuBuilder: () {
                          return Container(
                            // height: 300,
                            width: 320,
                            margin: const EdgeInsets.only(bottom: 10),
                            // color: Theme.of(context).colorScheme.background,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                              borderRadius: BorderRadius.circular(7),
                              // Set the desired border radius
                              border: Border.all(color: Theme.of(context).colorScheme.primary, width: 0.5), // Set the border color and width
                            ),
                            child: Column(
                              children: [
                                //========Header Container===========
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(7),
                                      // Set the desired top-left border radius
                                      topRight: Radius.circular(7), // Set the desired top-right border radius
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.transparent)),
                                        width: 30,
                                      ),
                                      const Spacer(),
                                      Text(
                                        AppLocalizations.of(context)!.userinfo,
                                        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () async {
                                          _menuController.hideMenu();
                                          if ((await AppHelper.showCustomAlertDialog(context, null, AppLocalizations.of(context)!.logoutValidation, AppLocalizations.of(context)!.yes, AppLocalizations.of(context)!.no) == AppLocalizations.of(context)!.yes)) {
                                            doLogout(context);
                                          }
                                        },
                                        child: Text(
                                          AppLocalizations.of(context)!.logout,
                                          style: const TextStyle(fontSize: 18, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                //==============================Menu Items===================================
                                //================User NAme===================
                                const Divider(
                                  height: 0,
                                  thickness: 0.5,
                                  color: Colors.grey,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                  // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.red)),
                                  child: Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.name,
                                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        AppHelper.currentUserSession.fullName,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 0.5,
                                  color: Colors.grey,
                                  endIndent: 10,
                                  indent: 10,
                                ),
                                //================Department===================
                                Theme(
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(horizontal: 10),
                                    childrenPadding: const EdgeInsets.all(10),
                                    title: Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.department,
                                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: 200,
                                          child: Text(
                                            // maxLines: 3,
                                            // '${AppHelper.currentUserSession.ouName}',
                                            VersionProvider.depName.isEmpty ? AppHelper.currentUserSession.ouName : VersionProvider.depName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: AppHelper.currentUserSession.userDepartments.length > 1 ? null : const Icon(Icons.arrow_drop_down),
                                    children: AppHelper.currentUserSession.userDepartments.where((department) => department.arOuName != AppHelper.currentUserSession.arOuName).map((dynamic item) {
                                      // var dept = item;
                                      var department = item;
                                      return GestureDetector(
                                        onTap: () async {
                                          _menuController.hideMenu();
                                          AppHelper.showLoaderDialog(context);
                                          MyServiceResponse serviceResponse = await AppHelper.login(
                                            AppHelper.currentUserSession.userName,
                                            AppHelper.currentUserSession.password,
                                            department.ouId,
                                          );
                                          // AppHelper.hideLoader(context);
                                          // if (serviceResponse.isSuccessResponse) Routes.moveDashboard(context: context);
                                          AppHelper.hideLoader(context);

                                          if (serviceResponse.isSuccessResponse) {
                                            VersionProvider.depName = department.regOuName;
                                            Routes.moveDashboard(context: context);
                                          }
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 17),
                                          child: Row(
                                            children: [
                                              // Icon(
                                              //   Icons.account_balance_outlined,
                                              //   color: Theme.of(context)
                                              //       .colorScheme
                                              //       .primary,
                                              // ),
                                              // const SizedBox(
                                              //   width: 10,
                                              // ),
                                              Flexible(
                                                child: Text(
                                                  '${department.ouName} ${department.hasRegistry == false ? ' - ${department.regOuName}' : ''}',
                                                  // "",
                                                  // '${department.ouName}',
                                                  // '${department.regOuName}',
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                //================Section (OUNAME)===================
                                const Divider(
                                  height: 0,
                                  thickness: 0.5,
                                  color: Colors.grey,
                                  endIndent: 10,
                                  indent: 10,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                  // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.red)),
                                  child: Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.section,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        AppHelper.currentUserSession.ouName,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                                // Container(
                                //   child: GestureDetector(
                                //     onTap: () async {
                                //       if ((await AppHelper.showCustomAlertDialog(context, null, AppLocalizations.of(context)!.logoutValidation, AppLocalizations.of(context)!.yes, AppLocalizations.of(context)!.no) == AppLocalizations.of(context)!.yes)) {
                                //         doLogout(context);
                                //       }
                                //     },
                                //     child: Container(
                                //       decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.transparent)),
                                //       child: Row(
                                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //         children: [
                                //           Text(
                                //             AppLocalizations.of(context)!.logout,
                                //             style: TextStyle(overflow: TextOverflow.ellipsis, color: Theme.of(context).colorScheme.primary, fontSize: 15),
                                //           ),
                                //           SvgPicture.asset(
                                //             "assets/images/logout_new.svg",
                                //             theme: SvgTheme(currentColor: Theme.of(context).colorScheme.primary),
                                //             height: 35,
                                //             width: 35,
                                //           ),
                                //         ],
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          );
                        },
                      )
                    else if ((AppHelper.currentUserSession.isEmployeeFollowupEnabled && _selectedIndex == 3) || (!AppHelper.currentUserSession.isEmployeeFollowupEnabled && _selectedIndex == 2))
                      Container(
                        decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.transparent)),
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: () {
                            resetAllFields();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.deleteAll,
                            style: TextStyle(fontSize: 18, color: ThemeProvider.isDarkMode ? Colors.black : Colors.white),
                          ),
                        ),
                      ),
                    //           PopupMenuButton(
                    //             shadowColor: Colors.grey,
                    //             splashRadius: 10,
                    //             position: PopupMenuPosition.under,
                    //             // color: Colors.white,
                    //             elevation: 0,
                    //             offset: Offset(1, 1),
                    //             itemBuilder: (context) => [
                    //               //===========fIRST iTEM (userName)===========
                    //               PopupMenuItem(
                    //                 child: Row(
                    //                   children: [
                    //                     Text(
                    //                       AppLocalizations.of(context)!.username + ": ",
                    //                       style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                    //                     ),
                    //                     Text(
                    //                       AppHelper.currentUserSession.fullName,
                    //                       style: const TextStyle(fontSize: 15),
                    //                     ),
                    //                   ],
                    //                 ),
                    //               ),
                    //               //===========Second item (depart)===========
                    //               PopupMenuItem(
                    //                 child: ExpansionTile(
                    //                   title: Text(
                    //                     '${AppHelper.currentUserSession.ouName}  ',
                    //                     style: const TextStyle(overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w600, fontSize: 15),
                    //                   ),
                    //                   children: AppHelper.currentUserSession.userDepartments.where((department) => department.arOuName != AppHelper.currentUserSession.arOuName).map((dynamic item) {
                    //                     var dept = item;
                    //                     // print(AppHelper.currentUserSession.userDepartments.indexOf(dept));
                    //                     return GestureDetector(
                    //                       onTap: () async {
                    //                         AppHelper.showLoaderDialog(context);
                    //                         MyServiceResponse serviceResponse = await AppHelper.login(
                    //                           AppHelper.currentUserSession.userName,
                    //                           AppHelper.currentUserSession.password,
                    //                           dept.ouId,
                    //                         );
                    //                         AppHelper.hideLoader(context);
                    //                         if (serviceResponse.isSuccessResponse) Routes.moveDashboard(context);
                    //                       },
                    //                       child: Container(
                    //                         margin: EdgeInsets.only(bottom: 17),
                    //                         child: Row(
                    //                           children: [
                    //                             Icon(
                    //                               Icons.account_balance_outlined,
                    //                               color: Theme.of(context).colorScheme.primary,
                    //                             ),
                    //                             const SizedBox(
                    //                               width: 10,
                    //                             ),
                    //                             Flexible(
                    //                               child: Text(
                    //                                 '${dept.ouName} ${dept.hasRegistry == false ? ' - ${dept.regOuName}' : ''}',
                    //                                 style: TextStyle(
                    //                                   color: Theme.of(context).colorScheme.primary,
                    //                                   overflow: TextOverflow.ellipsis,
                    //                                 ),
                    //                                 maxLines: 2,
                    //                               ),
                    //                             ),
                    //                           ],
                    //                         ),
                    //                       ),
                    //                     );
                    //                   }).toList(),
                    //                 ),
                    //                 //
                    //               ),
                    //               //============Third Item (Logout)============
                    //               PopupMenuItem(
                    //                 child: GestureDetector(
                    //                   onTap: () async {
                    //                     if ((await AppHelper.showCustomAlertDialog(context, null, AppLocalizations.of(context)!.logoutValidation, AppLocalizations.of(context)!.yes, AppLocalizations.of(context)!.no) == AppLocalizations.of(context)!.yes)) {
                    //                       doLogout(context);
                    //                     }
                    //                   },
                    //                   child: Container(
                    //                     decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.transparent)),
                    //                     child: Row(
                    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //                       children: [
                    //                         Text(
                    //                           AppLocalizations.of(context)!.logout,
                    //                           style: TextStyle(overflow: TextOverflow.ellipsis, color: Theme.of(context).colorScheme.primary, fontSize: 15),
                    //                         ),
                    //                         SvgPicture.asset(
                    //                           "assets/images/logout_new.svg",
                    //                           theme: SvgTheme(currentColor: Theme.of(context).colorScheme.primary),
                    //                           height: 35,
                    //                           width: 35,
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //             child: _selectedIndex == 0? const Padding(
                    //               padding: EdgeInsets.symmetric(horizontal: 10.0),
                    //               child: Icon(
                    //                 CupertinoIcons.person_alt_circle,
                    //                 // color: Colors.white,
                    //                 size: 32,
                    //               ),
                    //             ): _selectedIndex == 2?
                    //  Container(padding: EdgeInsets.symmetric(horizontal: 10.0),alignment: Alignment.bottomCenter, child: Text(AppLocalizations.of(context)!.deleteAll, style: TextStyle(fontSize: 18, color: ThemeProvider.isDarkMode? Colors.black: Colors.white))) : Container(),
                    //           ),
                  ],
                ),
              ),
        body: displaySelectedTabContent(context),
        //  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            // border: Border.all(
            //   width: 0.2,
            //   color: Colors.grey.shade400,
            // ),
            border: Border(
              top: BorderSide(
                width: 0.5,
                color: ThemeProvider.isDarkModeCheck() ? Color(0xFF323232) : Color(0xFFeeeeee),
              ),
            ),
          ),
          // color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 100,
                // transform: AppHelper.isMobileDevice(context) ? Matrix4.translationValues(0, 0, 0) : Matrix4.translationValues(0, 10, 0),
                padding: AppHelper.isMobileDevice(context) ? const EdgeInsets.only(right: 0) : const EdgeInsets.only(right: 50.0),
                // margin: EdgeInsets.only(top: 10),
                child: BottomNavigationBar(
                  elevation: 0,
                  selectedFontSize: 0,
                  // backgroundColor: Colors.white,
                  //AppHelper.myColor('#ededed'),
                  type: BottomNavigationBarType.fixed,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  items: <BottomNavigationBarItem>[
                    // SizedBox.shrink()
                    //===========================Inbox==================================
                    AppHelper.isMobileDevice(context)
                        ? BottomNavigationBarItem(
                            icon: Icon(
                              CupertinoIcons.mail,
                              size: navNormalSize,
                            ),
                            activeIcon: Icon(
                              CupertinoIcons.mail_solid,
                              size: navItemSize,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            label: AppLocalizations.of(context)!.inbox,
                            // tooltip: AppLocalizations.of(context)!.inbox,
                          )
                        : BottomNavigationBarItem(
                            icon: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 0),
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.inbox,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    CupertinoIcons.mail,
                                    size: navNormalSize,
                                  ),
                                ],
                              ),
                            ),
                            activeIcon: Row(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.inbox,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary),
                                ),
                                const SizedBox(width: 8),
                                Icon(CupertinoIcons.mail_solid, size: navItemSize),
                              ],
                            ),
                            label: "",
                            tooltip: AppLocalizations.of(context)!.sent,
                          ),
                    //  if (AppHelper.currentUserSession.isSentItemsEnabled)
                    //===========================Sent==================================
                    AppHelper.isMobileDevice(context)
                        ? BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.clock, size: navNormalSize),
                            activeIcon: Icon(
                              CupertinoIcons.clock_solid,
                              size: navItemSize,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            label: AppLocalizations.of(context)!.sent,
                            tooltip: AppLocalizations.of(context)!.sent,
                          )
                        : BottomNavigationBarItem(
                            icon: Container(
                              transform: transformAll,
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.sent,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(CupertinoIcons.clock, size: navNormalSize),
                                ],
                              ),
                            ),
                            activeIcon: Container(
                              transform: transformAll,
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.sent,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(CupertinoIcons.clock_solid, size: navItemSize),
                                ],
                              ),
                            ),
                            label: "",
                            tooltip: AppLocalizations.of(context)!.sent,
                          ),
                    //=============================================================
                    //===========================Follow UP==================================
                    if (AppHelper.currentUserSession.isEmployeeFollowupEnabled)
                      AppHelper.isMobileDevice(context)
                          ? BottomNavigationBarItem(
                              icon: Icon(
                                CupertinoIcons.person_2,
                                size: navNormalSize,
                              ),
                              activeIcon: Icon(
                                CupertinoIcons.person_2_fill,
                                size: navItemSize,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              label: AppLocalizations.of(context)!.followUp,
                              tooltip: AppLocalizations.of(context)!.followUp,
                            )
                          : BottomNavigationBarItem(
                              icon: Container(
                                transform: transformAll,
                                child: Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.followUp,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(CupertinoIcons.person_2, size: navNormalSize),
                                  ],
                                ),
                              ),
                              activeIcon: Container(
                                transform: transformAll,
                                child: Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.followUp,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      CupertinoIcons.person_2_fill,
                                      size: navItemSize,
                                    ),
                                  ],
                                ),
                              ),
                              label: "",
                              tooltip: AppLocalizations.of(context)!.followUp,
                            ),
                    //=============================================================
                    //===========================Search==================================
                    //  if (AppHelper.currentUserSession.searchEnabled)
                    AppHelper.isMobileDevice(context)
                        ? BottomNavigationBarItem(
                            icon: Icon(
                              CupertinoIcons.search,
                              size: navNormalSize,
                            ),
                            activeIcon: Icon(
                              CupertinoIcons.search,
                              size: navItemSize,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            label: AppLocalizations.of(context)!.search,
                            tooltip: AppLocalizations.of(context)!.search,
                          )
                        : BottomNavigationBarItem(
                            icon: Container(
                              transform: transformSearch,
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.search,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(CupertinoIcons.search, size: navNormalSize),
                                ],
                              ),
                            ),
                            activeIcon: Container(
                              transform: transformSearch,
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.search,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(CupertinoIcons.search, size: navItemSize),
                                ],
                              ),
                            ),
                            label: "",
                            tooltip: AppLocalizations.of(context)!.search,
                          ),
                    //=============================================================
                    //===========================Settings==================================
                    AppHelper.isMobileDevice(context)
                        ? BottomNavigationBarItem(
                            icon: Icon(
                              CupertinoIcons.settings,
                              size: navNormalSize,
                            ),
                            activeIcon: Icon(
                              CupertinoIcons.settings,
                              size: navItemSize,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            label: AppLocalizations.of(context)!.settings,
                            // label: Text(
                            //   AppLocalizations.of(context)!.settings,
                            //   style: TextStyle(
                            //     color: Colors.red,
                            //   ),
                            // ).data,
                            tooltip: AppLocalizations.of(context)!.settings,
                          )
                        : BottomNavigationBarItem(
                            icon: Container(
                              transform: transformAll,
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.settings,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(CupertinoIcons.settings, size: navNormalSize),
                                ],
                              ),
                            ),
                            activeIcon: Container(
                              transform: transformAll,
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.settings,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(CupertinoIcons.settings_solid, size: navItemSize),
                                ],
                              ),
                            ),
                            label: "",
                            tooltip: AppLocalizations.of(context)!.settings,
                          ),
                    //=============================================================
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  //   unselectedItemColor: unselectedItemColor,
                  selectedLabelStyle: TextStyle(
                    // color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: AppHelper.isMobileDevice(context) ? 13 : 0,
                  ),
                  unselectedLabelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: AppHelper.isMobileDevice(context) ? 13 : 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void doLogout(BuildContext ctx) {
    Routes.moveLogin(ctx);
    // DefaultCacheManager().emptyCache();
  }

// void doLogout(BuildContext ctx) async {
//   await DefaultCacheManager().emptyCache();
//   Routes.moveLogin(ctx);
//   // Clear user session cache
//   // await CacheManager.clearUserSessionCache();
//   // Clear entity details cache
//   // await CacheManager.clearEntityDetailsCache();
//   // Optionally, you can also update biometric status if needed
//   // CacheManager.updateBiometric(false);
// }
//   void clearCache() async {
//   try {
//     // Get the temporary directory where cached files are stored
//     Directory cacheDir = await getTemporaryDirectory();
//     // Delete the cache directory and its contents
//     if (cacheDir.existsSync()) {
//       cacheDir.deleteSync(recursive: true);
//     }
//     print('Cache cleared successfully.');
//   } catch (e) {
//     print('Error clearing cache: $e');
//   }
// }
// void doLogout(BuildContext context) {
//   // Clear cache
//   // clearCache();
//   // Add other logout logic here (e.g., navigate to login screen, clear user data, etc.)
//   Routes.moveLogin(context);
// }
// Future<void> clearCacheFile(String fileName) async {
//   try {
//     File cacheFile = await CacheManager.getFileByPath(fileName);
//     if (await cacheFile.exists()) {
//       await cacheFile.delete();
//     }
//   } catch (e) {
//     print('Error clearing cache file: $e');
//   }
// }
}
