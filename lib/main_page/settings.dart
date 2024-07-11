// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:tawasol/app_models/app_utilities/cache_manager.dart';
// import 'package:tawasol/app_models/app_utilities/theme_model.dart';
// import 'package:tawasol/app_models/app_view_models/proxy_user.dart';
// import 'package:tawasol/app_models/service_models/service_handler.dart';
// import 'package:tawasol/theme/theme_provider.dart';
// import '../app_models/app_utilities/app_helper.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// import '../app_models/versionProvider.dart';
// import '../custom_controls/custom_dialog.dart';
// import '../main.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AppSettings extends StatefulWidget {
//   const AppSettings({super.key});

//   @override
//   State<AppSettings> createState() => _AppSettingsState();
// }

// class _AppSettingsState extends State<AppSettings> {
//   bool _supportState = false;

//   // bool darkMode = false;
//   late final LocalAuthentication auth;

//   @override
//   void initState() {
//     try {
//       isProxyEnabled = AppHelper.currentUserSession.proxyFullName.isNotEmpty;
//       auth = LocalAuthentication();
//       auth.isDeviceSupported().then((bool isSupported) => setState(() {
//             _supportState = isSupported;
//           }));
//     } catch (e) {
//       _supportState = false;
//     }
//     super.initState();
//   }

//   void setProxyData(ProxyUserModel proxyModel) {
//     setState(() {
//       isProxyEnabled = true;
//       AppHelper.currentUserSession.proxyEnName = proxyModel.enFullName;
//       AppHelper.currentUserSession.proxyArName = proxyModel.arFullName;
//     });
//   }

//   bool? isProxyEnabled;

//   void changeColor(String clr) {
//     Provider.of<ThemeProvider>(context, listen: false)
//         .changePrimClr(AppHelper.myColor(clr), context, clr);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: Colors.amber,
//       body: Container(
//         // color: Colors.amber,
//         padding: const EdgeInsets.all(10),
//         child: SingleChildScrollView(
//           padding: EdgeInsets.only(bottom: 30),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Card(
//               //   child: TextButton.icon(
//               //     icon: const Icon(Icons.g_translate_outlined),
//               //     label: Text(AppLocalizations.of(context)!.changeLanguage),
//               //     onPressed: () {
//               //       AppHelper.changeLocalization(context);
//               //     },
//               //   ),
//               // ),
//               // const SizedBox(
//               //   height: 10,
//               // ),
//               //==========================================Version Number======================================
//               // Text(AppLocalizations.of(context)!.versionNumber),
//               // Card(
//               //   child: Padding(
//               //     padding: const EdgeInsets.all(8.0),
//               //     child:
//               //         Text(AppHelper.currentTawasolEntity.tawasolVersionNumber),
//               //   ),
//               // ),

//               Text(AppLocalizations.of(context)!.appVersionNumber),
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Consumer<VersionProvider>(
//                     builder: (context, versionProvider, child) {
//                       return Text(
//                           '${AppLocalizations.of(context)!.version} ${versionProvider.version}');
//                     },
//                   ),
//                 ),
//               ),

//               //==========================================FingerPrint======================================
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       Text(AppLocalizations.of(context)!.enableBiometric),
//                       const Spacer(),
//                       Switch(
//                         value: AppHelper.currentUserSession.isBiometricEnabled,
//                         onChanged: !_supportState
//                             ? null
//                             : (bool val) async {
//                                 setState(() {
//                                   AppHelper.currentUserSession
//                                       .isBiometricEnabled = val;
//                                 });
//                                 if (val) {
//                                   bool fingerPrintSuccess =
//                                       await _authenticate();
//                                   if (fingerPrintSuccess) {
//                                     setState(() async {
//                                       CacheManager.updateBiometric(true);
//                                       AppHelper.currentUserSession
//                                               .isBiometricEnabled =
//                                           fingerPrintSuccess;
//                                     });
//                                   } else {
//                                     setState(() {
//                                       CacheManager.updateBiometric(false);
//                                       AppHelper.currentUserSession
//                                           .isBiometricEnabled = false;
//                                     });
//                                   }
//                                 } else {
//                                   CacheManager.updateBiometric(false);
//                                 }
//                               },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               //==========================================On Leave======================================
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 10),
//                         child: Row(
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(bottom: 3),
//                                   child: Text(
//                                       AppLocalizations.of(context)!.onVacation),
//                                 ),
//                                 Text(
//                                   AppLocalizations.of(context)!
//                                       .onVacationWarning,
//                                   style: const TextStyle(color: Colors.red),
//                                 ),
//                               ],
//                             ),
//                             const Spacer(),
//                             Switch(
//                                 value: isProxyEnabled!,
//                                 onChanged: (value) async {
//                                   // CustomDialog.showProxyDialog(
//                                   //     context, setProxyData);
//                                   if (value) {
//                                     CustomDialog.showProxyDialog(
//                                         context, setProxyData);
//                                   } else {
//                                     if ((await AppHelper.showCustomAlertDialog(
//                                             context,
//                                             AppLocalizations.of(context)!
//                                                 .terminate,
//                                             AppLocalizations.of(context)!
//                                                 .assistantTerminateWarning,
//                                             AppLocalizations.of(context)!.yes,
//                                             AppLocalizations.of(context)!
//                                                 .no)) ==
//                                         AppLocalizations.of(context)!.yes) {
//                                       await AppHelper.showLoaderDialog(context);
//                                       bool result = await ServiceHandler
//                                           .terminateProxyUser();
//                                       AppHelper.hideLoader(context);

