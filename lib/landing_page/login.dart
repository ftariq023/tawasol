import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:tawasol/app_models/app_utilities/app_routes.dart';
import 'package:tawasol/app_models/app_utilities/app_ui_helper.dart';
import 'package:tawasol/app_models/app_utilities/cache_manager.dart';
import 'package:tawasol/app_models/app_view_models/tawasol_entity.dart';
import 'package:tawasol/app_models/app_view_models/user_session.dart';
import 'package:tawasol/app_models/service_models/my_service_response.dart';
import 'package:tawasol/app_models/service_models/service_handler.dart';
import 'package:tawasol/app_models/versionProvider.dart';
import 'package:tawasol/custom_controls/my_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tawasol/l10n/l10n.dart';
import '../custom_controls/custom_dialog.dart';
import '../custom_controls/my_textfield.dart';
import '../main_page/dashboard.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:package_info_plus/package_info_plus.dart';
// import 'package:connectivity/connectivity.dart';

class Login extends StatefulWidget {
  Login({super.key});

  TawasolEntity currentEntity = TawasolEntity();
  UserSession currentUserSession = UserSession();

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late final LocalAuthentication auth;
  bool _supportState = false;
  final loginFormKey = GlobalKey<FormState>();
  List<BiometricType> listOfAuthentications = [];
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  // final usernameController = TextEditingController(text: "tawasol1");
  // final passwordController = TextEditingController(text: "P@ssw0rd");
  final entityCodeController = TextEditingController();
  final entityURLController = TextEditingController();

  bool _isLanguageVisible = false;
  bool _isShowInvalidCredentials = false;

  bool isPasswordShow = false;

  // bool _isShowInvalidCredentials = false;
  String _errorMessage = '';

  _LoginState() {
    // setInitialData().then((data) => setState(() {
    //       widget.currentEntity = data[0];
    //
    //       widget.currentUserSession = data[1];
    //     }));

    try {
      auth = LocalAuthentication();
      auth.isDeviceSupported().then((bool isSupported) => setState(() {
            _supportState = isSupported;
          }));
    } catch (e) {
      _supportState = false;
    }
    try {
      auth.getAvailableBiometrics().then((List<BiometricType> listOfBioMetricType) => setState(() {
            listOfAuthentications = listOfBioMetricType;
          }));
    } catch (e) {
      print(e);
    }
  }

  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  Future<dynamic> setInitialData() async {
    dynamic listOfObjects = [];
    listOfObjects.add(await AppHelper.getCurrentTawasolEntity);
    listOfObjects.add(await AppHelper.getCurrentUserSession);

    await Future.delayed(const Duration(milliseconds: 500));
    return listOfObjects;
  }

