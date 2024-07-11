import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecentRcptContainer extends StatelessWidget {
  String rcptName;
  double mHgt;
  double mWdt;
  VoidCallback onPressFunc;
  bool isChecked;
  Color appPrimClr;

  RecentRcptContainer(
    this.rcptName,
    this.mHgt,
    this.mWdt,
    this.onPressFunc,
    this.isChecked,
    this.appPrimClr,
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
                color: isChecked ? appPrimClr : const Color(0XFFF1EDE6),
                // borderRadius: BorderRadius.circular(12.0),
                borderRadius: BorderRadius.circular(mWdt * 0.05),
              ),
              child: Row(
                children: [
                  Icon(
                    isChecked ? Icons.check : Icons.trending_up_rounded,
                    color: isChecked ? const Color(0XFFFFFFFF) : null,
                  ),
                  SizedBox(width: mWdt * 0.018),
                  Text(
                    rcptName,
                    style: TextStyle(
                      color: isChecked ? const Color(0XFFFFFFFF) : null,
                    ),
                  ),
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
