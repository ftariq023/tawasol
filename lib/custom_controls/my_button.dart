import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyButton extends StatelessWidget {
  MyButton(
      {super.key,
      required this.btnText,
      required this.onTap,
      this.btnIconData,
      this.verticalPadding = 5,
      this.horizontalPadding = 0,
      this.backgroundColor,
      this.borderColor,
      this.textColor,
      this.svgPicturePath,
      this.isWhiteColor,
      this.btnWidth = -1,
      this.btnHeight = -1,
      this.isLoginButton = false});

  final Function()? onTap;
  final String btnText;
  final IconData? btnIconData;
  final double verticalPadding;
  final double horizontalPadding;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  String? svgPicturePath;
  bool? isWhiteColor;
  bool isLoginButton;
  double btnWidth;
  double btnHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: isLoginButton
      //     ? (AppHelper.isMobileDevice(context) ? double.maxFinite : null)
      //     : null,
      child: ElevatedButton.icon(
        icon: btnIconData != null
            ? Icon(
                btnIconData,
                color: Colors.white,
              )
            : svgPicturePath != null
                ? SvgPicture.asset(
                    svgPicturePath!,
                    theme: SvgTheme(
                      currentColor: isWhiteColor == true
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                    ),
                  )
                : const SizedBox.shrink(),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          fixedSize: btnWidth > 0 ? Size(btnWidth, btnHeight) : null,
          backgroundColor:
              backgroundColor ?? Theme.of(context).colorScheme.primary,
          // shadowColor: isLoginButton ? Colors.white : null,
          //elevation: isLoginButton ? 2 : null,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: borderColor ?? Colors.transparent)),
        ),
        label: Padding(
          padding: EdgeInsets.only(
            top: verticalPadding,
            bottom: verticalPadding,
            left: btnIconData != null ? 0 : horizontalPadding,
            right: horizontalPadding,
          ),
          child: Text(
            btnText,
            style: TextStyle(
              fontSize: 18.0,
              color: textColor ?? Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
