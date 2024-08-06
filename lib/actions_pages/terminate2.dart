import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/app_models/app_view_models/db_entities/user_comment.dart';
import 'package:tawasol/custom_controls/my_button.dart';
import 'package:tawasol/theme/theme_provider.dart';
import '../app_models/app_utilities/app_routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_models/service_models/service_handler.dart';
import '../custom_controls/radioWithText.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

class TerminateDocument2 extends StatefulWidget {
  List selectedInboxItems;

  TerminateDocument2({
    super.key,
    required this.selectedInboxItems,
  });

  @override
  State<TerminateDocument2> createState() => _TerminateDocument2State();
}

class _TerminateDocument2State extends State<TerminateDocument2> {
  final terminateFormKey = GlobalKey<FormState>();
  final TextEditingController userCommentController = TextEditingController(text: "تم الإنجاز");
  CustomPopupMenuController menuController = CustomPopupMenuController();
  //
  bool showDropDown = false;
  int selectedOption = 1;

  Future<List<UserComment>> getUserComments() async {
    return await ServiceHandler.getUserComments();
  }

  Future onTerminatePressed2(BuildContext context) async {
    if (terminateFormKey.currentState!.validate()) {
      AppHelper.showLoaderDialog(context);

      List failedTerminationSubjects = [];

      for (var selectedInboxItem in widget.selectedInboxItems) {
        bool isTerminated = await ServiceHandler.terminateDocument(
          selectedInboxItem.docClassId,
          selectedInboxItem.wobNumber,
          userCommentController.text,
        );

        if (!isTerminated) failedTerminationSubjects.add(selectedInboxItem.docSubject);
      }

      AppHelper.hideLoader(context);

      if (failedTerminationSubjects.isEmpty)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.terminateSuccess)));
      else {
        String failedSubjects = "";
        for (var subject in failedTerminationSubjects) failedSubjects += subject + ", ";
        failedSubjects = failedSubjects.substring(0, failedSubjects.length - 2);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${AppLocalizations.of(context)!.terminationFailedFor}: $failedSubjects",
            ),
          ),
        );
      }

      Navigator.of(context).pop();
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      Routes.moveDashboard(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var mqContext = MediaQuery.of(context);
    var size = mqContext.size;

    var mHeight = size.height - AppBar().preferredSize.height - mqContext.padding.top - mqContext.padding.bottom;
    var mWidth = size.width;

    bool isPortrait = mqContext.orientation == Orientation.portrait;

    var lang = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: ThemeProvider.isDarkModeCheck() ? Colors.black : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(7),
          topRight: Radius.circular(7),
        ),
      ),
      //===================================================Main Container=======================================
      child: Column(
        children: [
          //=============================================Header============================================
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            width: double.infinity,
            child: Row(
              children: [
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.terminate,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          //================================================Body==============================================
          Container(
            // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.red)),
            alignment: Alignment.center,
            child: FutureBuilder<List<UserComment>>(
              future: getUserComments(),
              builder: (BuildContext context, AsyncSnapshot<List<UserComment>> snapshot) {
                if (!snapshot.hasData) {
                  //==============================Loader=======================================
                  return Container(
                    // decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.red)),
                    // height: 300,
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 270,
                      child: Center(
                        child: CupertinoActivityIndicator(
                          color: Theme.of(context).colorScheme.primary,
                          animating: true,
                          radius: 15,
                        ),
                      ),
                    ),
                  );
                } else {
                  //======================================Body of Container=================================
                  return Form(
                    key: terminateFormKey,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //===================================Comment Pop up===========================================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              RadioWithText(
                                rSelectedOption: selectedOption,
                                rValue: 1,
                                rText: "تم الإنجاز",
                                mWdt: mWidth,
                                rOnChanged: (value) => setState(() {
                                  selectedOption = value;
                                  userCommentController.text = "تم الإنجاز";
                                  Haptics.vibrate(HapticsType.light);
                                  showDropDown = false;
                                }),
                              ),
                              RadioWithText(
                                rSelectedOption: selectedOption,
                                rValue: 2,
                                rText: "تم العلم",
                                mWdt: mWidth,
                                rOnChanged: (value) => setState(() {
                                  selectedOption = value;
                                  userCommentController.text = "تم العلم";
                                  Haptics.vibrate(HapticsType.light);
                                  showDropDown = false;
                                }),
                              ),
                              RadioWithText(
                                rSelectedOption: selectedOption,
                                rValue: 3,
                                rText: "أخرى",
                                mWdt: mWidth,
                                rOnChanged: (value) => setState(() {
                                  selectedOption = value;
                                  userCommentController.text = "";
                                  Haptics.vibrate(HapticsType.light);
                                  showDropDown = true;
                                }),
                              ),
                            ],
                          ),
                          if (showDropDown)
                            CustomPopupMenu(
                              pressType: PressType.singleClick,
                              arrowSize: 20,
                              showArrow: true,
                              barrierColor: const Color.fromARGB(122, 0, 0, 0),
                              controller: menuController,
                              arrowColor: Theme.of(context).colorScheme.primary,
                              position: PreferredPosition.bottom,
                              verticalMargin: 0,
                              // verticalMargin: -50,
                              // horizontalMargin: 50,
                              child: Container(
                                padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.selectComment,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            // color: ThemeProvider.isDarkMode ? Colors.white : Theme.of(context).colorScheme.primary,
                                            color: ThemeProvider.isDarkModeCheck() ? Colors.white : Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          // color: ThemeProvider.isDarkMode ? Colors.white : Theme.of(context).colorScheme.primary,
                                          color: ThemeProvider.isDarkModeCheck() ? Colors.white : Theme.of(context).colorScheme.primary,
                                        )
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                                      child: Divider(
                                        // color: ThemeProvider.isDarkMode ? Colors.white : Theme.of(context).colorScheme.primary,
                                        color: ThemeProvider.isDarkModeCheck() ? Colors.white : Theme.of(context).colorScheme.primary,
                                        height: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              menuBuilder: () {
                                return Container(
                                  height: 300,
                                  width: 350,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.background,
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(color: Theme.of(context).colorScheme.primary, width: 0.5),
                                  ),
                                  child: ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.only(top: 10),
                                    itemBuilder: (context, index) {
                                      UserComment userComment = snapshot.data![index];
                                      return GestureDetector(
                                        onTap: () {
                                          menuController.hideMenu();
                                          userCommentController.text = userComment.comment;
                                        },
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Text(
                                                userComment.shortComment,
                                                // style: TextStyle(color: ThemeProvider.isDarkMode ? Colors.white : Theme.of(context).colorScheme.primary),
                                                style: TextStyle(color: ThemeProvider.isDarkModeCheck() ? Colors.white : Theme.of(context).colorScheme.primary),
                                              ),
                                            ),
                                            const Divider(
                                              color: Colors.grey,
                                              indent: 10,
                                              endIndent: 10,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 20),
                          //======================================Text Form for Comments=======================================
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(5)),
                              border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
                            ),
                            child: TextFormField(
                              decoration: InputDecoration.collapsed(
                                enabled: true,
                                // hintStyle: TextStyle(color: ThemeProvider.isDarkMode ? Colors.white54 : Colors.grey.shade400),
                                hintStyle: TextStyle(color: ThemeProvider.isDarkModeCheck() ? Colors.white54 : Colors.grey.shade400),
                                hintText: AppLocalizations.of(context)!.writeComment,
                              ),
                              // style: TextStyle(color: ThemeProvider.isDarkMode ? Colors.white : ThemeProvider.primaryColor),
                              style: TextStyle(color: ThemeProvider.isDarkModeCheck() ? Colors.white : ThemeProvider.primaryColor),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return AppLocalizations.of(context)!.requireField;
                                }
                              },
                              controller: userCommentController,
                              maxLines: 3,
                            ),
                          ),
                          const SizedBox(height: 40),
                          //=======================================Termination Button====================================================
                          SizedBox(
                            width: 230,
                            child: MyButton(
                              btnText: AppLocalizations.of(context)!.terminate,
                              onTap: () => onTerminatePressed2(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
