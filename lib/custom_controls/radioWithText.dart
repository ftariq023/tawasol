import 'package:flutter/material.dart';

import '../app_models/app_utilities/app_helper.dart';

class RadioWithText extends StatelessWidget {
  int rValue;
  String rText;
  int rSelectedOption;
  double mWdt;
  Function(int i) rOnChanged;

  RadioWithText({
    required this.rSelectedOption,
    required this.rValue,
    required this.rOnChanged,
    required this.rText,
    required this.mWdt,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => rOnChanged(rValue),
      child: Row(
        children: [
          Container(
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     width: 1,
            //     color: Colors.red,
            //   ),
            // ),
            child: Radio<int>(
              value: rValue,
              groupValue: rSelectedOption,
              onChanged: (value) => rOnChanged(value!),
              // onChanged: (value) {},
            ),
          ),
          Text(
            rText,
            style: TextStyle(
              // fontSize: Directionality.of(context) == TextDirection.rtl ? mWdt * 0.035 : mWdt * 0.026,
              fontSize: Directionality.of(context) == TextDirection.rtl
                  ? AppHelper.isMobileDevice(context)
                      ? mWdt * 0.035
                      : mWdt * 0.025
                  : mWdt * 0.026,
            ),
          ),
        ],
      ),
    );
  }
}
