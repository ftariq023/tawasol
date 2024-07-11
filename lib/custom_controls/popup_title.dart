import 'package:flutter/material.dart';

import '../app_models/app_utilities/app_helper.dart';

class PopupTitle extends StatelessWidget {
  PopupTitle({super.key, required this.title, this.icon});

  final String title;

  IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          color: Theme.of(context).colorScheme.primary),
      padding: const EdgeInsets.all(10),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Transform.rotate(
              angle: AppHelper.isCurrentArabic ? 180 * 3.14 / 180 : 0,
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),
          if (icon != null)
            const SizedBox(
              width: 10,
            ),
          Container(
            // width: 230,
            // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
            child: Tooltip(
              message: title,
              child: Row(
                // crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title.contains(":") ? title.split(" : ")[0] : title,
                    // textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (title.contains(":"))
                    Expanded(
                      child: Tooltip(
                        message: title.split(" : ")[1],
                        child: Text(
                          " : ${title.split(" : ")[1]}",
                          // textAlign: TextAlign.center,
                          maxLines: 1,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.close_outlined,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
