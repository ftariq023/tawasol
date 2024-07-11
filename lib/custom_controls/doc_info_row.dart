import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/theme/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DocInfoCustomRow extends StatelessWidget {
  const DocInfoCustomRow({
    super.key,
    required this.title,
    required this.value,
    required this.isGreyRow,
    required this.isCopy,
    required this.onPressed,
    this.isDate = false,
    this.maxLinesForText = 2,
  });

  final String title;
  final String value;
  final bool isGreyRow;
  final bool isDate;
  final int maxLinesForText;
  final bool isCopy;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final Color rowColor = AppHelper.myColor('#f4f4f4');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      // decoration: BoxDecoration(border: Border.fromBorderSide(BorderSide(width: 0.5, color: AppHelper.myColor("#d4d4d4")))),
      height: 55,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Divider(
          //   height: 1,
          // ),
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Tooltip(
              message: value,
              child: Text(
                value,
                maxLines: maxLinesForText,
                textDirection: isDate ? TextDirection.ltr : null,
                textAlign: AppHelper.isCurrentArabic ? TextAlign.right : null,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14, fontFamily: isDate ? 'Arial' : null),
              ),
            ),
          ),
          if (isCopy == true)
            IconButton(
              onPressed: () {
                onPressed?.call();

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.black,
                    content: Text(
                      AppLocalizations.of(context)!.copied,
                      style: const TextStyle(color: Colors.white),
                    )));
              },
              icon: const Icon(CupertinoIcons.doc_on_clipboard),
            ),
        ],
      ),
    );
  }
}
