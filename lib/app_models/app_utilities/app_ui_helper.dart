import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './app_helper.dart';

class AppUIHelper {





  static DateTime timeStampToDate(int timeStamp) {
    return DateTime.fromMicrosecondsSinceEpoch(timeStamp * 1000);
  }

  static void showCustomAlert(
          {required BuildContext context,
          required String message,
          required String accept,
          String titleText = '',
          String reject = ''}) =>
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: titleText.isNotEmpty ? Text(titleText) : null,
          //buttonPadding: null,
          content: Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          actions: <Widget>[
            if (reject.isNotEmpty)
              TextButton(
                style: const ButtonStyle(alignment: Alignment.center),
                onPressed: () => Navigator.pop(context, reject),
                child: Text(reject),
              ),
            if (accept.isNotEmpty)
              ElevatedButton(
                onPressed: () => Navigator.pop(context, accept),
                child: Text(accept),
              ),
          ],
        ),
      );


 static PageRouteBuilder pageBuilder(dynamic currentRoute){
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => currentRoute,

      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },

    );

  }

// final output = await CacheManager.localDirectoryPath;
// final file = File("${output.path}/$fileName.pdf");
// await file.writeAsBytes(bytes.buffer.asUint8List());
// return file;
}
