import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../app_models/app_utilities/app_helper.dart';
import '../app_models/app_view_models/db_entities/followup_ou.dart';
import '../app_models/app_view_models/db_entities/followup_user.dart';
import '../app_models/app_view_models/db_entities/inbox_Item.dart';
import '../app_models/app_view_models/db_entities/user_comment.dart';
import '../app_models/service_models/service_handler.dart';
import '../custom_controls/custom_dialog.dart';
import '../custom_controls/dropdown.dart';
import '../custom_controls/my_button.dart';
import '../custom_controls/popup_title.dart';

class Transfer extends StatefulWidget {
  const Transfer({super.key, required this.selectedInboxItem, required this.transferCallback});

  final InboxItem selectedInboxItem;
  final Function? transferCallback;

  @override
  State<Transfer> createState() => _TransferState();
}

class _TransferState extends State<Transfer> {
  FollowupOu? _selectedOu;
  FollowupUser? _selectTransferUser;
  final transferFormKey = GlobalKey<FormState>();
  final TextEditingController userCommentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size(200, 50),
        child: PopupTitle(
          title: lang.transfer,
        ),
      ),
      body: Form(
        key: transferFormKey,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: AppHelper.isMobileDevice(context) ? 15 : 30),
                  child: Dropdown(
                    isLabel: true,
                    listItemType: FollowupOu,
                    selectedValue: _selectedOu,
                    listItemBinding: () {
                      return ServiceHandler.getFollowupOrTransferOUs(forTransfer: true);
                    },
                    isValidationRequired: true,
                    labelText: lang.selectOU,
                    isShowTopLabel: false,
                    onDropdownChange: (dynamic item) {
                      setState(() {
                        _selectedOu = item;
                        _selectTransferUser = null;
                      });
                    },
                    isSearchEnabled: true,
                    prefixIconData: Icons.account_balance_outlined,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: AppHelper.isMobileDevice(context) ? 15 : 30),
                  child: Dropdown(
                    isLabel: true,
                    listItemType: FollowupUser,
                    selectedValue: _selectTransferUser,
                    isShowTopLabel: false,
                    listItemBinding: () {
                      return ServiceHandler.getFollowupOrTransferUsers(_selectedOu!.id);
                    },
                    isValidationRequired: true,
                    labelText: lang.selectOuUser,
                    onDropdownChange: (dynamic item) {
                      setState(() {
                        _selectTransferUser = item;
                      });
                    },
                    isSearchEnabled: true,
                    isDropdownEnabled: _selectedOu != null,
                    prefixIconData: Icons.person_2_outlined,
                  ),
                ),
                FutureBuilder<List<UserComment>>(
                    future: ServiceHandler.getUserComments(),
                    builder: (BuildContext context, AsyncSnapshot<List<UserComment>> snapshot) {
                      if (!snapshot.hasData) {
                        // while data is loading:
                        return Center(
                          child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                //  color: AppHelper.myColor('#ededed'),
                                alignment: AppHelper.isCurrentArabic ? Alignment.centerRight : Alignment.centerLeft,
                                child: Text(
                                  lang.selectComment,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 140,
                                child: ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      UserComment userComment = snapshot.data![index];
                                      return GestureDetector(
                                        onTap: () {
                                          userCommentController.text = userComment.comment;
                                        },
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(userComment.shortComment, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 0.5),
                                  color: AppHelper.myColor('#ededed'),
                                ),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return lang.requireField;
                                    } else {
                                      return null;
                                    }
                                  },
                                  controller: userCommentController,
                                  maxLines: 3,
                                  //or null
                                  decoration: InputDecoration.collapsed(hintStyle: TextStyle(color: Colors.grey.shade400), hintText: lang.writeComment),
                                ),
                              ),
                              // const SizedBox(height: 10),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   mainAxisSize: MainAxisSize.min,
                              //   children: [
                              //     MyButton(
                              //       btnText:
                              //           lang.transfer,
                              //       onTap: () {
                              //
                              //         if(transferFormKey.currentState!.validate()){}
                              //       },
                              //     ),
                              //     const SizedBox(
                              //       width: 20,
                              //     ),
                              //     MyButton(
                              //         btnText:
                              //             lang.back,
                              //         textColor: AppHelper.myColor('#FFFFFF'),
                              //         backgroundColor:
                              //             AppHelper.myColor("#757575"),
                              //         onTap: () => Navigator.of(context).pop())
                              //   ],
                              // ),
                            ],
                          ),
                        );
                      }
                    })
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            MyButton(
              btnText: lang.transfer,
              onTap: () async {
                if (transferFormKey.currentState!.validate()) {
                  AppHelper.showLoaderDialog(context);

                  bool isTransferred = await ServiceHandler.transferDocument(
                    _selectTransferUser!.domainName,
                    widget.selectedInboxItem.wobNumber,
                    _selectedOu!.id.toString(),
                    userCommentController.text,
                  );
                  AppHelper.hideLoader(context);

                  if (isTransferred) {
                    Navigator.of(context).pop();

                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  } else {
                    await AppHelper.showCustomAlertDialog(
                      context,
                      null,
                      lang.errorMessage,
                      lang.close,
                      null,
                    );
                  }
                  if (widget.transferCallback != null) {
                    widget.transferCallback!();
                  }
                }
              },
            ),
            const SizedBox(
              width: 20,
            ),
            MyButton(
              btnText: lang.back,
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
