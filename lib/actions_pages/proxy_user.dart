// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// import '../app_models/app_utilities/app_helper.dart';
// import '../app_models/app_view_models/db_entities/organization_unit.dart';
// import '../app_models/app_view_models/proxy_user.dart';
// import '../app_models/service_models/service_handler.dart';
// import '../custom_controls/dropdown.dart';
// import '../custom_controls/my_button.dart';
// import '../custom_controls/popup_title.dart';

// class ProxyUser extends StatefulWidget {
//   const ProxyUser({super.key, required this.proxyCallback});

//   final Function? proxyCallback;

//   @override
//   State<ProxyUser> createState() => _ProxyUserState();
// }

// class _ProxyUserState extends State<ProxyUser> {
//   OrganizationUnit? _selectedProxyOu;
//   ProxyUserModel? _selectedProxyUser;

//   GlobalKey<FormState>? proxyUserFormKey;

//   @override
//   void initState() {
//     proxyUserFormKey = GlobalKey<FormState>();
//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       // backgroundColor: Theme.of(context).colorScheme.background,

//       appBar: PreferredSize(
//         preferredSize: const Size(400, 50),
//         child: PopupTitle(
//           title: AppLocalizations.of(context)!.selectProxyUser,
//         ),
//       ),
//       body: Form(
//         key: proxyUserFormKey,
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             children: [
//               //  if (AppHelper.currentUserSession.isManager)
//               Dropdown(
//                 isLabel: true,
//                 listItemType: OrganizationUnit,
//                 selectedValue: _selectedProxyOu,
//                 listItemBinding: ServiceHandler.getOUListForManagerProxy,
//                 isValidationRequired: true,
//                 labelText: AppLocalizations.of(context)!.selectOU,
//                 onDropdownChange: (dynamic item) {
//                   setState(() {
//                     _selectedProxyOu = item;
//                     _selectedProxyUser = null;
//                   });
//                 },
//                 isSearchEnabled: true,
//                 prefixIconData: Icons.account_balance_outlined,
//               ),
//               //  if (AppHelper.currentUserSession.isManager)
//               SizedBox(
//                 height: AppHelper.isMobileDevice(context) ? 15 : 30,
//               ),
//               Dropdown(
//                 isLabel: true,
//                 listItemType: ProxyUserModel,
//                 selectedValue: _selectedProxyUser,
//                 isShowClearIcon: _selectedProxyUser != null,
//                 listItemBinding: () {
//                   return ServiceHandler.getProxyUsers(
//                       // AppHelper.currentUserSession.isManager
//                       //     ? _selectedProxyOu!.ouID
//                       //     : AppHelper.currentUserSession.ouId
//                       _selectedProxyOu!.ouID);
//                 },
//                 isValidationRequired: true,
//                 isDropdownEnabled: _selectedProxyOu != null,

//                 // isDropdownEnabled: (!AppHelper.currentUserSession.isManager ||
//                 //     (AppHelper.currentUserSession.isManager &&
//                 //         _selectedProxyOu != null)),
//                 labelText: AppLocalizations.of(context)!.selectOuUser,
//                 onDropdownChange: (dynamic item) {
//                   setState(() {
//                     _selectedProxyUser = item;
//                   });
//                 },
//                 isSearchEnabled: true,
//                 prefixIconData: Icons.person_2_outlined,
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             MyButton(
//               btnText: AppLocalizations.of(context)!.save,
//               onTap: () async {
//                 if (proxyUserFormKey!.currentState!.validate()) {
//                   await AppHelper.showLoaderDialog(context);

//                   bool result = await ServiceHandler.setProxyUser(_selectedProxyUser!, _selectedProxyOu!.ouID);

//                   AppHelper.hideLoader(context);

//                   if (result) {
//                     await AppHelper.showCustomAlertDialog(context, null, AppLocalizations.of(context)!.assistantSaved, AppLocalizations.of(context)!.close, null);
//                     Navigator.of(context).pop();
//                     if (widget.proxyCallback != null) {
//                       widget.proxyCallback!(_selectedProxyUser);
//                     }
//                   } else {
//                     await AppHelper.showCustomAlertDialog(context, null, AppLocalizations.of(context)!.errorMessage, AppLocalizations.of(context)!.close, null);
//                     return;
//                   }
//                 }
//               },
//             ),
//             const SizedBox(
//               width: 20,
//             ),
//             MyButton(
//               btnText: AppLocalizations.of(context)!.back,
//               textColor: AppHelper.myColor('#FFFFFF'),
//               backgroundColor: AppHelper.myColor("#757575"),
//               onTap: () => Navigator.of(context).pop(),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_models/app_utilities/app_helper.dart';
import '../app_models/app_view_models/db_entities/organization_unit.dart';
import '../app_models/app_view_models/proxy_user.dart';
import '../app_models/service_models/service_handler.dart';
import '../custom_controls/dropdown.dart';
import '../custom_controls/my_button.dart';
import '../custom_controls/popup_title.dart';

class ProxyUser extends StatefulWidget {
  ProxyUser({super.key, required this.proxyCallback, this.onLeave = false});
  final Function? proxyCallback;
  bool onLeave;
  @override
  State<ProxyUser> createState() => _ProxyUserState();
}

class _ProxyUserState extends State<ProxyUser> {
  OrganizationUnit? _selectedProxyOu;
  ProxyUserModel? _selectedProxyUser;
  GlobalKey<FormState>? proxyUserFormKey;
  @override
  void initState() {
    proxyUserFormKey = GlobalKey<FormState>();
// TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
// backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 80),
        child: AppBar(
// backgroundColor: null,
//appPrimaryColor,
          title: Text(
            AppLocalizations.of(context)!.selectProxyUser,
            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white, overflow: TextOverflow.ellipsis),
          ),
// flexibleSpace: Container(
// decoration: const BoxDecoration(
// image: DecorationImage(
// image: AssetImage('assets/images/header_moi.png'),
// fit: BoxFit.fill)),
// ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
// borderRadius: BorderRadius.only(
// bottomLeft: Radius.circular(20),
// Adjust the border radius for left bottom
// bottomRight: Radius.circular(20), // Adjust the border radius for right bottom
// ),
            ),
          ),
// backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              iconSize: 32,
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: proxyUserFormKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
// if (AppHelper.currentUserSession.isManager)
              Dropdown(
                isLabel: true,
                listItemType: OrganizationUnit,
                selectedValue: _selectedProxyOu,
                listItemBinding: ServiceHandler.getOUListForManagerProxy,
                isValidationRequired: true,
                isShowBorder: false,
                labelText: AppLocalizations.of(context)!.selectOU,
                onDropdownChange: (dynamic item) {
                  setState(() {
                    _selectedProxyOu = item;
                    _selectedProxyUser = null;
                  });
                },
                isSearchEnabled: true,
// prefixIconData: Icons.account_balance_outlined,
              ),
              const Divider(
                thickness: 0.2,
                color: Colors.grey,
              ),
// if (AppHelper.currentUserSession.isManager)
// SizedBox(
// height: AppHelper.isMobileDevice(context) ? 15 : 30,
// ),
              Dropdown(
                isLabel: true,
                isShowBorder: false,
                listItemType: ProxyUserModel,
                selectedValue: _selectedProxyUser,
                isShowClearIcon: _selectedProxyUser != null,
                listItemBinding: () {
                  return ServiceHandler.getProxyUsers(
// AppHelper.currentUserSession.isManager
// ? _selectedProxyOu!.ouID
// : AppHelper.currentUserSession.ouId
                      _selectedProxyOu!.ouID);
                },
                isValidationRequired: true,
                isDropdownEnabled: _selectedProxyOu != null,
// isDropdownEnabled: (!AppHelper.currentUserSession.isManager ||
// (AppHelper.currentUserSession.isManager &&
// _selectedProxyOu != null)),
                labelText: AppLocalizations.of(context)!.selectOuUser,
                onDropdownChange: (dynamic item) {
                  setState(() {
                    _selectedProxyUser = item;
                  });
                },
                isSearchEnabled: true,
// prefixIconData: Icons.person_2_outlined,
              ),
              const Divider(
                thickness: 0.2,
                color: Colors.grey,
              ),
              Row(
                children: [
                  Text(AppLocalizations.of(context)!.onVacation),
                  const Spacer(),
                  Switch(
                      value: widget.onLeave,
                      onChanged: (value) {
                        setState(() {
                          widget.onLeave = value;
                        });
                      }),
                ],
              ),
              const Divider(
                thickness: 0.2,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 20,
              ),
              if (AppHelper.currentUserSession.proxyFullName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    children: [
// Text('${AppLocalizations.of(context)!.userProxy}: '),
// const SizedBox(
// width: 35,
// ),
                      Text("المعاون/ "),
                      Text(AppHelper.currentUserSession.proxyFullName),
                      const Spacer(),
                      if (AppHelper.currentUserSession.outOfOffice) Text(AppLocalizations.of(context)!.onVacation),
                      const SizedBox(
                        width: 20,
                      ),
                      Container(
                        color: Colors.red,
                        child: TextButton(
                          onPressed: () async {
                            AppHelper.showLoaderDialog(context);
                            bool result = await ServiceHandler.terminateProxyUser();
                            if (result) {
                              AppHelper.hideLoader(context);
                              AppHelper.currentUserSession.proxyEnName = AppHelper.currentUserSession.proxyArName = '';
                              _selectedProxyOu = null;
                              _selectedProxyUser = null;
                              widget.onLeave = false;
                              if (widget.proxyCallback != null) {
                                widget.proxyCallback!(null);
                              }
                              setState(() {});
                            } else {
                              AppHelper.hideLoader(context);
                              await AppHelper.showCustomAlertDialog(context, null, AppLocalizations.of(context)!.errorMessage, AppLocalizations.of(context)!.close, null);
                            }
                          },
                          child: Text(
                            // AppLocalizations.of(context)!.terminate,
                            "إنهاء",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
// ElevatedButton(
// onPressed: () async {
// AppHelper.showLoaderDialog(context);
// bool result =
// await ServiceHandler.terminateProxyUser();
// if (result) {
// AppHelper.hideLoader(context);
// AppHelper.currentUserSession.proxyEnName =
// AppHelper.currentUserSession.proxyArName = '';
// _selectedProxyOu = null;
// _selectedProxyUser = null;
// widget.onLeave = false;
//
// setState(() {});
// } else {
// AppHelper.hideLoader(context);
//
// await AppHelper.showCustomAlertDialog(
// context,
// null,
// AppLocalizations.of(context)!.errorMessage,
// AppLocalizations.of(context)!.close,
// null);
// }
// },
// child: Text(AppLocalizations.of(context)!.terminate))
                    ],
                  ),
                ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyButton(
                    btnText: AppLocalizations.of(context)!.save,
                    onTap: () async {
                      if (proxyUserFormKey!.currentState!.validate()) {
                        await AppHelper.showLoaderDialog(context);
                        bool result = await ServiceHandler.setProxyUser(_selectedProxyUser!, _selectedProxyOu!.ouID, widget.onLeave);
                        AppHelper.hideLoader(context);
                        if (result) {
// await AppHelper.showCustomAlertDialog(
// context,
// null,
// AppLocalizations.of(context)!.assistantSaved,
// AppLocalizations.of(context)!.close,
// null);
                          AppHelper.currentUserSession.outOfOffice = widget.onLeave;
                          AppHelper.currentUserSession.proxyArName = _selectedProxyUser!.arFullName;
                          AppHelper.currentUserSession.proxyEnName = _selectedProxyUser!.enFullName;
                          setState(() {});
// Navigator.of(context).pop();
                          if (widget.proxyCallback != null) {
                            widget.proxyCallback!(_selectedProxyUser);
                          }
                        } else {
                          await AppHelper.showCustomAlertDialog(context, null, AppLocalizations.of(context)!.errorMessage, AppLocalizations.of(context)!.close, null);
                          return;
                        }
                      }
                    },
                  ),
// const SizedBox(
// width: 20,
// ),
// MyButton(
// btnText: AppLocalizations.of(context)!.back,
// textColor: AppHelper.myColor('#FFFFFF'),
// backgroundColor: AppHelper.myColor("#757575"),
// onTap: () => Navigator.of(context).pop(),
// )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
