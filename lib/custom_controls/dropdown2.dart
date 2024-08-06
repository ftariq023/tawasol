import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tawasol/theme/theme_provider.dart';
import '../app_models/app_utilities/app_helper.dart';

class Dropdown2 extends StatelessWidget {
  dynamic listItemType;
  bool isSingleValue;
  dynamic selectedValue;
  IconData? prefixIconData;
  bool isSearchEnabled;
  bool isValidationRequired;
  bool isShowTopLabel;
  Function? listItemBinding;
  String labelText;
  bool isDropdownEnabled;
  bool isShowClearIcon;
  dynamic listOfItems = [];
  Function onDropdownChange;
  bool isLabel;
  bool isShowBorder;
  bool isSearchScreen;
  bool refresh;
  VoidCallback? onCrossPressed;

  Dropdown2({
    super.key,
    required this.listItemType,
    required this.selectedValue,
    required this.isValidationRequired,
    required this.labelText,
    required this.onDropdownChange,
    required this.isLabel,
    this.listItemBinding,
    this.listOfItems,
    this.isSingleValue = false,
    this.isSearchEnabled = true,
    this.isShowClearIcon = true,
    this.isShowTopLabel = true,
    this.isDropdownEnabled = true,
    this.prefixIconData,
    this.isShowBorder = true,
    this.isSearchScreen = false,
    this.refresh = false,
    this.onCrossPressed,
  });

  // @override
  // void initState() {
  //   if (refresh) selectedValue = null;
  // }

  @override
  Widget build(BuildContext context) {
    Color appPrimaryColor = Theme.of(context).colorScheme.primary;
    bool isDarkMode = ThemeProvider.isDarkModeCheck();

    return DropdownSearch<dynamic>(
      autoValidateMode: AutovalidateMode.onUserInteraction,
      selectedItem: selectedValue,
      popupProps: PopupProps.menu(
        showSearchBox: isSearchEnabled,
        //============================Here are the properties of the dropdown result===============================
        searchFieldProps: TextFieldProps(
          //Color of the search box text
          // style: TextStyle(
          //   color: Colors.red,
          // ),
          // padding: EdgeInsets.only(left: 20, right: 20),
          decoration: InputDecoration(
            // floatingLabelBehavior: FloatingLabelBehavior.never,
            // contentPadding: EdgeInsets.only(left: 20, right: 20),
            border: const OutlineInputBorder(borderSide: BorderSide(width: 10)),
            suffixIcon: Icon(
              Icons.search,
              color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.black,
              // color: ThemeProvider.isDarkModeCheck() ? Colors.red : Colors.red,
            ),
            enabledBorder: isShowBorder
                ? OutlineInputBorder(
                    // borderSide: BorderSide(color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.black),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  )
                : InputBorder.none,
            focusedBorder: isShowBorder
                ? OutlineInputBorder(
                    // borderSide: BorderSide(color: Colors.grey.shade400),
                    //Light mode/Dark Mode
                    borderSide: BorderSide(
                      color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.black,
                    ),
                  )
                : InputBorder.none,
            // fillColor: ThemeProvider.isDarkModeCheck() ? Colors.black : Colors.white,
            isDense: AppHelper.isMobileDevice(context),
            filled: true,
            // fillColor: Colors.red,
          ),
        ),
        //===========================================================================================================
      ),
      //============================Here are the properties of the dropdown button===============================
      dropdownButtonProps: DropdownButtonProps(
        color: isDropdownEnabled
            ? ThemeProvider.isDarkModeCheck()
                ? Colors.white
                : Colors.black
            : Colors.grey,
        icon: const Icon(
          // Icons.keyboard_arrow_down_outlined,
          Icons.arrow_drop_down_outlined,
          size: 30,
          color: Color(0XFF999999),
        ),
        isVisible: true,
        // isVisible: false,
      ),
      asyncItems: listItemBinding == null ? null : (String filter) => listItemBinding!(),
      items: listOfItems ?? [],
      itemAsString: (dynamic item) => isSingleValue ? item : item.dropdownText,
      enabled: isDropdownEnabled,
      clearButtonProps: ClearButtonProps(
        icon: Icon(
          Icons.clear,
          size: 20,
        ),
        isVisible: isShowClearIcon && selectedValue != null,
        // iconSize: 5,
        onPressed: onCrossPressed,
        color: isDropdownEnabled
            ? isDarkMode
                ? Colors.white
                : Colors.black
            : Colors.grey,
      ),
      // validator: (value) {
      //   if (isValidationRequired && value == null) {
      //     return AppLocalizations.of(context)!.requireField;
      //   }
      // },
      //=========================================DropDown itself=========================================
      dropdownDecoratorProps: DropDownDecoratorProps(
        baseStyle: TextStyle(color: isDarkMode ? Colors.white : appPrimaryColor),
        textAlignVertical: TextAlignVertical.center,
        dropdownSearchDecoration: InputDecoration(
          border: const OutlineInputBorder(
            borderSide: BorderSide(width: 10),
          ),
          isCollapsed: !isShowBorder,
          prefixIcon: prefixIconData != null
              ? Icon(
                  prefixIconData,
                  color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.black,
                )
              : null,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: true,
          // filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          // border: InputBorder(borderSide: BorderSide()),
          // decoration: const InputDecoration(
          //   border: OutlineInputBorder(),
          // ),
          // fillColor: const Color(0XFFF1F1F1),
          fillColor: ThemeProvider.isDarkModeCheck() ? Colors.grey[700] : const Color(0XFFF1F1F1),
          // fillColor: Colors.grey[700],
          isDense: AppHelper.isMobileDevice(context),
          // enabledBorder: isShowBorder ? OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.black, width: 1)) : InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            // borderSide: BorderSide(color: Colors.transparent, width: 1),
            borderSide: BorderSide.none,
          ),
          focusedBorder: isShowBorder ? OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.black, width: 1)) : InputBorder.none,
          // hintStyle: TextStyle(color: Colors.red, fontSize: 14),
          // suffixStyle: TextStyle(color: Colors.red, fontSize: 14),
          disabledBorder: isShowBorder ? OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.grey, width: 1)) : InputBorder.none,
          labelText: isLabel ? labelText : null,
          // labelStyle: TextStyle(color: ThemeProvider.isDarkModeCheck() ? Colors.white54 : Colors.grey, fontSize: 14),
          // labelStyle: TextStyle(color: ThemeProvider.isDarkModeCheck() ? const Color(0XFFFFFFFF) : Colors.grey.shade400, fontSize: 14),
          labelStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        ),
      ),
      onChanged: (dynamic item) {
        onDropdownChange(item);
      },
    );
  }
}
