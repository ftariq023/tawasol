import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/theme/theme_provider.dart';

class MyTextField2 extends StatelessWidget {
  String labelText;
  bool isDense;
  bool isSearchScreen;
  TextEditingController ctrl;
  bool isFloatingLabel;
  bool isPasswordType;
  bool isShowBorder;
  bool isSearchScreenBorder;
  bool isEnabled;
  bool isLoginPage;
  double? textFieldWidth;
  double horizontalPadding;
  IconData? prefixIconData;
  bool isShowClear;
  bool isValidationRequired;
  Function? onTextFieldTap;
  Function? onSubmit;
  Function? onPasswordShow;
  Function? onClearTap;
  bool isKeyboardEnabled;
  bool isShowTodayBtn;
  bool isMob;
  bool isPort;
  double mHgt;
  double mWdt;
  VoidCallback? rSetTodaysDate;

  MyTextField2({
    super.key,
    required this.labelText,
    required this.ctrl,
    this.isPasswordType = false,
    this.isEnabled = true,
    this.isLoginPage = false,
    this.isDense = true,
    this.isShowBorder = false,
    this.isSearchScreenBorder = false,
    this.isFloatingLabel = false,
    this.isKeyboardEnabled = true,
    this.horizontalPadding = 10,
    this.onTextFieldTap,
    this.onClearTap,
    this.isShowClear = false,
    this.isValidationRequired = true,
    this.isSearchScreen = false,
    this.prefixIconData,
    this.textFieldWidth,
    this.onPasswordShow,
    this.onSubmit,
    required this.mHgt,
    required this.mWdt,
    this.rSetTodaysDate,
    this.isShowTodayBtn = false,
    this.isMob = true,
    this.isPort = true,
  });

  @override
  Widget build(BuildContext context) {
    Color appPrimaryColor = Theme.of(context).colorScheme.primary;
    bool isDarkMode = ThemeProvider.isDarkModeCheck();

    return Container(
      width: textFieldWidth,
      // padding: EdgeInsets.symmetric(
      //   horizontal: horizontalPadding,
      //   vertical: mWdt! * 0.1,
      // ),
      child: TextFormField(
        enabled: isEnabled,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onFieldSubmitted: (_) {
          if (onSubmit != null) onSubmit!();
        },
        style: TextStyle(
          color: isSearchScreen
              ? isDarkMode
                  ? const Color(0XFFFFFFFF)
                  : appPrimaryColor
              : isDarkMode
                  ? Colors.white
                  : Colors.black,
          // fontSize: mWdt! * 0.08,
        ),
        obscureText: isPasswordType,
        controller: ctrl,
        keyboardType: isKeyboardEnabled ? null : TextInputType.none,
        validator: (value) {
          if (isValidationRequired && value!.isEmpty) return AppLocalizations.of(context)!.requireField;
        },
        onTap: () {
          if (onTextFieldTap != null) onTextFieldTap!();
          //  else null;
        },
        // textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: isDense,
          isCollapsed: isSearchScreenBorder,
          contentPadding: EdgeInsets.symmetric(
            horizontal: mWdt! * 0.02,
            vertical: mHgt! * 0.016,
          ),
          errorStyle: TextStyle(
            color: (isLoginPage || ThemeProvider.isDarkModeCheck()) ? Colors.white : Colors.red,
          ),
          suffixIcon: isShowClear && !isShowTodayBtn
              ? GestureDetector(
                  onTap: () {
                    if (onClearTap != null) onClearTap!();
                  },
                  child: const Icon(Icons.close_outlined),
                )
              : onPasswordShow != null
                  ? IconButton(
                      onPressed: () {
                        onPasswordShow!();
                      },
                      icon: Icon(
                        (onPasswordShow != null && isPasswordType) ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill,
                      ),
                    )
                  : isShowClear && isShowTodayBtn
                      ? Container(
                          width: isMob ? mWdt! * 0.22 : mWdt! * 0.19,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                // onTap: setTodaysDate,
                                onTap: rSetTodaysDate,
                                child: Container(
                                  height: isMob
                                      ? mHgt! * 0.035
                                      : isPort
                                          ? mHgt! * 0.025
                                          : mHgt! * 0.04,
                                  width: isMob ? mWdt! * 0.135 : mWdt! * 0.1,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Color(0XFF585858) : Color(0XFFF4F4F4),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Text(
                                    AppHelper.isCurrentArabic ? "اليوم" : "Today",
                                    style: TextStyle(
                                      fontSize: isMob
                                          ? mWdt! * 0.028
                                          : isPort
                                              ? mWdt! * 0.02
                                              : mWdt! * 0.015,
                                      color: isDarkMode ? Colors.white : appPrimaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (onClearTap != null) onClearTap!();
                                  // else null;
                                },
                                child: const Icon(Icons.close_outlined),
                              ),
                            ],
                          ),
                        )
                      : null,
          labelText: labelText,
          suffixIconColor: onPasswordShow != null ? AppHelper.myColor('#0c4160') : null,
          labelStyle: TextStyle(color: ThemeProvider.isDarkModeCheck() ? Colors.white54 : Colors.grey.shade400, fontSize: 13),
          // labelStyle: const TextStyle(color: Colors.grey),
          floatingLabelBehavior: isFloatingLabel ? FloatingLabelBehavior.auto : FloatingLabelBehavior.never,
          prefixIcon: prefixIconData == null
              ? null
              : isLoginPage
                  ? SvgPicture.asset(
                      onPasswordShow != null ? "assets/images/lock_login_new.svg" : "assets/images/person_login_new.svg",
                      theme: SvgTheme(
                        currentColor: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : Icon(
                      prefixIconData,
                      color: !isEnabled ? Colors.grey : null,
                    ),
          // enabledBorder: OutlineInputBorder(borderSide: isShowBorder ? BorderSide(color: Colors.grey.shade400) : const BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(8)),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(mWdt! * 0.02),
          ),
          disabledBorder: isSearchScreenBorder ? InputBorder.none : const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: isSearchScreenBorder
              ? InputBorder.none
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isLoginPage ? 18 : 8),
                  borderSide: BorderSide(
                    color: ThemeProvider.isDarkModeCheck() ? Colors.white : Colors.black,
                    width: 1,
                  ),
                ),
          // fillColor: Colors.white,
          fillColor: const Color(0XFFF1F1F1),
          filled: true,
        ),
      ),
    );
  }
}
