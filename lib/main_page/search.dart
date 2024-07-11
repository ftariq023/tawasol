import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:tawasol/app_models/app_utilities/app_routes.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/search_result_item.dart';
import 'package:tawasol/app_models/app_view_models/site_bind.dart';
import 'package:tawasol/custom_controls/department_switch.dart';
import 'package:tawasol/custom_controls/dropdown.dart';
import 'package:tawasol/custom_controls/my_textfield.dart';
import 'package:tawasol/theme/theme_provider.dart';
import '../app_models/app_utilities/app_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../app_models/app_view_models/db_entities/organization_unit.dart';
import '../app_models/app_view_models/securityLevel.dart';
import '../app_models/service_models/service_handler.dart';
import '../app_models/service_models/service_urls.dart';
import '../custom_controls/my_button.dart';
import '../custom_controls/roundedContainer.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => SearchState();
}

class SearchState extends State<Search> {
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

  SearchState() {
    bindLists();
  }

  // SiteBind? widget.siteType;
  // SiteBind? widget.rMainSite;
  // SiteBind? widget.rSubSite;
  // OrganizationUnit? widget.rSelectedSearchOu = AppHelper.getCurrentUserOuList()[0];
  // String? widget.selectedYear;
  // String? _selectedApproveYear;
  // SecurityLevel? widget.rSelectedSecurityLevel;
  // List<String> yearList = [];
  // DateTime? widget.rStartDate;
  // DateTime? approveStartDate;
  // DateTime? widget.rDocDateFrom;
  // bool widget.risShowSites = true;
  // bool isCurrentDepartment = false;
  // DateTime? widget.rEndDate;
  // DateTime? approveEndDate;
  // DateTime? widget.rDocDateTo;
  // GroupButtonController widget.rwidget.rTopBarController = GroupButtonController(selectedIndex: 0);
  // TextEditingController widget.rSubjectController = TextEditingController();
  // TextEditingController widget.rSerialNumberController = TextEditingController();
  // TextEditingController widget.rStartDateController = TextEditingController();
  // TextEditingController widget.rEndDateController = TextEditingController();
  // TextEditingController widget.rDocDateFromController = TextEditingController();
  // TextEditingController widget.rDocDateToController = TextEditingController();
  // TextEditingController widget.rApproveStartDateController = TextEditingController();
  // TextEditingController widget.rApproveEndDateController = TextEditingController();

  List<String> bindLists() {
    for (int i = 0; i < 25; i++) {
      yearList.add((DateTime.now().year - i).toString());
    }
    selectedYear = yearList[0];
    selectedApproveYear = yearList[0];
    return yearList;
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      );

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

  // String getSearchTypeByIndex(int index) {
  //   switch (index) {
  //     case 0:
  //       return AppDefaultKeys.searchTypeCorrespondence;
  //     case 1:
  //       return AppDefaultKeys.searchTypeOutgoing;
  //     case 2:
  //       return AppDefaultKeys.searchTypeIncoming;
  //     case 3:
  //       return AppDefaultKeys.searchTypeInternal;
  //     case 4:
  //       return AppDefaultKeys.searchTypeGeneral;
  //   }
  //   return AppDefaultKeys.searchTypeGeneral;
  // }
  // void resetAllFields() {
  //   setState(() {
  //     widget.siteType = null;
  //     widget.rSerialNumberController.text = '';
  //     widget.rSubjectController.text = '';
  //     widget.selectedYear = yearList[0];
  //     widget.rSelectedSecurityLevel = null;
  //     widget.rSubSite = null;
  //     widget.rMainSite = null;
  //     widget.rStartDate = null;
  //     widget.rEndDate = null;
  //     widget.rStartDateController.text = '';
  //     widget.rEndDateController.text = '';
  //   });
  // }

