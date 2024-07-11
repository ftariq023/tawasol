import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

// import '../app_models/app_utilities/app_helper.dart';
// import '../theme/theme_provider.dart';

// ignore: must_be_immutable
class RoundedContainer extends StatelessWidget {
  String btnText;
  Color contClr;
  double bordRadius;
  double btnFontSize;
  double contHgt;
  double contWdt;
  double margLeft;
  double margRight;
  double paddingHor;
  double paddingVer;

  RoundedContainer({
    required this.btnText,
    required this.contClr,
    required this.bordRadius,
    required this.contHgt,
    required this.contWdt,
    required this.btnFontSize,
    this.margLeft = 0,
    this.margRight = 0,
    this.paddingHor = 0,
    this.paddingVer = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: contHgt,
      width: contWdt,
      padding: EdgeInsets.symmetric(horizontal: paddingHor, vertical: paddingVer),
      margin: EdgeInsets.only(right: margRight, left: margLeft),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // color: ThemeProvider.lightenClr(ThemeProvider.primaryColor, 12),
        color: contClr,
        // borderRadius: BorderRadius.circular(12.0),
        borderRadius: BorderRadius.circular(bordRadius),
      ),
      child: Text(
        btnText,
        style: TextStyle(
          // fontSize: AppHelper.isCurrentArabic ? 14 : 10,
          fontSize: btnFontSize,
          color: Colors.white,
        ),
      ),
    );
  }
}
