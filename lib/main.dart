// ignore_for_file: library_private_types_in_public_api
import 'dart:async';
import 'dart:io';

// import 'package:connectivity/connectivity.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:provider/provider.dart';
// import 'package:screen_protector/screen_protector.dart';
import 'package:tawasol/app_models/app_utilities/cache_manager.dart';
import 'package:tawasol/app_models/service_models/service_handler.dart';
import 'package:tawasol/app_models/service_models/service_urls.dart';
import 'package:tawasol/app_models/versionProvider.dart';
import 'package:tawasol/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:tawasol/main_page/dashboard.dart';
// import 'package:tawasol/theme/theme_data.dart';
import 'package:tawasol/theme/theme_provider.dart';
import './app_models/app_utilities/app_helper.dart';
import 'landing_page/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'main_page/search2.dart';
// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:dynatrace_flutter_plugin/dynatrace_flutter_plugin.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  // // // use client that contain certificate
  //  AppHelper.httpClient = await AppHelper.getSSLPinningClient();
  // await Future.delayed(const Duration(seconds: 2));

  final strg = FlutterSecureStorage();

  AppHelper.currentUserSession = await CacheManager.getUserSessionLocally(AppCacheKeys.userSessionFileName);

  var adaptSystemTheme = await strg.read(key: 'adaptSystemTheme');
  if (adaptSystemTheme != null) ThemeProvider.setAdaptSystemTheme(adaptSystemTheme);

  var isDarkMode = await strg.read(key: 'isDarkMode');
  if (isDarkMode != null) ThemeProvider.setIsDarkMode(isDarkMode);

  var savedClr = await strg.read(key: 'savedClr');
  if (savedClr != null) ThemeProvider.setPrimaryColor(savedClr);

  // most communicated feature starts below:

  var mostUsedActions = await strg.read(key: 'mostUsedActions');
  if (mostUsedActions != null) AppHelper.processStoredRecentActions(mostUsedActions);

  var recentlyUsedUsers = await strg.read(key: 'recentlyUsedUsers');
  if (recentlyUsedUsers != null) AppHelper.processStoredRecentUsers(recentlyUsedUsers);

  // Connectivity().checkConnectivity(); // Initialize the connectivity package

  // Dynatrace().startWithoutWidget(configuration: Configuration(logLevel: LogLevel.Debug));
  // Dynatrace().start(MyApp());
  //
  // Dynatrace().setDataCollectionLevel(DataCollectionLevel.User);
  // Dynatrace().setCrashReportingOptedIn(true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => VersionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  bool? _jailBroken;
  bool? _developerMode;

  Future<void> initPlatformState() async {
    bool jailBroken;
    bool developerMode;
    // Platform messages may fail, so we use a try/catch PlatformException.
    //
    AppHelper.currentUserSession = await CacheManager.getUserSessionLocally(AppCacheKeys.userSessionFileName);

    try {
      jailBroken = await FlutterJailbreakDetection.jailbroken;
      developerMode = await FlutterJailbreakDetection.developerMode;
    } on PlatformException {
      jailBroken = true;
      developerMode = true;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _jailBroken = jailBroken;
      _developerMode = developerMode;
    });
  }

  Locale _locale = const Locale('ar');

  final _navigatorKey = GlobalKey<NavigatorState>();

  Timer? _timer;

  @override
  void initState() {
    initPlatformState();

    // _protectDataLeakageOn();
    // ScreenProtector.preventScreenshotOn();
    _startTimer();
    super.initState();
  }

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer(const Duration(minutes: 30), () {
      _timer?.cancel();
      _timer = null;

      _navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (routeContext) => Login()));
    });
  }

  void _handleInteraction([_]) {
    _startTimer();
  }

  // _MyAppState() {
  //   setSelectedLanguage().then((selectedLocale) => setState(() {
  //         _locale = selectedLocale;
  //       }));
  // }
  //
  // Future<Locale> setSelectedLanguage() async {
  //   // widget.currentUserSession = await AppHelper.getCurrentUserSession;
  //   return (await CacheManager.getGlobalSelectedLanguage()) == 'en'
  //       ? L10n.all.elementAt(0)
  //       : L10n.all.elementAt(1);
  // }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
      CacheManager.globalCache(_locale.languageCode);
    });
  }

  // void _protectDataLeakageOn() async {
  //   if (Platform.isIOS) {
  //     await ScreenProtector.protectDataLeakageWithColor(Colors.black);
  //     //  await ScreenProtector.preventScreenshotOn();
  //   } else if (Platform.isAndroid) {
  //     await ScreenProtector.protectDataLeakageOn();
  //   }
  // }

  @override
  void dispose() async {
    // await ScreenProtector.protectDataLeakageOff();
    // TODO: implement dispose
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    context.read<VersionProvider>().loadVersionInfo();
    // ValueNotifier<ThemeClass> notifier = ValueNotifier(ThemeMode.light as ThemeClass);
    // if ((Platform.isIOS && _jailBroken == true) || (Platform.isAndroid && _developerMode == true)) {
    //   exit(0);
    // }
    // return Listener(
    //   behavior: HitTestBehavior.translucent,
    //   onPointerMove: _handleInteraction,
    //   child: MaterialApp(
    //     title: 'Tawasol',
    //     debugShowCheckedModeBanner: false,
    //     localizationsDelegates: AppLocalizations.localizationsDelegates,
    //     supportedLocales: L10n.all,
    //     locale: _locale,
    //     // themeMode: ThemeMode.system,
    //     navigatorKey: _navigatorKey,
    //     themeMode: ThemeMode.system,
    //     theme: Provider.of<ThemeProvider>(context).themeData, // applies this theme if the device theme is light mode
    //     // theme: ThemeData(
    //     //   primaryColor: ThemeData.light().scaffoldBackgroundColor,
    //     //   colorScheme: const ColorScheme.light().copyWith(
    //     //     primary: ThemeClass.primaryColor,
    //     //     background: Colors.white,
    //     //     // secondary: _themeClass.secondaryColor,
    //     //   ),
    //     // ),
    //     // darkTheme: ThemeClass.darkTheme, // applies this theme if the device theme is dark mode
    //     // theme: ThemeData(
    //     //   //fontFamily: 'Arial',
    //     //   //fontFamily: 'AlMajd',
    //     //   // fontFamily: _locale.languageCode == 'ar' ? 'Lusail Medium' : null,
    //     //   // textTheme: GoogleFonts.openSansTextTheme(
    //     //   //   Theme.of(context).textTheme,
    //     //   // ),
    //     //   colorScheme: ColorScheme.fromSeed(
    //     //     seedColor: AppHelper.myColor('#0c4160'),
    //     //     primary: AppHelper.myColor('#0c4160'),
    //     //     //      primary: const Color(0xFF151026)
    //     //   ),
    //     //   useMaterial3: true,
    //     // ),
    //     home: Login(),
    //   ),
    // );

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: _handleInteraction,
      child: Consumer<ThemeProvider>(
        builder: (context, clrr, _) {
          return MaterialApp(
            title: 'Tawasol',
            // title: "مراسلات",
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: L10n.all,
            locale: _locale,
            navigatorKey: _navigatorKey,
            // themeMode: ThemeMode.system,
            themeMode: Provider.of<ThemeProvider>(context).getThemeMode(),
            // theme: Provider.of<ThemeProvider>(context).themeData, // applies this theme if the device theme is light mode
            theme: ThemeData(
              primaryColor: ThemeData.light().scaffoldBackgroundColor,
              // fontFamily: _locale.languageCode == 'ar' ? 'AlMajd' : null,
              fontFamily: _locale.languageCode == 'ar' ? 'NotoNaskhArabic' : null,
              colorScheme: const ColorScheme.light().copyWith(
                primary: ThemeProvider.primaryColor,
                background: Colors.white,
                // secondary: _themeClass.secondaryColor,
              ),
            ),
            darkTheme: ThemeData(
              primaryColor: ThemeData.dark().scaffoldBackgroundColor,
              // fontFamily: _locale.languageCode == 'ar' ? 'AlMajd' : null,
              fontFamily: _locale.languageCode == 'ar' ? 'NotoNaskhArabic' : null,
              colorScheme: const ColorScheme.dark().copyWith(
                primary: ThemeProvider.primaryColor,
                background: const Color.fromARGB(225, 0, 0, 0),
              ),
            ),
            home: FlutterSplashScreen.gif(
              gifPath: 'assets/images/lunchScreen.gif',
              // gifPath: 'assets/images/launchScreenPMO2.gif',
              gifWidth: double.infinity,
              gifHeight: 1200,
              nextScreen: Login(),
              // nextScreen: Search2(),
              backgroundColor: const Color(0xFF0E4B6E),
              // duration: const Duration(milliseconds: 4515),
              duration: const Duration(milliseconds: 4000),
              // duration: const Duration(milliseconds: 5600),
              onInit: () async {
                await ServiceHandler.getPreLoginInfo(AppDefaultKeys.tawasolEntityCode, AppServiceURLS.baseUrl);
              },
              onEnd: () async {
                debugPrint("onEnd 1");
              },
            ),
            // home: Login(),
          );
        },
      ),
    );
  }
}
// AppHelper.myColor('#3b5998')
