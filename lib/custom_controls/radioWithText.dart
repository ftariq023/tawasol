import 'package:flutter/material.dart';

class RadioWithText extends StatelessWidget {
  int rValue;
  String rText;
  int rSelectedOption;
  Function(int i) rOnChanged;

  RadioWithText({
    required this.rSelectedOption,
    required this.rValue,
    required this.rOnChanged,
    required this.rText,
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
          Text(rText),
        ],
      ),
    );
  }
}