//                                       if (result) {
//                                         await AppHelper.showCustomAlertDialog(
//                                             context,
//                                             null,
//                                             AppLocalizations.of(context)!
//                                                 .assistantTerminateSuccess,
//                                             AppLocalizations.of(context)!.close,
//                                             null);
//                                         setState(() {
//                                           isProxyEnabled = value;
//                                           AppHelper.currentUserSession
//                                               .proxyArName = '';
//                                           AppHelper.currentUserSession
//                                               .proxyEnName = '';
//                                         });
//                                       } else {
//                                         await AppHelper.showCustomAlertDialog(
//                                             context,
//                                             null,
//                                             AppLocalizations.of(context)!
//                                                 .errorMessage,
//                                             AppLocalizations.of(context)!.close,
//                                             null);
//                                         return;
//                                       }
//                                     }
//                                   }
//                                 }),
//                           ],
//                         ),
//                       ),
//                       if (AppHelper.currentUserSession.proxyArName.isNotEmpty)
//                         Row(
//                           children: [
//                             // Text("Assistant Name", style: TextStyle(
//                             //    color: Theme.of(context).colorScheme.primary,fontSize: 16),),
//                             Text(
//                               AppHelper.currentUserSession.proxyFullName,
//                               style: TextStyle(
//                                   color: Theme.of(context).colorScheme.primary,
//                                   fontSize: 16),
//                             )
//                           ],
//                         )
//                     ],
//                   ),
//                 ),
//               ),
//               //==============================================Adapt System Theme==========================================
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       Text(
//                         AppLocalizations.of(context)!.adaptSystemTheme,
//                       ),
//                       Spacer(),
//                       Checkbox(
//                         value: ThemeProvider.adaptSystemTheme,
//                         onChanged: (_) {
//                           setState(() {
//                             // ThemeProvider.adaptSystemTheme = !ThemeProvider.adaptSystemTheme;
//                             Provider.of<ThemeProvider>(context, listen: false)
//                                 .toggleAdaptSystemTheme();
//                           });
//                         },
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               //==============================================Dark/Light Mode==========================================
//               if (!ThemeProvider.adaptSystemTheme)
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         Text(
//                           AppLocalizations.of(context)!.darkMode,
//                         ),
//                         Spacer(),
//                         Switch(
//                           value: ThemeProvider.isDarkMode,
//                           onChanged: (_) {
//                             Provider.of<ThemeProvider>(context, listen: false)
//                                 .toggleTheme();
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//               const SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 AppLocalizations.of(context)!.themeColors,
//                 style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w400,
//                     color: Theme.of(context).colorScheme.primary),
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   Flexible(
//                     child: GestureDetector(
//                       onTap: () {
//                         // Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r1c1), context);
//                         changeColor(ThemeModel.r1c1);
//                       },
//                       child: Container(
//                         height: 50,
//                         color: AppHelper.myColor(ThemeModel.r1c1),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Flexible(
//                     child: GestureDetector(
//                       onTap: () {
//                         // Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r1c2), context);
//                         changeColor(ThemeModel.r1c2);
//                       },
//                       child: Container(
//                         height: 50,
//                         color: AppHelper.myColor(ThemeModel.r1c2),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Flexible(
//                     child: GestureDetector(
//                       onTap: () {
//                         // Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r1c3), context);
//                         changeColor(ThemeModel.r1c3);
//                       },
//                       child: Container(
//                         height: 50,
//                         color: AppHelper.myColor(ThemeModel.r1c3),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Flexible(
//                     child: GestureDetector(
//                       onTap: () {
//                         // Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r1c4), context);
//                         changeColor(ThemeModel.r1c4);
//                       },
//                       child: Container(
//                         height: 50,
//                         color: AppHelper.myColor(ThemeModel.r1c4),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   Flexible(
//                     child: GestureDetector(
//                       onTap: () {
//                         // Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r2c1), context);
//                         changeColor(ThemeModel.r2c1);
//                       },
//                       child: Container(
//                         height: 50,
//                         color: AppHelper.myColor(ThemeModel.r2c1),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Flexible(
//                     child: GestureDetector(
//                       onTap: () {
//                         // Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r2c2), context);
//                         changeColor(ThemeModel.r2c2);
//                       },
//                       child: Container(
//                         height: 50,
//                         color: AppHelper.myColor(ThemeModel.r2c2),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Flexible(
//                     child: GestureDetector(
//                       onTap: () {
//                         // Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r2c3), context);
//                         changeColor(ThemeModel.r2c3);
//                       },
//                       child: Container(
//                         height: 50,
//                         color: AppHelper.myColor(ThemeModel.r2c3),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Flexible(
//                     child: GestureDetector(
//                       onTap: () {
//                         // Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r2c4), context);
//                         changeColor(ThemeModel.r2c4);
//                       },
//                       child: Container(
//                         height: 50,
//                         color: AppHelper.myColor(ThemeModel.r2c4),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   Flexible(
//                     child: GestureDetector(
//                       onTap: () {
//                         // Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r3c1), context);
//                         changeColor(ThemeModel.r3c1);
//                       },
//                       child: Container(
//                         height: 50,
//                         color: AppHelper.myColor(ThemeModel.r3c1),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Flexible(
//                     child: GestureDetector(
//                       onTap: () {
//                         // Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r3c2), context);
//                         changeColor(ThemeModel.r3c2);
//                       },
//                       child: Container(
//                         height: 50,
//                         color: AppHelper.myColor(ThemeModel.r3c2),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Flexible(
//                     child: GestureDetector(
//                       onTap: () {
//                         // Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r3c3), context);
//                         changeColor(ThemeModel.r3c3);
//                       },
//                       child: Container(
//                         height: 50,
//                         color: AppHelper.myColor(ThemeModel.r3c3),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Flexible(
//                     child: GestureDetector(
//                       onTap: () {
//                         // Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r3c4), context);
//                         changeColor(ThemeModel.r3c4);
//                       },
//                       child: Container(
//                         height: 50,
//                         color: AppHelper.myColor(ThemeModel.r3c4),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<bool> _authenticate() async {
//     try {
//       bool authenticate = await auth.authenticate(
//           localizedReason: 'Register yourself for easy login',
//           options: const AuthenticationOptions(
//               stickyAuth: true, biometricOnly: true));
//       //  print('Authenticated: $authenticate');
//       return authenticate;
//     } on PlatformException catch (e) {
//       print(e);
//       return false;
//     }
//   }
// }

// Future<ThemeData> _fetchSystemTheme() async {
//   // Implement logic to fetch the current system theme
//   // For example, you can use the platform channel to communicate with native code
//   // and retrieve the system theme.
//   // This might vary depending on the platform (Android/iOS).
//   // For simplicity, let's assume light theme for now.
//   return ThemeData.light();
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:tawasol/app_models/app_utilities/app_routes.dart';
import 'package:tawasol/app_models/app_utilities/cache_manager.dart';
import 'package:tawasol/app_models/app_utilities/theme_model.dart';
import 'package:tawasol/app_models/app_view_models/proxy_user.dart';
import 'package:tawasol/app_models/service_models/service_handler.dart';
import 'package:tawasol/theme/theme_provider.dart';
import '../app_models/app_utilities/app_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_models/versionProvider.dart';
import '../custom_controls/custom_dialog.dart';
import '../main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});
  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  bool _supportState = false;

// bool darkMode = false;
  late final LocalAuthentication auth;
  @override
  void initState() {
    try {
      isProxyEnabled = AppHelper.currentUserSession.proxyFullName.isNotEmpty;

      auth = LocalAuthentication();

      auth.isDeviceSupported().then((bool isSupported) => setState(() {
            _supportState = isSupported;
          }));
    } catch (e) {
      _supportState = false;
    }
    super.initState();
  }

  void setProxyData(ProxyUserModel? proxyModel) {
    setState(() {
      isProxyEnabled = true;
      if (proxyModel != null) {
        AppHelper.currentUserSession.proxyEnName = proxyModel.enFullName;

        AppHelper.currentUserSession.proxyArName = proxyModel.arFullName;
      } else {
        AppHelper.currentUserSession.proxyEnName = '';

        AppHelper.currentUserSession.proxyArName = '';
      }
    });
  }

  bool? isProxyEnabled;

  void changeColor(String clr) {
    Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(clr), context, clr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.amber,
      body: Container(
        // color: Colors.amber,
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
// Card(

// child: TextButton.icon(

// icon: const Icon(Icons.g_translate_outlined),

// label: Text(AppLocalizations.of(context)!.changeLanguage),

// onPressed: () {

// AppHelper.changeLocalization(context);

// },

// ),

// ),

// const SizedBox(

// height: 10,

// ),

//==========================================Version Number======================================

// Text(AppLocalizations.of(context)!.versionNumber),

// Card(

// child: Padding(

// padding: const EdgeInsets.all(8.0),

// child:

// Text(AppHelper.currentTawasolEntity.tawasolVersionNumber),

// ),

// ),
              Text(AppLocalizations.of(context)!.appVersionNumber),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Consumer<VersionProvider>(
                    builder: (context, versionProvider, child) {
                      return Text('${AppLocalizations.of(context)!.version} ${versionProvider.version}');
                    },
                  ),
                ),
              ),

//==========================================FingerPrint======================================
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(AppLocalizations.of(context)!.enableBiometric),
                      const Spacer(),
                      Switch(
                        value: AppHelper.currentUserSession.isBiometricEnabled,
                        onChanged: !_supportState
                            ? null
                            : (bool val) async {
                                setState(() {
                                  AppHelper.currentUserSession.isBiometricEnabled = val;
                                });
                                if (val) {
                                  bool fingerPrintSuccess = await AppHelper.authenticate();
                                  if (fingerPrintSuccess) {
                                    setState(() async {
                                      CacheManager.updateBiometric(true);

                                      AppHelper.currentUserSession.isBiometricEnabled = fingerPrintSuccess;
                                    });
                                  } else {
                                    setState(() {
                                      CacheManager.updateBiometric(false);

                                      AppHelper.currentUserSession.isBiometricEnabled = false;
                                    });
                                  }
                                } else {
                                  CacheManager.updateBiometric(false);
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ),

//==========================================On Leave======================================
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    // AppLocalizations.of(context)!.onVacation,
                                    "تحديد معاون",
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.onVacationWarning,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                                onPressed: () {
                                  Routes.moveProxyUser(context: context, callback: setProxyData);

// CustomDialog.showProxyDialog(

// context, setProxyData);
                                },
                                icon: const Icon(CupertinoIcons.add_circled)),

// Switch(

// value: isProxyEnabled!,

// onChanged: (value) async {

// // CustomDialog.showProxyDialog(

// // context, setProxyData);

// if (value) {

// CustomDialog.showProxyDialog(

// context, setProxyData);

// } else {

// if ((await AppHelper.showCustomAlertDialog(

// context,

// AppLocalizations.of(context)!

// .terminate,

// AppLocalizations.of(context)!

// .assistantTerminateWarning,

// AppLocalizations.of(context)!.yes,

// AppLocalizations.of(context)!

// .no)) ==

// AppLocalizations.of(context)!.yes) {

// await AppHelper.showLoaderDialog(context);

// bool result = await ServiceHandler

// .terminateProxyUser();

// AppHelper.hideLoader(context);

//

// if (result) {

// await AppHelper.showCustomAlertDialog(

// context,

// null,

// AppLocalizations.of(context)!

// .assistantTerminateSuccess,

// AppLocalizations.of(context)!.close,

// null);

// setState(() {

// isProxyEnabled = value;

// AppHelper.currentUserSession

// .proxyArName = '';

// AppHelper.currentUserSession

// .proxyEnName = '';

// });

// } else {

// await AppHelper.showCustomAlertDialog(

// context,

// null,

// AppLocalizations.of(context)!

// .errorMessage,

// AppLocalizations.of(context)!.close,

// null);

// return;

// }

// }

// }

// }),
                          ],
                        ),
                      ),
                      if (AppHelper.currentUserSession.proxyArName.isNotEmpty)
                        Row(
                          children: [
                            // Text("Assistant Name", style: TextStyle(
                            // color: Theme.of(context).colorScheme.primary,fontSize: 16),),
                            Text(
                              AppHelper.currentUserSession.proxyFullName,
                              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                            )
                          ],
                        )
                    ],
                  ),
                ),
              ),

