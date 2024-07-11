import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../app_models/app_utilities/app_helper.dart';
import '../app_models/app_view_models/db_entities/inbox_Item.dart';
import '../app_models/app_view_models/db_entities/search_result_item.dart';
import '../app_models/app_view_models/db_entities/sent_Item.dart';
import '../app_models/app_view_models/view_document_model.dart';
import '../app_models/service_models/service_urls.dart';
import '../custom_controls/doc_info_row.dart';
import '../theme/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PrintDocInfo {
  const PrintDocInfo(this.currentItem);

  final dynamic currentItem;

  static printGeneratedDocInfoPdf(
      dynamic currentItem, BuildContext context, bool isShare) async {
    // PdfPreview(
    //   build: (_) => generatePdf(currentItem, context),
    // );

    if (isShare) {
      await Printing.sharePdf(
          bytes: await generatePdf(currentItem, context),
          filename: currentItem.docSubject);
    } else {
      await Printing.layoutPdf(
          onLayout: (_) => generatePdf(currentItem, context));
    }
  }

  static Future<Uint8List> generatePdf(
      dynamic currentItem, BuildContext ctx) async {
    final pdf = pw.Document(
      version: PdfVersion.pdf_1_5,
      compress: true,
    );
    // final font = await PdfGoogleFonts.adventProRegular();
    final font = await PdfGoogleFonts.notoNaskhArabicRegular();
    //   final font = await fontFromAssetBundle('assets/fonts/arial.ttf');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: AppHelper.isCurrentArabic
            ? pw.TextDirection.rtl
            : pw.TextDirection.ltr,
        build: (context) {
          return pw.Column(children: [
            pw.SizedBox(
              width: double.infinity,
              child: pw.Center(
                child: pw.Text(
                  AppLocalizations.of(ctx)!.documentInfo,
                  style: pw.TextStyle(font: font, fontSize: 16),
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1)),
              child: pw.Column(children: [
                pw.SizedBox(height: 10),
                if (currentItem is! LinkedDocument)
                  getInfoRow(AppLocalizations.of(ctx)!.serialNumber,
                      currentItem.docSerial, font),
                if (currentItem is! LinkedDocument)
                  pw.Container(
                      height: 0.3,
                      width: double.infinity,
                      color: PdfColors.grey500),
                getInfoRow(AppLocalizations.of(ctx)!.docSub,
                    currentItem.docSubject, font),
                pw.Container(
                    height: 0.3,
                    width: double.infinity,
                    color: PdfColors.grey500),
                if (currentItem is! LinkedDocument &&
                    (currentItem is! SearchResultItem ||
                        (currentItem is SearchResultItem &&
                            currentItem.mainSite != '')))
                  pw.Column(
                    children: [
                      getInfoRow(AppLocalizations.of(ctx)!.mainSite,
                          currentItem.mainSite, font),
                      pw.Container(
                          height: 0.3,
                          width: double.infinity,
                          color: PdfColors.grey500),
                    ],
                  ),
                if (currentItem is! LinkedDocument &&
                    (currentItem is! SearchResultItem ||
                        (currentItem is SearchResultItem &&
                            currentItem.mainSite != '')))
                  pw.Column(
                    children: [
                      getInfoRow(AppLocalizations.of(ctx)!.subSite,
                          currentItem.subSite, font),
                      pw.Container(
                          height: 0.3,
                          width: double.infinity,
                          color: PdfColors.grey500),
                    ],
                  ),
                getInfoRow(
                    AppLocalizations.of(ctx)!.docSubType,
                    currentItem is LinkedDocument
                        ? currentItem.docClassName
                        : AppHelper.getDocumentType(
                            context: ctx,
                            docType: currentItem is! SearchResultItem
                                ? currentItem.docClassId
                                : AppHelper.getDocumentClassIdByName(currentItem
                                    .classDescription
                                    .toLowerCase())),
                    font),
                pw.Container(
                    height: 0.3,
                    width: double.infinity,
                    color: PdfColors.grey500),
                if (currentItem is InboxItem || currentItem is LinkedDocument)
                  pw.Column(
                    children: [
                      getInfoRow(
                          AppLocalizations.of(ctx)!.docCreatedDate,
                          DateFormat()
                              .addPattern(AppDefaults.dateFormat)
                              .format(currentItem.createdOn),
                          font),

                      pw.Container(
                          height: 0.3,
                          width: double.infinity,
                          color: PdfColors.grey500),

                      if (currentItem is! SentItem)
                        pw.Column(
                          children: [
                            getInfoRow(AppLocalizations.of(ctx)!.securityLevel,
                                currentItem.securityLevelName, font),
                            pw.Container(
                                height: 0.3,
                                width: double.infinity,
                                color: PdfColors.grey500),
                          ],
                        ),
                      if (currentItem is InboxItem ||
                          currentItem is LinkedDocument)
                        pw.Column(
                          children: [
                            getInfoRow(AppLocalizations.of(ctx)!.priorityLevel,
                                currentItem.priorityLevelName, font),
                          ],
                        ),
                      pw.Container(
                          height: 0.3,
                          width: double.infinity,
                          color: PdfColors.grey500),
                      // DocInfoCustomRow(
                      //     title: AppLocalizations.of(context)!.folder,
                      //     value: 'Inbox',
                      //     isGreyRow: true),
                      if (currentItem is! LinkedDocument &&
                          currentItem.followupDate != null)
                        pw.Column(
                          children: [
                            getInfoRow(
                                AppLocalizations.of(ctx)!.followupDate,
                                DateFormat()
                                    .addPattern(AppDefaults.dateFormat)
                                    .format(currentItem.followupDate),
                                font),
                            pw.Container(
                                height: 0.3,
                                width: double.infinity,
                                color: PdfColors.grey500),
                          ],
                        ),
                      if (currentItem is! LinkedDocument)
                        getInfoRow(AppLocalizations.of(ctx)!.followupStatus,
                            currentItem.followupStatus, font),
                      if (currentItem is! LinkedDocument)
                        pw.Container(
                            height: 0.3,
                            width: double.infinity,
                            color: PdfColors.grey500),
                      // DocInfoCustomRow(
                      //     title: AppLocalizations.of(context)!
                      //         .linkedDocumentsCount,
                      //     value: currentItem.linkedDocsNo.toString(),
                      //     isGreyRow: false),
                      // DocInfoCustomRow(
                      //     title: AppLocalizations.of(context)!.attachmentCount,
                      //     value: currentItem.linkedDocsNo.toString(),
                      //     isGreyRow: false),
                      if (currentItem is! LinkedDocument)
                        getInfoRow(
                            AppLocalizations.of(ctx)!.receivedOn,
                            DateFormat()
                                .addPattern(AppDefaults.dateFormat)
                                .format(currentItem.receivedDate),
                            font),
                      if (currentItem is! LinkedDocument)
                        pw.Container(
                            height: 0.3,
                            width: double.infinity,
                            color: PdfColors.grey500),
                    ],
                  ),
                if (currentItem is! InboxItem && currentItem is! LinkedDocument)
                  getInfoRow(
                      AppLocalizations.of(ctx)!.actionDate,
                      DateFormat()
                          .addPattern(AppDefaults.dateFormat)
                          .format(currentItem.actionDate),
                      font),
                if (currentItem is! LinkedDocument)
                  pw.Container(
                      height: 0.3,
                      width: double.infinity,
                      color: PdfColors.grey500),
                if (currentItem is! LinkedDocument)
                  getInfoRow(AppLocalizations.of(ctx)!.action,
                      currentItem.actionName, font),
                if (currentItem is! LinkedDocument)
                  pw.Container(
                      height: 0.3,
                      width: double.infinity,
                      color: PdfColors.grey500),
                // if (currentItem is! LinkedDocument)
                //   getInfoRow(AppLocalizations.of(ctx)!.comment,
                //       currentItem.comment, font),
                if (currentItem is! LinkedDocument)
                  pw.Container(
                      height: 0.3,
                      width: double.infinity,
                      color: PdfColors.grey500),
                if (currentItem is LinkedDocument)
                  pw.Column(
                    children: [
                      getInfoRow(
                          AppLocalizations.of(ctx)!.lastModified,
                          DateFormat()
                              .addPattern(AppDefaults.dateFormat)
                              .format(currentItem.lastModified!),
                          font),
                      pw.Container(
                          height: 0.3,
                          width: double.infinity,
                          color: PdfColors.grey500),
                      getInfoRow(AppLocalizations.of(ctx)!.creatorOU,
                          currentItem.creatorOuName, font),
                      pw.Container(
                          height: 0.3,
                          width: double.infinity,
                          color: PdfColors.grey500),
                      getInfoRow(
                          AppLocalizations.of(ctx)!.docDate,
                          DateFormat()
                              .addPattern(AppDefaults.dateFormat)
                              .format(currentItem.docDate!),
                          font),
                      pw.Container(
                          height: 0.3,
                          width: double.infinity,
                          color: PdfColors.grey500),
                      getInfoRow(AppLocalizations.of(ctx)!.createdBy,
                          currentItem.creatorName, font),
                      pw.Container(
                          height: 0.3,
                          width: double.infinity,
                          color: PdfColors.grey500),
                      getInfoRow(AppLocalizations.of(ctx)!.lastModifier,
                          currentItem.lastModifierName, font),
                      pw.Container(
                          height: 0.3,
                          width: double.infinity,
                          color: PdfColors.grey500),
                    ],
                  ),
              ]),
            ),
          ]);
        },
      ),
    );

    return pdf.save();
  }

  static pw.Container getInfoRow(
      String labelText, String? labelValue, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: pw.Row(children: [
        pw.SizedBox(
          width: AppHelper.isCurrentArabic ? 115 : 130,
          child: pw.Text(labelText,
              style: pw.TextStyle(
                  font: font,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black)),
        ),
        if (labelValue != null && labelValue.isNotEmpty)
          pw.Text(labelValue,
              maxLines: 5,
              style: pw.TextStyle(
                  font: font,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black)),
      ]),
    );
  }
}
