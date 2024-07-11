import 'package:flutter/material.dart';

import '../app_models/app_utilities/app_helper.dart';

class SlideAction extends StatelessWidget {
  const SlideAction({super.key, required this.imageName, required this.actionName});

  final String imageName;
  final String actionName;

  @override
  Widget build(BuildContext context) {
    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     Image(
    //       image: AssetImage("assets/images/$imageName.png"),
    //       height: 32,
    //       width: 32,
    //     ),
    //     // SvgPicture.asset(
    //     //   "assets/images/$imageName.svg",
    //     //   theme: const SvgTheme(currentColor: Colors.white),
    //     // ),
    //     Text(
    //       actionName,
    //       style: const TextStyle(
    //         color: Colors.white,
    //         fontWeight: FontWeight.w400,
    //       ),
    //     )
    //   ],
    // );

    // new:

    return Container(
      height: 65,
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     width: 1,
      //     color: Colors.black,
      //   ),
      // ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image(
            image: AssetImage("assets/images/$imageName.png"),
            height: 32,
            width: 32,
          ),
          Text(
            actionName,
            maxLines: 2,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: AppHelper.isCurrentArabic ? 14 : 12,
            ),
          )
        ],
      ),
    );
  }
}
