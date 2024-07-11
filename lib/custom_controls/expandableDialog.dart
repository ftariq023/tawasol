import 'package:flutter/material.dart';

import '../theme/theme_provider.dart';

class ExpandableDialog extends StatefulWidget {
  var rLang;
  String moreContent;

  ExpandableDialog(
    this.rLang,
    this.moreContent,
  );

  @override
  _ExpandableDialogState createState() => _ExpandableDialogState();
}

class _ExpandableDialogState extends State<ExpandableDialog> {
  bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ThemeProvider.isDarkMode ? null : Colors.white,
      surfaceTintColor: ThemeProvider.isDarkMode ? null : Colors.white,
      shadowColor: null,
      contentPadding: const EdgeInsets.all(20),
      actionsPadding: const EdgeInsets.only(bottom: 10),
      actionsAlignment: MainAxisAlignment.center,
      shape: RoundedRectangleBorder(side: BorderSide(width: 0.5, color: Colors.grey.shade700), borderRadius: const BorderRadius.all(Radius.circular(10))),
      title: Text(
        widget.rLang.errorMessage,
        style: const TextStyle(
          // color: Colors.grey.shade800,
          fontSize: 16,
        ),
      ),
      // title: Text('Alert Dialog'),
      content: SingleChildScrollView(
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // if (_showMore)
            //   Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text('More content to show...'),
            //       Text('More content to show...'),
            //       Text('More content to show...'),
            //     ],
            //   ),
            if (_showMore) Text(widget.moreContent),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  _showMore = !_showMore;
                });
              },
              child: Row(
                children: [
                  Text(
                    _showMore ? widget.rLang.showLess : widget.rLang.showMore,
                  ),
                  SizedBox(width: 5),
                  Icon(
                    _showMore ? Icons.arrow_circle_up_rounded : Icons.arrow_circle_down_rounded,
                    size: 20,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(widget.rLang.close),
        ),
      ],
    );
  }
}
