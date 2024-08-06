import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:tawasol/app_models/app_utilities/app_routes.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/search_result_item.dart';
import 'package:tawasol/app_models/app_view_models/site_bind.dart';
import 'package:tawasol/theme/theme_provider.dart';
import '../app_models/app_utilities/app_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../app_models/app_view_models/db_entities/organization_unit.dart';
import '../app_models/app_view_models/securityLevel.dart';
import '../app_models/service_models/service_handler.dart';
import '../app_models/service_models/service_urls.dart';
import '../custom_controls/dropdown2.dart';
import '../custom_controls/my_textfield2.dart';
import '../custom_controls/radioWithText.dart';
import '../custom_controls/roundedContainer.dart';
import './search.dart';

class Search2 extends StatefulWidget {
  const Search2({super.key});

  @override
  State<Search2> createState() => SearchState();
}

class SearchState extends State<Search2> {
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

  int selectedOption = 1;

  SearchState() {
    bindLists();
    // _speech = stt.SpeechToText();
  }

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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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
    }
    return AppDefaultKeys.searchTypeGeneral;
  }

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
    Color selectedTabTextClr = const Color(0XFFFFFFFF);
    Color unselectedTabTextClr = ThemeProvider.isDarkModeCheck() ? const Color(0XFFD9D9D9) : const Color(0XFF999999);

    currentSelectedYear = int.parse(selectedYear.toString());
    int currentSelectedApproveYear = int.parse(selectedApproveYear.toString());
    isSelectedYearCurrent = DateTime.now().year == currentSelectedYear;
    bool isSelectedApproveYearCurrent = DateTime.now().year == currentSelectedApproveYear;
    Color appPrimaryColor = Theme.of(context).colorScheme.primary;

    int convertStringToDateTimeStamp(DateTime selectedDateTime) {
      return selectedDateTime.millisecondsSinceEpoch;
    }

    void search() async {
      // print("search");
      // print(topBarController.selectedIndex!);
      // print(getSearchTypeByIndex(topBarController.selectedIndex!));
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
        // var snackBar = SnackBar(content: Text(e.toString()));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }

    void setCurrentDepartmentValue(bool isCurrentDepartmentEnabled) => isCurrentDepartment = isCurrentDepartmentEnabled;

    Widget spaceBwConts() {
      return SizedBox(height: mHeight * 0.017);
    }

    Widget getSearchBtn(String btnText, Color btnClr, VoidCallback onPress) {
      return Container(
        height: mHeight * 0.065,
        width: mWidth * 0.37,
        child: ElevatedButton(
          // onPressed: () {},
          onPressed: onPress,
          child: Text(btnText),
          style: ElevatedButton.styleFrom(
            backgroundColor: btnClr,
            foregroundColor: Colors.white,
            // textStyle: TextStyle(
            //   fontSize: 30,
            //   fontWeight: FontWeight.bold,
            // ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
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
                        contClr: ThemeProvider.lightenClr(
                          ThemeProvider.primaryColor,
                          15,
                        ),
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
                  // const SizedBox(
                  //   height: 15,
                  // ),
                  //===============================Department====================================
                  Dropdown2(
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
                  //===============================Subject================================
                  spaceBwConts(),
                  MyTextField2(
                    labelText: lang.subject,
                    ctrl: subjectController,
                    isDense: true,
                    isShowBorder: true,
                    isValidationRequired: false,
                    isFloatingLabel: false,
                    horizontalPadding: 0,
                    isSearchScreenBorder: true,
                    isSearchScreen: true,
                    mHgt: mHeight,
                    mWdt: mWidth,
                  ),
                  spaceBwConts(),
                  MyTextField2(
                    labelText: lang.serialNumber,
                    ctrl: serialNumberController,
                    isDense: true,
                    isSearchScreenBorder: true,
                    isShowBorder: false,
                    isValidationRequired: false,
                    isFloatingLabel: false,
                    horizontalPadding: 0,
                    isSearchScreen: true,
                    mHgt: mHeight,
                    mWdt: mWidth,
                  ),
                  spaceBwConts(),
                  // until here farooq
                  // Container(
                  //   padding: const EdgeInsets.all(10),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(12),
                  //     // border: const Border.fromBorderSide(BorderSide(width: 0, color: Colors.transparent)),
                  //     // color: Theme.of(context).colorScheme.background,
                  //     color: ThemeProvider.isDarkModeCheck() ? const Color(0XFF585858) : const Color(0XFFF5F5F5),
                  //     // color: Colors.red,
                  //     boxShadow: [
                  //       BoxShadow(
                  //         // blurRadius: 2,
                  //         spreadRadius: 1.3,
                  //         color: dividerClr,
                  //         // offset: const Offset(1.5, 1.5),
                  //       )
                  //     ],
                  //   ),
                  //   child: GroupButton(
                  //     isRadio: true,
                  //     controller: topBarController,
                  //     options: GroupButtonOptions(
                  //       spacing: 0,
                  //       unselectedColor: Colors.transparent,
                  //       buttonWidth: (MediaQuery.of(context).size.shortestSide - 60) / 4,
                  //       // AppHelper.isMobileDevice(context) ? 90 : 150,
                  //       // buttonHeight: AppHelper.isMobileDevice(context) ? 35 : 50,
                  //       buttonHeight: 40,
                  //       elevation: 0,
                  //       borderRadius: BorderRadius.circular(8),
                  //       // borderRadius: BorderRadius.circular(AppHelper.isMobileDevice(context) ? 8 : 15),
                  //       selectedColor: appPrimaryColor,
                  //       selectedTextStyle: TextStyle(color: selectedTabTextClr, fontWeight: FontWeight.bold, fontSize: AppHelper.isMobileDevice(context) ? 14 : 16),
                  //       unselectedTextStyle: TextStyle(color: unselectedTabTextClr, fontSize: AppHelper.isMobileDevice(context) ? 14 : 16),
                  //       // alignment: Alignment.center,
                  //       textAlign: TextAlign.center,
                  //     ),
                  //     onSelected: (value, int index, bool isSelected) {
                  //       setState(() {
                  //         if (index == 3 || index == 4) {
                  //           isShowSites = false;
                  //         } else {
                  //           isShowSites = true;
                  //         }
                  //       });
                  //     },
                  //     // onSelected: ( index,isSelected) => print('$index button is selected'),
                  //     buttons: [
                  //       lang.general,
                  //       // if (AppHelper.currentUserSession.isGeneralSearchEnabled)
                  //       //if (AppHelper.currentUserSession.isOutgoingSearchEnabled)
                  //       lang.outgoing,
                  //       //if (AppHelper.currentUserSession.isIncomingSearchEnabled)
                  //       lang.incoming,
                  //       //if (AppHelper.currentUserSession.isInternalSearchEnabled)
                  //       lang.internal,
                  //       //  lang.general,
                  //     ],
                  //   ),
                  // ),
                  Container(
                    // width: mWidth * 0.8,
                    // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.red)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RadioWithText(
                          rSelectedOption: selectedOption,
                          rValue: 1,
                          rText: lang.general,
                          mWdt: mWidth,
                          rOnChanged: (value) => setState(() {
                            selectedOption = value;
                            Haptics.vibrate(HapticsType.light);
                            // print(value);
                            isShowSites = false;
                          }),
                        ),
                        RadioWithText(
                          rSelectedOption: selectedOption,
                          rValue: 2,
                          rText: lang.outgoing,
                          mWdt: mWidth,
                          rOnChanged: (value) => setState(() {
                            selectedOption = value;
                            Haptics.vibrate(HapticsType.light);
                            // print(value);
                            isShowSites = false;
                          }),
                        ),
                        RadioWithText(
                          rSelectedOption: selectedOption,
                          rValue: 3,
                          rText: lang.incoming,
                          mWdt: mWidth,
                          rOnChanged: (value) => setState(() {
                            selectedOption = value;
                            Haptics.vibrate(HapticsType.light);
                            // print(value);
                            isShowSites = false;
                          }),
                        ),
                        RadioWithText(
                          rSelectedOption: selectedOption,
                          rValue: 4,
                          rText: lang.internal,
                          mWdt: mWidth,
                          rOnChanged: (value) => setState(() {
                            selectedOption = value;
                            Haptics.vibrate(HapticsType.light);
                            // print(value);
                            isShowSites = false;
                          }),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: mWidth * 0.8,
                    margin: EdgeInsets.only(top: mHeight * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        getSearchBtn(
                          lang.search,
                          appPrimaryColor,
                          search,
                        ),
                        getSearchBtn(
                          "البحث المتقدم",
                          const Color(0XFFA19576),
                          () {
                            // Navigator.pushNamed(context, routeName);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Search()));
                          },
                        ),
                      ],
                    ),
                  ),
                  // spaceBwConts(),
                  // Container(
                  //   padding: const EdgeInsets.all(10),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(12),
                  //     // border: const Border.fromBorderSide(BorderSide(width: 0, color: Colors.transparent)),
                  //     // color: Theme.of(context).colorScheme.background,
                  //     color: ThemeProvider.isDarkModeCheck() ? const Color(0XFF585858) : const Color(0XFFF5F5F5),
                  //     // color: Colors.red,
                  //     boxShadow: [
                  //       BoxShadow(
                  //         // blurRadius: 2,
                  //         spreadRadius: 1.3,
                  //         color: dividerClr,
                  //         // offset: const Offset(1.5, 1.5),
                  //       )
                  //     ],
                  //   ),
                  //   child: GroupButton(
                  //     isRadio: true,
                  //     controller: topBarController,
                  //     options: GroupButtonOptions(
                  //       spacing: 0,
                  //       unselectedColor: Colors.transparent,
                  //       buttonWidth: (MediaQuery.of(context).size.shortestSide - 60) / 4,
                  //       // AppHelper.isMobileDevice(context) ? 90 : 150,
                  //       // buttonHeight: AppHelper.isMobileDevice(context) ? 35 : 50,
                  //       buttonHeight: 40,
                  //       elevation: 0,
                  //       borderRadius: BorderRadius.circular(8),
                  //       // borderRadius: BorderRadius.circular(AppHelper.isMobileDevice(context) ? 8 : 15),
                  //       selectedColor: appPrimaryColor,
                  //       selectedTextStyle: TextStyle(color: selectedTabTextClr, fontWeight: FontWeight.bold, fontSize: AppHelper.isMobileDevice(context) ? 14 : 16),
                  //       unselectedTextStyle: TextStyle(color: unselectedTabTextClr, fontSize: AppHelper.isMobileDevice(context) ? 14 : 16),
                  //       textAlign: TextAlign.center,
                  //     ),
                  //     onSelected: (value, int index, bool isSelected) {
                  //       setState(() {
                  //         print(index);
                  //         if (index == 3 || index == 4) {
                  //           isShowSites = false;
                  //         } else {
                  //           isShowSites = true;
                  //         }
                  //       });
                  //     },
                  //     buttons: [
                  //       lang.general,
                  //       // if (AppHelper.currentUserSession.isGeneralSearchEnabled)
                  //       //if (AppHelper.currentUserSession.isOutgoingSearchEnabled)
                  //       lang.outgoing,
                  //       //if (AppHelper.currentUserSession.isIncomingSearchEnabled)
                  //       lang.incoming,
                  //       //if (AppHelper.currentUserSession.isInternalSearchEnabled)
                  //       lang.internal,
                  //       //  lang.general,
                  //     ],
                  //   ),
                  // ),
                  SizedBox(height: mHeight * 0.1),
                  Icon(
                    Icons.manage_search,
                    color: Color(0XFFEAEAEA),
                    size: mWidth * 0.4,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