  @override
  void initState() {
    setInitialData().then((data) => setState(() {
          widget.currentEntity = data[0];
          widget.currentUserSession = data[1];
        }));
    if (AppHelper.currentUserSession.userName.isNotEmpty) {
      usernameController.text = AppHelper.currentUserSession.userName;
      // passwordController.text = AppHelper.currentUserSession.password;
    }
    if (widget.currentEntity.entityCode.isNotEmpty) {
      AppHelper.currentTawasolEntity = widget.currentEntity;
      // AppHelper.currentUserSession = widget.currentUserSession;
    } else {
      widget.currentEntity = AppHelper.currentTawasolEntity;
      widget.currentUserSession = AppHelper.currentUserSession;
    }

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;

    Future<void> _configureAppSettings(BuildContext context) {
      entityCodeController.text = widget.currentEntity.entityCode;
      entityURLController.text = widget.currentEntity.serviceUrl;

      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        useSafeArea: true,
        builder: (context) {
          final configAppFormKey = GlobalKey<FormState>();
          //push test comment
          return Card(
            semanticContainer: true,
            color: Colors.transparent,
            child: AlertDialog(
              title: Text(
                lang.configApp,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              content: Form(
                key: configAppFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MyTextField(
                      labelText: lang.entityCode,
                      textFieldWidth: 450,
                      isFloatingLabel: true,
                      ctrl: entityCodeController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    MyTextField(
                      labelText: lang.serviceUrl,
                      ctrl: entityURLController,
                      isFloatingLabel: true,
                      textFieldWidth: 450,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: Text(lang.save),
                  onPressed: () async {
                    if (configAppFormKey.currentState!.validate()) {
                      AppHelper.showLoaderDialog(context);
                      TawasolEntity response = await ServiceHandler.getPreLoginInfo(entityCodeController.text, entityURLController.text);
                      // if (response.entityCode.isEmpty) {
                      //   _validateConfigFields(invalidDetails: true);
                      //   Navigator.of(context).pop();
                      //   return;
                      // }

                      AppHelper.hideLoader(context);
                      setState(() {
                        widget.currentEntity = response;
                        Navigator.of(context).pop();
                      });
                    }
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: Text(lang.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    }

//   bool _validateConfigFields({bool invalidDetails = false}) {
//     String errorMessage = '';
//     if (invalidDetails == true) {
//       errorMessage = lang.validateEntityDetails;
//     } else {
//       if (entityCodeController.text.isEmpty || entityURLController.text.isEmpty) {
//         errorMessage = lang.allFieldValidate;
//       }
//     }
//     if (errorMessage.isEmpty) return true;
//     var snackBar = SnackBar(
//       content: Text(errorMessage),
//     );
// // Find the ScaffoldMessenger in the widget tree
// // and use it to show a SnackBar.
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     return false;
//   }
// bool _validateConfigFields({bool invalidDetails = false, String errorMessage = ''}) {
//   if (invalidDetails || errorMessage.isNotEmpty) {
//     var snackBar = SnackBar(
//       // backgroundColor: Colors.red,
//       content: Text(errorMessage),
//     );
//     // Find the ScaffoldMessenger in the widget tree
//     // and use it to show a SnackBar.
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     return false;
//   } else {
//     if (entityCodeController.text.isEmpty || entityURLController.text.isEmpty) {
//       errorMessage = lang.allFieldValidate;
//       var snackBar = SnackBar(
//         content: Text(errorMessage),
//       );
//       // Find the ScaffoldMessenger in the widget tree
//       // and use it to show a SnackBar.
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//       return false;
//     }
//   }
//   return true;
// }

    void _validateConfigFields({bool invalidDetails = false, String errorMessage = ''}) {
      if (invalidDetails || errorMessage.isNotEmpty) {
        _errorMessage.isEmpty ? lang.invalidLogin : _errorMessage;
        setState(() {
          _isShowInvalidCredentials = true;
          _errorMessage = errorMessage;
        });
      } else {
        // Check if entity code or entity URL is empty
        if (entityCodeController.text.isEmpty || entityURLController.text.isEmpty) {
          setState(() {
            _isShowInvalidCredentials = true;
            // Set the error message to the required field message
            _errorMessage = lang.allFieldValidate;
          });
        } else {
          // Reset error state if all conditions are met
          setState(() {
            _isShowInvalidCredentials = false;
            _errorMessage = '';
          });

          // ... Existing validation logic
        }
      }
    }

    Future<bool> _checkInternetConnectivity() async {
      try {
        final result = await InternetAddress.lookup('google.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        return false;
      }
    }

    void doLogin({String userName = '', String password = ''}) async {
      // print(passwordController.text);
      // return;
      if (userName.isNotEmpty && password.isNotEmpty) {
        usernameController.text = userName;
        passwordController.text = password;
      }

      if (loginFormKey.currentState!.validate()) {
        AppHelper.showLoaderDialog(context);

        // Check for internet connectivity
        bool isConnected = await _checkInternetConnectivity();

        if (!isConnected) {
          setState(() {
            _isShowInvalidCredentials = true;
            print('Error Response Code: 400');
            print('Error Response: يرجى التحقق من إتصالك بالإنترنت');
            _validateConfigFields(errorMessage: 'يرجى التحقق من إتصالك بالإنترنت');
          });
          // ignore: use_build_context_synchronously
          AppHelper.hideLoader(context);
          return; // Skip making the API call if not connected
        }

        MyServiceResponse myServiceResponse = await AppHelper.login(
          usernameController.text,
          passwordController.text,
          null,
        );

        // AppHelper.hideLoader(context);
        // return;

        if (myServiceResponse.responseCode == HttpStatusCode.badRequest) {
          setState(() {
            _isShowInvalidCredentials = true;
            print('Error Response Code: Host Error');
            print('Error Response: تعذر الوصول إلى الخادم');
            _validateConfigFields(errorMessage: 'تعذر الوصول إلى الخادم');
          });
        }
        if (myServiceResponse.responseCode != HttpStatusCode.oK) {
          await Haptics.vibrate(HapticsType.error);
          setState(() {
            _isShowInvalidCredentials = true;

            if (myServiceResponse.responseCode == HttpStatus.unauthorized) {
              _validateConfigFields(errorMessage: lang.invalidLogin);
            }
            // print('Error Response Code: ${myServiceResponse.responseCode}');
            // print('Error Response: ${myServiceResponse.resultString}');
            // printArNameFromErrorResponse(myServiceResponse.resultString);
          });
          AppHelper.hideLoader(context);
        } else {
          AppHelper.hideLoader(context);
          //  print('Success Response Code: ${myServiceResponse.responseCode}');
          // print('Success Response: ${myServiceResponse.resultString}');
          AppHelper.isDashboardFromLogin = true;

          await AppHelper.toggleScreenSecurity(!AppHelper.listOfVIPUsers.contains(usernameController.text.toLowerCase()));

          Routes.moveDashboard(context: context);
          await Haptics.vibrate(HapticsType.success);
        }
      }
    }

    Future<void> _authenticate() async {
      try {
        bool authenticate = await auth.authenticate(localizedReason: lang.registerBiometricMessage, options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true));
        //  print('Authenticated: $authenticate');

        if (authenticate) {
          doLogin(userName: AppHelper.currentUserSession.userName, password: AppHelper.currentUserSession.password);
        }
      } on PlatformException catch (e) {
        print(e);
      }
    }

    bool _validateFields(bool? isInvalidCredentials) {
      String errorMessage = '';
      if (isInvalidCredentials == true) {
        errorMessage = lang.invalidLogin;
      } else {
        if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
          errorMessage = 'All fields are mandatory.';
        }
      }
      if (errorMessage.isEmpty) return true;
      var snackBar = SnackBar(
        content: Text(errorMessage),
      );
// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }

    // void doLogin({String userName = '', String password = ''}) async {
    //   // if (widget.currentEntity.tawasolVersionNumber.isEmpty) {
    //   //   _configureAppSettings(context);
    //   //   return;
    //   // }
    //   if (userName.isNotEmpty && password.isNotEmpty) {
    //     usernameController.text = userName;
    //     passwordController.text = password;
    //   }
    //   // if (!_validateFields(false)) {
    //   //   return;
    //   // }
    //   if (loginFormKey.currentState!.validate()) {
    //     AppHelper.showLoaderDialog(context);
    //     MyServiceResponse myServiceResponse = await AppHelper.login(usernameController.text, passwordController.text, null);
    //     if (myServiceResponse.responseCode != HttpStatusCode.oK) {
    //       setState(() {
    //         _isShowInvalidCredentials = true;
    //       });
    //       // _validateFields(true);
    //       AppHelper.hideLoader(context);
    //     } else {
    //       AppHelper.hideLoader(context);
    //       // ignore: use_build_context_synchronously
    //       AppHelper.isDashboardFromLogin = true;
    //       // ignore: use_build_context_synchronously
    //       Routes.moveDashboard(
    //         context,
    //         // () {},
    //       );
    //     }
    //   }
    // }
    // void doLogin({String userName = '', String password = ''}) async {
    //   if (userName.isNotEmpty && password.isNotEmpty) {
    //     usernameController.text = userName;
    //     passwordController.text = password;
    //   }
    //   if (loginFormKey.currentState!.validate()) {
    //     AppHelper.showLoaderDialog(context);
    //     MyServiceResponse myServiceResponse = await AppHelper.login(usernameController.text, passwordController.text, null);
    //     if (myServiceResponse.responseCode != HttpStatusCode.oK) {
    //       setState(() {
    //         _isShowInvalidCredentials = true;
    //         print(myServiceResponse.resultString);
    //       });
    //       AppHelper.hideLoader(context);
    //     } else {
    //       AppHelper.hideLoader(context);
    //       print(myServiceResponse.responseCode);
    //       print(myServiceResponse.resultString);
    //       AppHelper.isDashboardFromLogin = true;
    //       Routes.moveDashboard(context);
    //     }
    //   }
    // }

    void printArNameFromErrorResponse(String resultString) {
      try {
        Map<String, dynamic> jsonResponse = json.decode(resultString);

        if (jsonResponse.containsKey("eo")) {
          Map<String, dynamic> eoMap = jsonResponse["eo"];
          String arName = eoMap["arName"] ?? "";
          print('Arabic Name from "eo": $arName');

          // Show SnackBar to the user with the error message
          _validateConfigFields(errorMessage: arName);
        } else {
          print('No "eo" field found in the response.');
          //delay one seconed and
        }
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    }

// void printArNameFromErrorResponse(String resultString) async {
//   try {
//     Map<String, dynamic> jsonResponse = json.decode(resultString);
//     if (jsonResponse.containsKey("eo")) {
//       Map<String, dynamic> eoMap = jsonResponse["eo"];
//       String arName = eoMap["arName"] ?? "";
//       print('Arabic Name from "eo": $arName');
//       // Show SnackBar to the user with the error message
//       _validateConfigFields(errorMessage: arName);
//     } else {
//       print('No "eo" field found in the response.');
//       // Delay for one second
//       await Future.delayed(Duration(seconds: 1));
//       // Hit the server again or perform any other action
//       // Example: await _hitServerAgain();
//     }
//   } catch (e) {
//     print('Error decoding JSON: $e');
//   }
// }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          body: Form(
            key: loginFormKey,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: GestureDetector(
                onLongPress: () {
                  setState(() {
                    _isLanguageVisible = !_isLanguageVisible;
                  });
                },
                child: Container(
                  height: MediaQuery.of(context).size.longestSide,
                  width: MediaQuery.of(context).size.shortestSide + 400,
                  // color: Color(0XFF0a4c63),
                  color: const Color(0XFF1c4b6d),
                  // decoration: const BoxDecoration(
                  //   image: DecorationImage(
                  //     image: AssetImage('assets/images/moi_bg_new.png'),
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                  // margin: EdgeInsetsDirectional.only(top: AppHelper.isMobileDevice(context) ? 50 : 120),
                  padding: EdgeInsets.only(left: 35, top: AppHelper.isMobileDevice(context) ? 50 : 30, right: 35, bottom: 20),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 60,
                      ),
                      //  if (widget.currentEntity.entityCode.isEmpty)
                      Image.asset(
                        'assets/images/loginPageLogo.png',
                        height: AppHelper.isMobileDevice(context) ? 180 : 270,
                        width: 230,
                      ),
                      // if (widget.currentEntity.entityCode.isNotEmpty)
                      //   Image.memory(
                      //     widget.currentEntity.logo,
                      //     height: 200,
                      //     width: 200,
                      //   ),
                      SizedBox(
                        height: AppHelper.isMobileDevice(context) ? 30 : 100,
                      ),
                      // if (_isShowInvalidCredentials)
                      Visibility(
                        visible: _isShowInvalidCredentials,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: Colors.red,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                child: Container(
                                  alignment: Alignment.center,
                                  width: AppHelper.isMobileDevice(context) ? 310 : 455,
                                  height: 50.0,
                                  child: Text(
                                    _errorMessage,
                                    // lang.invalidLogin,
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Text(
                      //   lang.appName,
                      //   style: TextStyle(
                      //       color: Colors.white,
                      //       fontWeight: FontWeight.w700,
                      //       fontSize:
                      //       AppHelper.isMobileDevice(context) ? 18.0 : 24.0),
                      // ),
                      const SizedBox(height: 15),
                      MyTextField(
                        labelText: lang.username,
                        ctrl: usernameController,
                        onSubmit: doLogin,
                        prefixIconData: Icons.person_2_outlined,
                        textFieldWidth: 475,
                        isDense: false,
                        isLoginPage: true,
                      ),
                      const SizedBox(height: 20),
                      MyTextField(
                        labelText: lang.password,
                        textFieldWidth: 475,
                        isLoginPage: true,
                        onSubmit: doLogin,
                        prefixIconData: Icons.lock_outlined,
                        isDense: false,
                        ctrl: passwordController,
                        // textAlign: TextAlign.right,
                        isPasswordType: !isPasswordShow,
                        onPasswordShow: () {
                          setState(() {
                            isPasswordShow = !isPasswordShow;
                          });
                        },
                      ),
                      const SizedBox(height: 25),
                      //  if(!AppHelper.isMobileDevice(context))
                      MyButton(
                          btnText: lang.login,
                          horizontalPadding: 24,
                          verticalPadding: 16,
                          isLoginButton: true,
                          borderColor: AppHelper.myColor('#243056'),
                          backgroundColor: Colors.white,
                          // Colors.white,
                          textColor: AppHelper.myColor("#243056"),
                          //AppHelper.myColor("#243056"),
                          onTap: () {
                            doLogin();
                          }),
                      const SizedBox(
                        height: 30,
                      ),
                      if (_supportState && AppHelper.currentUserSession.isBiometricEnabled && listOfAuthentications.isNotEmpty && listOfAuthentications.contains(BiometricType.face))
                        IconButton(
                          onPressed: _authenticate,
                          icon: SvgPicture.asset('assets/images/face_id.svg',
                              height: AppHelper.isMobileDevice(context) ? 60 : 80,
                              width: AppHelper.isMobileDevice(context) ? 60 : 80,
                              theme: SvgTheme(
                                currentColor: Colors.white,
                                fontSize: AppHelper.isMobileDevice(context) ? 80 : 80,
                              )),
                        ),
                      if (_supportState && AppHelper.currentUserSession.isBiometricEnabled && listOfAuthentications.isNotEmpty && (listOfAuthentications.contains(BiometricType.strong) || listOfAuthentications.contains(BiometricType.fingerprint)))
                        IconButton(
                          onPressed: _authenticate,
                          icon: Icon(
                            Icons.fingerprint_outlined,
                            size: AppHelper.isMobileDevice(context) ? 60 : 80,
                            color: Colors.white,
                          ),
                        ),
                      const Spacer(),
                      Expanded(
                        child: Consumer<VersionProvider>(
                          builder: (context, versionProvider, child) {
                            return versionProvider.version.isNotEmpty
                                ? Text(
                                    '${lang.version} ${versionProvider.version}',
                                    style: TextStyle(color: Colors.white),
                                  )
                                : Text(
                                    '${lang.version} -',
                                    style: TextStyle(color: Colors.white),
                                  );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLanguageVisible)
                            IconButton.filled(
                                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(AppHelper.myColor('#0b6192'))),
                                onPressed: () {
                                  AppHelper.changeLocalization(context);
                                  setState(() {
                                    setInitialData().then((data) => setState(() {
                                          widget.currentEntity = data[0];
                                          widget.currentUserSession = data[1];
                                        }));
                                  });
                                },
                                icon: Icon(
                                  Icons.g_translate_outlined,
                                  size: AppHelper.isMobileDevice(context) ? 35 : 45,
                                  color: Colors.white,
                                )),
                          if (_isLanguageVisible) const SizedBox(width: 15),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
