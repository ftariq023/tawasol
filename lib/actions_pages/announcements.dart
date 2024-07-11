import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/app_models/app_view_models/announcement_model.dart';
import 'package:tawasol/custom_controls/popup_title.dart';

import '../custom_controls/my_button.dart';

class Announcements extends StatelessWidget {
  const Announcements({super.key});

  @override
  Widget build(BuildContext context) {
    final themePrimaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size(400, 50),
        child: PopupTitle(
          title: AppLocalizations.of(context)!.announcements,
          icon: Icons.volume_up_outlined,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: CarouselSlider.builder(
            options: CarouselOptions(
              autoPlay: true,
              viewportFraction: 1,
              autoPlayInterval: const Duration(seconds: 3),
            ),
            itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
              AnnouncementModel currentAnnouncement = AppHelper.currentUserSession.announcements[itemIndex];
              return SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: Card(
                    elevation: null,
                    shape: RoundedRectangleBorder(side: BorderSide(color: AppHelper.myColor("#d4d4d4"), width: 0.5), borderRadius: BorderRadius.circular(8)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(currentAnnouncement.subject, maxLines: 2, style: TextStyle(fontSize: 16, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w500, color: themePrimaryColor)),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Html(
                                data: currentAnnouncement.body,
                                style: {
                                  "body": Style(
                                      // color: themePrimaryColor,
                                      // color: Colors.red,
                                      ),
                                  "p": Style(
                                      // color: themePrimaryColor,
                                      // color: Colors.red,
                                      ),
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "${itemIndex + 1} ${AppLocalizations.of(context)!.ofForSlider} ${AppHelper.currentUserSession.announcements.length}",
                            style: TextStyle(color: themePrimaryColor),
                          )
                        ],
                      ),
                    )),
              );
            },
            itemCount: AppHelper.currentUserSession.announcements.length,
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            MyButton(
              btnText: AppLocalizations.of(context)!.back,
              textColor: AppHelper.myColor('#FFFFFF'),
              backgroundColor: AppHelper.myColor("#757575"),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
