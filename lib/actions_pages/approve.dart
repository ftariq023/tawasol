import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/app_models/app_utilities/app_routes.dart';
import 'package:tawasol/app_models/service_models/my_service_response.dart';
import 'package:tawasol/app_models/service_models/service_urls.dart';
import 'package:tawasol/custom_controls/popup_title.dart';
import '../app_models/app_view_models/db_entities/inbox_Item.dart';
import '../app_models/app_view_models/user_signature.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_models/service_models/service_handler.dart';
import '../custom_controls/my_button.dart';

class ApproveDocument extends StatefulWidget {
  ApproveDocument({super.key, required this.selectedInboxItem});

  InboxItem selectedInboxItem;

  @override
  State<ApproveDocument> createState() => _ApproveDocumentState();
}

class _ApproveDocumentState extends State<ApproveDocument> {
  UserSignature? selectedUserSignature;

  // Future<List<UserSignature>> getUserSignatures() async {
  //   return await ServiceHandler.getSignatureList();
  // }

  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size(400, 50),
        child: PopupTitle(
          title: AppLocalizations.of(context)!.approve,
        ),
      ),
      body: FutureBuilder<List<UserSignature>>(
          future: AppHelper.getUserSignatures(context),
          builder: (BuildContext context, AsyncSnapshot<List<UserSignature>> snapshot) {
            if (!snapshot.hasData) {
              // while data is loading:
              return Center(
                child: CupertinoActivityIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  animating: true,
                  radius: 20,
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: snapshot.data!.isEmpty
                      ? Center(
                          child: Text(AppLocalizations.of(context)!.noRecordFound, style: TextStyle(color: Colors.grey.shade700, fontSize: 18)),
                        )
                      : Wrap(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(snapshot.data!.length, (index) {
                            UserSignature userSign = snapshot.data!.elementAt(index);
                            return Container(
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.all(3),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                      selectedUserSignature = userSign;
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(width: selectedIndex == index ? 3 : 1, color: Theme.of(context).colorScheme.primary),
                                          borderRadius: const BorderRadius.all(Radius.circular(3)),
                                        ),
                                        child: Image.memory(
                                          userSign.userSignatureImage,
                                          width: 120,
                                          height: 120,
                                        ),
                                      ),
                                      Text(
                                        userSign.signTitle,
                                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
                                      )
                                    ],
                                  ),
                                ));
                          }),
                        ),
                ),
              );
            }
          }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            MyButton(
              btnText: AppLocalizations.of(context)!.approve,
              onTap: () async {
                if (selectedUserSignature != null) {
                  bool isApproved = await AppHelper.onApproveTapped(context: context, inboxItem: widget.selectedInboxItem, signatureVsId: selectedUserSignature!.vsId);

                  // if (isApproved) {
                  //   Navigator.of(context).pop();
                  //   if (Navigator.of(context).canPop()) {
                  //     Navigator.of(context).pop();
                  //   }
                  //   Routes.moveDashboard(context: context);
                  // }
                  //
                  if (isApproved) {
                    Navigator.of(context).pop();
                    if (widget.selectedInboxItem.securityLevelId == 4)
                      Routes.moveSend(context: context, selectedItem: widget.selectedInboxItem);
                    else {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                      Routes.moveDashboard(context: context);
                    }
                  }
                }
              },
            ),
            const SizedBox(
              width: 20,
            ),
            MyButton(
              btnText: AppLocalizations.of(context)!.back,
              textColor: AppHelper.myColor('#FFFFFF'),
              backgroundColor: AppHelper.myColor("#757575"),
              onTap: () => Navigator.of(context).pop(),
            )
          ],
        ),
      ),
    );
  }
}
