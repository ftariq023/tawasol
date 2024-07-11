import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import '../app_models/app_utilities/app_helper.dart';

class DocumentViewer extends StatelessWidget {
  const DocumentViewer({super.key, required this.docFile});

  final Uint8List docFile;

  @override
  Widget build(BuildContext context) {
    return SfPdfViewerTheme(
      data: SfPdfViewerThemeData(
        backgroundColor: AppHelper.myColor("#f8f8f8"),

        //<----
      ),

       // padding:  const EdgeInsets.symmetric(horizontal: 10),
        child:SfPdfViewer.memory(docFile,

              canShowPageLoadingIndicator: true,
              enableTextSelection: true),

    );
  }
}
