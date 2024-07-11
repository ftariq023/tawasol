import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecentActionContainer extends StatelessWidget {
  String actionName;
  double mHgt;
  double mWdt;
  VoidCallback onPressFunc;

  RecentActionContainer(
    this.actionName,
    this.mHgt,
    this.mWdt,
    this.onPressFunc,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressFunc,
          child: IntrinsicWidth(
            child: Container(
              // color: Color(0XFFF1EDE6),
              padding: EdgeInsets.all(mWdt * 0.02),
              decoration: BoxDecoration(
                // color: ThemeProvider.lightenClr(ThemeProvider.primaryColor, 12),
                color: Color(0XFFF1EDE6),
                // borderRadius: BorderRadius.circular(12.0),
                borderRadius: BorderRadius.circular(mWdt * 0.05),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up_rounded),
                  SizedBox(
                    width: mWdt * 0.018,
                  ),
                  Text(actionName),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: mHgt * 0.01)
      ],
    );
  }
}