//==============================================Adapt System Theme==========================================
              GestureDetector(
                onTap: () => setState(() {
                  Provider.of<ThemeProvider>(context, listen: false).toggleAdaptSystemTheme();
                }),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.adaptSystemTheme,
                        ),
                        Spacer(),
                        Checkbox(
                          value: ThemeProvider.adaptSystemTheme,
                          onChanged: (_) {
                            setState(() {
                              Provider.of<ThemeProvider>(context, listen: false).toggleAdaptSystemTheme();
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
//==============================================Dark/Light Mode==========================================
              if (!ThemeProvider.adaptSystemTheme)
                GestureDetector(
                  onTap: () => setState(() {
                    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                  }),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.darkMode,
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                // ThemeProvider.adaptSystemTheme = !ThemeProvider.adaptSystemTheme;
                                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                              });
                            },
                            icon: const Icon(Icons.contrast_outlined),
                          ),
                          // Switch(
                          //   value: ThemeProvider.isDarkMode,
                          //   onChanged: (_) {
                          //     Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                          //   },
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
              Text(
                AppLocalizations.of(context)!.themeColors,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
// Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r1c1), context);

                        changeColor(ThemeModel.r1c1);
                      },
                      child: Container(
                        height: 50,
                        color: AppHelper.myColor(ThemeModel.r1c1),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        // Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r1c2), context);
                        changeColor(ThemeModel.r1c2);
                      },
                      child: Container(
                        height: 50,
                        color: AppHelper.myColor(ThemeModel.r1c2),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        // Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r1c3), context);
                        changeColor(ThemeModel.r1c3);
                      },
                      child: Container(
                        height: 50,
                        color: AppHelper.myColor(ThemeModel.r1c3),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        // Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r1c4), context);
                        changeColor(ThemeModel.r1c4);
                      },
                      child: Container(
                        height: 50,
                        color: AppHelper.myColor(ThemeModel.r1c4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
// Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r2c1), context);

                        changeColor(ThemeModel.r2c1);
                      },
                      child: Container(
                        height: 50,
                        color: AppHelper.myColor(ThemeModel.r2c1),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
// Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r2c2), context);

                        changeColor(ThemeModel.r2c2);
                      },
                      child: Container(
                        height: 50,
                        color: AppHelper.myColor(ThemeModel.r2c2),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
// Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r2c3), context);

                        changeColor(ThemeModel.r2c3);
                      },
                      child: Container(
                        height: 50,
                        color: AppHelper.myColor(ThemeModel.r2c3),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
// Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r2c4), context);

                        changeColor(ThemeModel.r2c4);
                      },
                      child: Container(
                        height: 50,
                        color: AppHelper.myColor(ThemeModel.r2c4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
// Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r3c1), context);

                        changeColor(ThemeModel.r3c1);
                      },
                      child: Container(
                        height: 50,
                        color: AppHelper.myColor(ThemeModel.r3c1),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
// Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r3c2), context);

                        changeColor(ThemeModel.r3c2);
                      },
                      child: Container(
                        height: 50,
                        color: AppHelper.myColor(ThemeModel.r3c2),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
// Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r3c3), context);

                        changeColor(ThemeModel.r3c3);
                      },
                      child: Container(
                        height: 50,
                        color: AppHelper.myColor(ThemeModel.r3c3),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
// Provider.of<ThemeProvider>(context, listen: false).changePrimClr(AppHelper.myColor(ThemeModel.r3c4), context);

                        changeColor(ThemeModel.r3c4);
                      },
                      child: Container(
                        height: 50,
                        color: AppHelper.myColor(ThemeModel.r3c4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<ThemeData> _fetchSystemTheme() async {
// Implement logic to fetch the current system theme

// For example, you can use the platform channel to communicate with native code

// and retrieve the system theme.

// This might vary depending on the platform (Android/iOS).

// For simplicity, let's assume light theme for now.
  return ThemeData.light();
}