  void resetAllFields() {
    // print("reset");
    // return;
    setState(() {
      siteType = null;
      serialNumberController.text = '';
      subjectController.text = '';
      selectedYear = yearList[0];
      selectedApproveYear = yearList[0];
      selectedSearchOu = AppHelper.getCurrentUserOuList()[0];
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

  // final searchFormKey = GlobalKey<FormState>();

  Color dividerClr = ThemeProvider.isDarkModeCheck() ? Color(0xFF323232) : Color(0xFFeeeeee);

  void setTodaysDate(TextEditingController ctrl) {
    DateTime ob = DateTime.now();
    setState(() {
      if (ctrl == startDateController) startDate = ob;
      ctrl.text = DateFormat('dd/MM/yyyy').format(ob);
    });
  }

  @override
  Widget build(BuildContext context) {
    var mqContext = MediaQuery.of(context);
    var size = mqContext.size;

    var mHeight = size.height - AppBar().preferredSize.height - mqContext.padding.top - mqContext.padding.bottom;
    var mWidth = size.width;

    bool isPortrait = mqContext.orientation == Orientation.portrait;

    var lang = AppLocalizations.of(context)!;

    Widget myDivider = Divider(
      thickness: 0.7,
      color: dividerClr,
    );

    var contHgt = 40.0;
    //
    Color selectedTabTextClr = Color(0XFFFFFFFF);
    Color unselectedTabTextClr = ThemeProvider.isDarkModeCheck() ? Color(0XFFD9D9D9) : Color(0XFF999999);

    // Color rowTitleTextClr = ThemeProvider.isDarkModeCheck() ? Color(0XFFD9D9D9) : Color(0XFF999999);

    //

    currentSelectedYear = int.parse(selectedYear.toString());
    int currentSelectedApproveYear = int.parse(selectedApproveYear.toString());
    isSelectedYearCurrent = DateTime.now().year == currentSelectedYear;
    bool isSelectedApproveYearCurrent = DateTime.now().year == currentSelectedApproveYear;
    // Color appPrimaryColor = Theme.of(context).colorScheme.primary;
    // Color appPrimaryColor = Provider.of<ThemeProvider>(context).setPrimaryColor(Colors.red);
    // Color appPrimaryColor = Provider.of<ThemeProvider>(context).getPrimaryColor();
    // Color lightColor = Provider.of<ThemeProvider>(context).lighModColor();
    // final Brightness lighMode = Theme.of(context).brightness;
    // Color groupButtonColor = lighMode == Brightness.dark ? Provider.of<ThemeProvider>(context).blackModColor() : Provider.of<ThemeProvider>(context).lighModColor();
    // Color unselectedItems = lighMode == Brightness.dark ? Provider.of<ThemeProvider>(context).lighModColor() : appPrimaryColor;
    Color appPrimaryColor = Theme.of(context).colorScheme.primary;

    int convertStringToDateTimeStamp(DateTime selectedDateTime) {
      return selectedDateTime.millisecondsSinceEpoch;
    }

    void search() async {
      // print("search");
      // return;
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
                    : convertStringToDateTimeStamp(approveStartDate!),
            topBarController.selectedIndex != 1
                ? null
                : approveEndDateController.text.isEmpty
                    ? null
                    : convertStringToDateTimeStamp(approveEndDate!),
            topBarController.selectedIndex != 2
                ? null
                : docDateFromController.text.isEmpty
                    ? null
                    : DateFormat("yyyy-MM-dd").format(docDateFrom!),
            topBarController.selectedIndex != 2
                ? null
                : docDateToController.text.isEmpty
                    ? null
                    : DateFormat("yyyy-MM-dd").format(docDateTo!),
          );
          AppHelper.hideLoader(context);
          if (searchItemList.isEmpty) {
            // ignore: use_build_context_synchronously
            showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: Text(
                    lang.error,
                    textAlign: TextAlign.center,
                  ),
                  content: Text(lang.noSearchResult),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      child: Text(lang.ok),
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

    void setCurrentDepartmentValue(bool isCurrentDepartmentEnabled) => isCurrentDepartment = isCurrentDepartmentEnabled;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        floatingActionButton: FloatingActionButton.small(
          onPressed: () => Navigator.pop(context),
          backgroundColor: appPrimaryColor,
          child: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, 75),
          child: AppBar(
            scrolledUnderElevation: 0,
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(
              lang.search,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            automaticallyImplyLeading: false,
            leading: AppHelper.isCurrentArabic
                ? FittedBox(
                    child: GestureDetector(
                      onTap: search,
                      child: RoundedContainer(
                        contHgt: AppHelper.isMobileDevice(context)
                            ? mHeight * 0.018
                            : isPortrait
                                ? mHeight * 0.5
                                : mHeight * 0.95,
                        contWdt: AppHelper.isMobileDevice(context) ? mWidth * 0.045 : mWidth * 0.85,
                        btnFontSize: AppHelper.isMobileDevice(context) ? mWidth * 0.014 : mWidth * 0.3,
                        bordRadius: AppHelper.isMobileDevice(context) ? mWidth * 0.01 : mWidth * 0.22,
                        margRight: AppHelper.isMobileDevice(context) ? mWidth * 0.01 : mWidth * 0.18,
                        margLeft: AppHelper.isMobileDevice(context) ? 0 : mWidth * 0.09,
                        btnText: lang.search,
                        contClr: ThemeProvider.lightenClr(ThemeProvider.primaryColor, 15),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      GestureDetector(
                        onTap: search,
                        child: RoundedContainer(
                          contHgt: mHeight * 0.04,
                          contWdt: mWidth * 0.15,
                          btnFontSize: mWidth * 0.03,
                          bordRadius: mWidth * 0.02,
                          margLeft: mWidth * 0.02,
                          btnText: lang.search,
                          contClr: ThemeProvider.lightenClr(ThemeProvider.primaryColor, 15),
                        ),
                      ),
                    ],
                  ),
            actions: [
              Container(
                height: AppHelper.isCurrentArabic ? 35 : 30,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                margin: AppHelper.isCurrentArabic ? const EdgeInsets.only(left: 10) : const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: ThemeProvider.lightenClr(ThemeProvider.primaryColor, 15),
                  borderRadius: BorderRadius.circular(isPortrait ? mWidth * 0.018 : mWidth * 0.013),
                ),
                child: GestureDetector(
                  onTap: resetAllFields,
                  child: Text(
                    lang.clearAll,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Form(
          key: searchFormKey,
          child: SingleChildScrollView(
            child: Container(
              // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
              padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 0),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      // border: const Border.fromBorderSide(BorderSide(width: 0, color: Colors.transparent)),
                      // color: Theme.of(context).colorScheme.background,
                      color: ThemeProvider.isDarkModeCheck() ? const Color(0XFF585858) : const Color(0XFFF5F5F5),
                      // color: Colors.red,
                      boxShadow: [
                        BoxShadow(
                          // blurRadius: 2,
                          spreadRadius: 1.3,
                          color: dividerClr,
                          // offset: const Offset(1.5, 1.5),
                        )
                      ],
                    ),
                    child: GroupButton(
                      isRadio: true,
                      controller: topBarController,
                      options: GroupButtonOptions(
                        spacing: 0,
                        unselectedColor: Colors.transparent,
                        buttonWidth: (MediaQuery.of(context).size.shortestSide - 60) / 4,
                        // AppHelper.isMobileDevice(context) ? 90 : 150,
                        // buttonHeight: AppHelper.isMobileDevice(context) ? 35 : 50,
                        buttonHeight: 40,
                        elevation: 0,
                        borderRadius: BorderRadius.circular(8),
                        // borderRadius: BorderRadius.circular(AppHelper.isMobileDevice(context) ? 8 : 15),
                        selectedColor: appPrimaryColor,
                        selectedTextStyle: TextStyle(color: selectedTabTextClr, fontWeight: FontWeight.bold, fontSize: AppHelper.isMobileDevice(context) ? 14 : 16),
                        unselectedTextStyle: TextStyle(color: unselectedTabTextClr, fontSize: AppHelper.isMobileDevice(context) ? 14 : 16),
                        textAlign: TextAlign.center,
                      ),
                      onSelected: (value, int index, bool isSelected) {
                        setState(() {
                          if (index == 3 || index == 4) {
                            isShowSites = false;
                          } else {
                            isShowSites = true;
                          }
                        });
                      },
                      buttons: [
                        lang.general,
                        // if (AppHelper.currentUserSession.isGeneralSearchEnabled)
                        //if (AppHelper.currentUserSession.isOutgoingSearchEnabled)
                        lang.outgoing,
                        //if (AppHelper.currentUserSession.isIncomingSearchEnabled)
                        lang.incoming,
                        //if (AppHelper.currentUserSession.isInternalSearchEnabled)
                        lang.internal,
                        //  lang.general,
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  // Column(
                  //   children: [
                  //===============================Department====================================
                  Container(
                    height: contHgt,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            // lang.selectOU,
                            lang.organizationUnit,
                            textAlign: TextAlign.start,
                            // style: TextStyle(color: appPrimaryColor, fontWeight: FontWeight.w500, fontSize: 15),
                            style: TextStyle(color: unselectedTabTextClr, fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ),
                        Expanded(
                          child: Dropdown(
                            isSearchScreen: true,
                            isLabel: false,
                            listItemType: OrganizationUnit,
                            selectedValue: selectedSearchOu,
                            isShowBorder: false,
                            isShowTopLabel: false,
                            isShowClearIcon: false,
                            listItemBinding: ServiceHandler.getOusForSearch,
                            isValidationRequired: false,
                            labelText: lang.selectOU,
                            isSearchEnabled: true,
                            // prefixIconData: Icons.account_balance_outlined,
                            onDropdownChange: (dynamic item) {
                              setState(() {
                                selectedSearchOu = item;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  myDivider,
                  // SizedBox(
                  //   height: AppHelper.isMobileDevice(context) ? 15 : 30,
                  // ),
                  //============================Security level===========================
                  Container(
                    height: contHgt,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            lang.securityLevel,
                            style: TextStyle(color: unselectedTabTextClr, fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ),
                        Expanded(
                          child: Dropdown(
                            isSearchScreen: true,
                            isLabel: true,
                            isShowBorder: false,
                            listItemType: SecurityLevel,
                            selectedValue: selectedSecurityLevel,
                            isValidationRequired: false,
                            isShowTopLabel: false,
                            // prefixIconData: Icons.security_outlined,
                            listOfItems: AppHelper.currentUserSession.securityLevelList,
                            isSearchEnabled: false,
                            labelText: lang.securityLevel,
                            onDropdownChange: (dynamic item) {
                              setState(() {
                                selectedSecurityLevel = item;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const Divider(
                  //   thickness: 0.2,
                  //   color: Colors.grey,
                  // ),
                  myDivider,
                  //================================Year===============================ss
                  Container(
                    height: contHgt,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            lang.selectYear,
                            style: TextStyle(color: unselectedTabTextClr, fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ),
                        Expanded(
                          child: Dropdown(
                            isSearchScreen: true,
                            isLabel: true,
                            isShowBorder: false,
                            listItemType: String,
                            selectedValue: selectedYear.toString(),
                            isValidationRequired: true,
                            isShowTopLabel: false,
                            //   prefixIconData: Icons.calendar_today_outlined,
                            isSingleValue: true,
                            isShowClearIcon: false,
                            listOfItems: yearList,
                            isSearchEnabled: false,
                            labelText: lang.year,
                            onDropdownChange: (dynamic item) {
                              setState(() {
                                selectedYear = item;
                                startDateController.text = '';
                                endDateController.text = '';
                                docDateToController.text = '';
                                docDateFromController.text = '';
                                startDate = null;
                                endDate = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const Divider(
                  //   thickness: 0.2,
                  //   color: Colors.grey,
                  // ),
                  myDivider,
                  //===============================Subject================================
                  Container(
                    height: contHgt,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            lang.subject,
                            style: TextStyle(color: unselectedTabTextClr, fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ),
                        Expanded(
                          child: MyTextField(
                            labelText: lang.subject,
                            ctrl: subjectController,
                            isDense: true,
                            isShowBorder: true,
                            isValidationRequired: false,
                            isFloatingLabel: false,
                            horizontalPadding: 0,
                            isSearchScreenBorder: true,
                            isSearchScreen: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  myDivider,
                  // SizedBox(
                  //   height: AppHelper.isMobileDevice(context) ? 15 : 30,
                  // ),
                  Container(
                    height: contHgt,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            lang.serialNumber,
                            style: TextStyle(color: unselectedTabTextClr, fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ),
                        Expanded(
                          child: MyTextField(
                            labelText: lang.serialNumber,
                            ctrl: serialNumberController,
                            isDense: true,
                            isSearchScreenBorder: true,
                            isShowBorder: false,
                            isValidationRequired: false,
                            isFloatingLabel: false,
                            horizontalPadding: 0,
                            isSearchScreen: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  myDivider,
                  //===========================Start Date==============================
                  Container(
                    height: contHgt,
                    child: Row(
                      children: [
                        // if (!AppHelper.isMobileDevice(context))
                        SizedBox(
                          width: 110,
                          child: Text(
                            topBarController.selectedIndex == 2 ? lang.incomingDateFrom : lang.dateFrom,
                            style: TextStyle(color: unselectedTabTextClr, fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ),
                        Expanded(
                          child: MyTextField(
                            labelText: "",
                            // labelText: AppHelper.isMobileDevice(context) ? lang.start : lang.widget.rStartDate,
                            mHgt: mHeight,
                            mWdt: mWidth,
                            isSearchScreen: true,
                            ctrl: startDateController,
                            isValidationRequired: false,
                            isKeyboardEnabled: false,
                            isShowBorder: true,
                            isSearchScreenBorder: true,
                            isShowClear: true,
                            isShowTodayBtn: true,
                            isMob: AppHelper.isMobileDevice(context),
                            isPort: isPortrait,
                            rSetTodaysDate: () => setTodaysDate(startDateController),
                            onClearTap: () {
                              startDateController.text = '';
                              endDateController.text = '';
                              setState(() {
                                startDate = null;
                                endDate = null;
                              });
                            },
                            prefixIconData: Icons.calendar_month_outlined,
                            onTextFieldTap: () async {
                              int month = 1;
                              int day = 1;
                              int lastMonth = isSelectedYearCurrent ? DateTime.now().month : 12;
                              int lastDay = isSelectedYearCurrent ? DateTime.now().day : 31;
                              DateTime? pickedTime = await showDatePicker(
                                context: context,
                                cancelText: lang.cancel,
                                confirmText: lang.ok,
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: Theme.of(context).colorScheme,
                                      buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                    ),
                                    child: child!,
                                  );
                                },
                                initialDate: isSelectedYearCurrent ? DateTime.now() : DateTime(currentSelectedYear, day, month),
                                firstDate: DateTime(currentSelectedYear, month, day),
                                lastDate: DateTime(currentSelectedYear, lastMonth, lastDay),
                                helpText: lang.startDate,
                                // cancelText: lang.cancel,
                                // confirmText: lang.ok,
                              );
                              setState(() {
                                startDate = pickedTime;
                              });
                              if (pickedTime != null) {
                                startDateController.text = DateFormat('dd/MM/yyyy').format(pickedTime);
                              }
                            },
                            horizontalPadding: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  //=======================================End Date================================
                  myDivider,
                  Container(
                    height: contHgt,
                    child: Row(
                      children: [
                        // if (!AppHelper.isMobileDevice(context))
                        SizedBox(
                          width: 110,
                          child: Text(
                            topBarController.selectedIndex == 2 ? lang.incomingDateTo : lang.dateTo,
                            style: TextStyle(color: unselectedTabTextClr, fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ),
                        Expanded(
                          child: MyTextField(
                              labelText: "",
                              mHgt: mHeight,
                              mWdt: mWidth,
                              // labelText: AppHelper.isMobileDevice(context) ? lang.end : lang.widget.rEndDate,
                              isSearchScreen: true,
                              isValidationRequired: false,
                              isKeyboardEnabled: false,
                              isShowBorder: true,
                              isSearchScreenBorder: true,
                              onClearTap: startDate != null
                                  ? () {
                                      endDateController.text = '';
                                      endDate = null;
                                    }
                                  : null,
                              prefixIconData: Icons.calendar_month_outlined,
                              isShowTodayBtn: true,
                              isMob: AppHelper.isMobileDevice(context),
                              isPort: isPortrait,
                              rSetTodaysDate: () => setTodaysDate(endDateController),
                              isShowClear: true,
                              ctrl: endDateController,
                              isEnabled: startDate != null,
                              onTextFieldTap: startDate != null
                                  ? () async {
                                      DateTime? pickedTime = await showDatePicker(
                                        context: context,
                                        cancelText: lang.cancel,
                                        confirmText: lang.ok,
                                        builder: (BuildContext context, Widget? child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              colorScheme: Theme.of(context).colorScheme,
                                              buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                            ),
                                            child: child!,
                                          );
                                        },
                                        initialDate: !isSelectedYearCurrent && startDate != null ? DateTime(int.parse(selectedYear.toString()), 12, 31) : DateTime.now(),
                                        firstDate: startDate!,
                                        lastDate: DateTime(int.parse(selectedYear.toString()), isSelectedYearCurrent ? DateTime.now().month : 12, isSelectedYearCurrent ? DateTime.now().day : 31),
                                        helpText: lang.endDate,
                                      );
                                      endDate = pickedTime;
                                      if (pickedTime != null) {
                                        endDateController.text = DateFormat('dd/MM/yyyy').format(pickedTime);
                                      }
                                    }
                                  : null,
                              horizontalPadding: 0),
                        ),
                      ],
                    ),
                  ),
                  myDivider,
                  // SizedBox(
                  //   height: AppHelper.isMobileDevice(context) ? 15 : 30,
                  // ),
                  //=====================================Site Type================================
                  if (isShowSites) ...[
                    Container(
                      height: contHgt,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              lang.siteType,
                              style: TextStyle(color: unselectedTabTextClr, fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ),
                          Expanded(
                            child: Dropdown(
                              isSearchScreen: true,
                              isLabel: true,
                              listItemType: SiteBind,
                              isShowBorder: false,
                              selectedValue: siteType,
                              isValidationRequired: false,
                              isShowTopLabel: false,
                              listItemBinding: ServiceHandler.getSiteTypes,
                              labelText: lang.siteType,
                              onDropdownChange: (dynamic item) {
                                setState(() {
                                  siteType = item;
                                  mainSite = null;
                                  subSite = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    myDivider,
                    //=====================================Main Site================================
                    Container(
                      height: contHgt,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              lang.mainSite,
                              style: TextStyle(color: unselectedTabTextClr, fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ),
                          Expanded(
                            child: Dropdown(
                              isSearchScreen: true,
                              isLabel: true,
                              listItemType: SiteBind,
                              isShowBorder: false,
                              selectedValue: mainSite,
                              // prefixIconData: Icons.account_tree_outlined,
                              isDropdownEnabled: siteType != null,
                              isShowTopLabel: false,
                              isValidationRequired: false,
                              listItemBinding: () {
                                return ServiceHandler.getSiteList(siteType!.siteId, null);
                              },
                              labelText: lang.mainSite,
                              onDropdownChange: (dynamic item) {
                                setState(() {
                                  mainSite = item;
                                  subSite = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    myDivider,
                    //=====================================Sub Site================================
                    Container(
                      height: contHgt,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              lang.subSite,
                              style: TextStyle(color: unselectedTabTextClr, fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ),
                          Expanded(
                            child: Dropdown(
                              isSearchScreen: true,
                              isLabel: true,
                              listItemType: SiteBind,
                              isShowTopLabel: false,
                              isShowBorder: false,
                              selectedValue: subSite,
                              isDropdownEnabled: siteType != null && mainSite != null,
                              isValidationRequired: false,
                              listItemBinding: () {
                                return ServiceHandler.getSiteList(siteType!.siteId, mainSite!.siteId);
                              },
                              labelText: lang.subSite,
                              onDropdownChange: (dynamic item) {
                                setState(() {
                                  subSite = item;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    myDivider,
                  ],
                  //=====================================Outgoing Search Fields================================
                  if (topBarController.selectedIndex == 1)
                    Column(
                      children: [
                        Container(
                          height: contHgt,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 110,
                                child: Text(
                                  lang.approveYear,
                                  style: TextStyle(color: unselectedTabTextClr, fontWeight: FontWeight.w500, fontSize: 15),
                                ),
                              ),
                              Expanded(
                                child: Dropdown(
                                  isSearchScreen: true,
                                  isLabel: true,
                                  isShowBorder: false,
                                  listItemType: String,
                                  selectedValue: selectedApproveYear.toString(),
                                  isValidationRequired: true,
                                  isShowTopLabel: false,
                                  //   prefixIconData: Icons.calendar_today_outlined,
                                  isSingleValue: true,
                                  isShowClearIcon: false,
                                  listOfItems: yearList,
                                  isSearchEnabled: false,
                                  labelText: lang.approveYear,
                                  onDropdownChange: (dynamic item) {
                                    setState(() {
                                      selectedApproveYear = item;
                                      approveStartDateController.text = '';
                                      approveEndDateController.text = '';
                                      approveStartDate = null;
                                      approveEndDate = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        myDivider,
                        //===========================Approve Start Date==============================
                        Container(
                          height: contHgt,
                          child: Row(
                            children: [
                              // if (!AppHelper.isMobileDevice(context))
                              SizedBox(
                                width: 110,
                                child: Text(
                                  lang.approveDateFrom,
                                  style: TextStyle(color: unselectedTabTextClr, fontWeight: FontWeight.w500, fontSize: 15),
                                ),
                              ),
                              Expanded(
                                child: MyTextField(
                                  labelText: "",
                                  // labelText: AppHelper.isMobileDevice(context) ? lang.start : lang.startDate,
                                  isSearchScreen: true,
                                  ctrl: approveStartDateController,
                                  isValidationRequired: false,
                                  isKeyboardEnabled: false,
                                  isShowBorder: true,
                                  isSearchScreenBorder: true,
                                  isShowClear: true,
                                  onClearTap: () {
                                    approveStartDateController.text = '';
                                    approveEndDateController.text = '';
                                    setState(() {
                                      approveStartDate = null;
                                      approveEndDate = null;
                                    });
                                  },
                                  prefixIconData: Icons.calendar_month_outlined,
                                  onTextFieldTap: () async {
                                    int month = 1;
                                    int day = 1;

                                    int lastMonth = isSelectedApproveYearCurrent ? DateTime.now().month : 12;
                                    int lastDay = isSelectedApproveYearCurrent ? DateTime.now().day : 31;

                                    DateTime? pickedTime = await showDatePicker(
                                      context: context,
                                      cancelText: lang.cancel,
                                      confirmText: lang.ok,
                                      builder: (BuildContext context, Widget? child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            colorScheme: Theme.of(context).colorScheme,
                                            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                          ),
                                          child: child!,
                                        );
                                      },
                                      initialDate: isSelectedApproveYearCurrent ? DateTime.now() : DateTime(currentSelectedApproveYear, day, month),
                                      firstDate: DateTime(currentSelectedApproveYear, month, day),
                                      lastDate: DateTime(currentSelectedApproveYear, lastMonth, lastDay),
                                      helpText: lang.approveDateFrom,
                                      // cancelText: lang.cancel,
                                      // confirmText: lang.ok,
                                    );
                                    setState(() {
                                      approveStartDate = pickedTime;
                                    });
                                    if (pickedTime != null) {
                                      approveStartDate == pickedTime;
                                      approveStartDateController.text = DateFormat('dd/MM/yyyy').format(pickedTime);
                                    }
                                  },
                                  horizontalPadding: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        //=======================================Approve End Date================================
                        myDivider,
                        // SizedBox(
                        //   height: AppHelper.isMobileDevice(context) ? 15 : 30,
                        // ),
                        Row(
                          children: [
                            // if (!AppHelper.isMobileDevice(context))
                            SizedBox(
                              width: 110,
                              child: Text(
                                lang.approveDateTo,
                                style: TextStyle(color: unselectedTabTextClr, fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                            ),
                            Expanded(
                              child: MyTextField(
                                  labelText: "",
                                  // labelText: AppHelper.isMobileDevice(context) ? lang.end : lang.endDate,
                                  isSearchScreen: true,
                                  isValidationRequired: approveStartDate != null,
                                  isKeyboardEnabled: false,
                                  isShowBorder: true,
                                  isSearchScreenBorder: true,
                                  onClearTap: approveStartDate != null
                                      ? () {
                                          approveEndDateController.text = '';
                                          approveEndDate = null;
                                        }
                                      : null,
                                  prefixIconData: Icons.calendar_month_outlined,
                                  isShowClear: true,
                                  ctrl: approveEndDateController,
                                  isEnabled: approveStartDate != null,
                                  onTextFieldTap: approveStartDate != null
                                      ? () async {
                                          DateTime? pickedTime = await showDatePicker(
                                            context: context,
                                            cancelText: lang.cancel,
                                            confirmText: lang.ok,
                                            builder: (BuildContext context, Widget? child) {
                                              return Theme(
                                                data: ThemeData.light().copyWith(
                                                  colorScheme: Theme.of(context).colorScheme,
                                                  buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                                ),
                                                child: child!,
                                              );
                                            },
                                            initialDate: !isSelectedApproveYearCurrent && approveStartDate != null ? DateTime(int.parse(selectedApproveYear.toString()), 12, 31) : DateTime.now(),
                                            firstDate: approveStartDate!,
                                            lastDate: DateTime(int.parse(selectedApproveYear.toString()), isSelectedApproveYearCurrent ? DateTime.now().month : 12, isSelectedApproveYearCurrent ? DateTime.now().day : 31),
                                            helpText: lang.approveDateTo,
                                          );
                                          approveEndDate = pickedTime;
                                          if (pickedTime != null) {
                                            approveEndDate == pickedTime;
                                            approveEndDateController.text = DateFormat('dd/MM/yyyy').format(pickedTime);
                                          }
                                        }
                                      : null,
                                  horizontalPadding: 0),
                            ),
                          ],
                        ),
                        myDivider,
                      ],
                    ),
                  //=====================================Incoming Search Fields================================
                  if (topBarController.selectedIndex == 2)
                    Column(
                      children: [
                        //===========================Doc Date From==============================
                        Container(
                          height: contHgt,
                          child: Row(
                            children: [
                              // if (!AppHelper.isMobileDevice(context))
                              SizedBox(
                                width: 110,
                                child: Text(
                                  lang.docHistoryFrom,
                                  style: TextStyle(color: unselectedTabTextClr, fontWeight: FontWeight.w500, fontSize: 15),
                                ),
                              ),
                              Expanded(
                                child: MyTextField(
                                  labelText: "",
                                  // labelText: AppHelper.isMobileDevice(context) ? lang.start : lang.startDate,
                                  isSearchScreen: true,
                                  ctrl: docDateFromController,
                                  isValidationRequired: false,
                                  isKeyboardEnabled: false,
                                  isShowBorder: true,
                                  isSearchScreenBorder: true,
                                  isShowClear: true,
                                  onClearTap: () {
                                    docDateFromController.text = '';
                                    docDateToController.text = '';
                                    setState(() {
                                      docDateFrom = null;
                                      docDateTo = null;
                                    });
                                  },
                                  prefixIconData: Icons.calendar_month_outlined,
                                  onTextFieldTap: () async {
                                    int month = 1;
                                    int day = 1;
                                    int lastMonth = isSelectedYearCurrent ? DateTime.now().month : 12;
                                    int lastDay = isSelectedYearCurrent ? DateTime.now().day : 31;
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      cancelText: lang.cancel,
                                      confirmText: lang.ok,
                                      builder: (BuildContext context, Widget? child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            colorScheme: Theme.of(context).colorScheme,
                                            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                          ),
                                          child: child!,
                                        );
                                      },
                                      initialDate: isSelectedYearCurrent ? DateTime.now() : DateTime(currentSelectedYear, day, month),
                                      firstDate: DateTime(1990, month, day),
                                      lastDate: DateTime(currentSelectedYear, lastMonth, lastDay),
                                      helpText: lang.docDateFrom,
                                      // cancelText: lang.cancel,
                                      // confirmText: lang.ok,
                                    );
                                    setState(() {
                                      docDateFrom = pickedDate;
                                    });
                                    if (pickedDate != null) {
                                      docDateFromController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                                    }
                                  },
                                  horizontalPadding: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        //=======================================Doc Date To================================
                        myDivider,
                        // SizedBox(
                        //   height: AppHelper.isMobileDevice(context) ? 15 : 30,
                        // ),
                        Container(
                          height: contHgt,
                          child: Row(
                            children: [
                              // if (!AppHelper.isMobileDevice(context))
                              SizedBox(
                                width: 110,
                                child: Text(
                                  lang.docHistoryTo,
                                  style: TextStyle(color: unselectedTabTextClr, fontWeight: FontWeight.w500, fontSize: 15),
                                ),
                              ),
                              Expanded(
                                child: MyTextField(
                                    labelText: "",
                                    // labelText: AppHelper.isMobileDevice(context) ? lang.end : lang.endDate,
                                    isSearchScreen: true,
                                    isValidationRequired: docDateTo != null,
                                    isKeyboardEnabled: false,
                                    isShowBorder: true,
                                    isSearchScreenBorder: true,
                                    onClearTap: docDateFrom != null
                                        ? () {
                                            docDateToController.text = '';
                                            docDateTo = null;
                                          }
                                        : null,
                                    prefixIconData: Icons.calendar_month_outlined,
                                    isShowClear: true,
                                    ctrl: docDateToController,
                                    isEnabled: docDateFrom != null,
                                    onTextFieldTap: docDateFrom != null
                                        ? () async {
                                            DateTime? pickedDate = await showDatePicker(
                                              context: context,
                                              cancelText: lang.cancel,
                                              confirmText: lang.ok,
                                              builder: (BuildContext context, Widget? child) {
                                                return Theme(
                                                  data: ThemeData.light().copyWith(
                                                    colorScheme: Theme.of(context).colorScheme,
                                                    buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                              initialDate: !isSelectedYearCurrent && docDateFrom != null ? DateTime(int.parse(selectedYear.toString()), 12, 31) : DateTime.now(),
                                              firstDate: docDateFrom!,
                                              lastDate: DateTime(int.parse(selectedYear.toString()), isSelectedYearCurrent ? DateTime.now().month : 12, isSelectedYearCurrent ? DateTime.now().day : 31),
                                              helpText: lang.docDateTo,
                                            );
                                            docDateTo = pickedDate;
                                            if (pickedDate != null) {
                                              docDateToController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                                            }
                                          }
                                        : null,
                                    horizontalPadding: 0),
                              ),
                            ],
                          ),
                        ),
                        myDivider,
                      ],
                    ),
                  Container(
                    height: contHgt,
                    child: Row(
                      children: [
                        // if (!AppHelper.isMobileDevice(context))
                        SizedBox(
                          width: 250,
                          child: Text(
                            lang.searchInCurrentDepartment,
                            style: TextStyle(color: unselectedTabTextClr, fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ),
                        const Spacer(),
                        DepartmentSwitch(isCurrentDepartment: isCurrentDepartment, isCurrentDepartSelected: setCurrentDepartmentValue),
                      ],
                    ),
                  ),
                  //   ],
                  // ),
                  //
                  // Container(
                  //   margin: EdgeInsets.symmetric(vertical: 30),
                  //   child: MyButton(
                  //       btnText: lang.search,
                  //       horizontalPadding: 130,
                  //       verticalPadding: 12,
                  //       isLoginButton: true,
                  //       borderColor: Theme.of(context).colorScheme.primary,
                  //       backgroundColor: Theme.of(context).colorScheme.primary,
                  //       // Colors.white,
                  //       textColor: Colors.white,
                  //       onTap: () {
                  //         // doLogin();
                  //       }),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
