/*
 * Author     : Berenisse Oldright
 * Website    :
 * Repository : https://github.com/oldbright22
 * 
 * Created on JUL 14 2024
 * Copyright (c) 2024 Berenisse Oldright
 */

import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:logging/logging.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'data/data.dart';
import 'injection.dart';
import 'config/config.dart';
import 'core/core.dart';
import 'observer.dart';

Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
  CallKitHandler.showCallkitIncoming(message);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  CallKitHandler.showCallkitIncoming(message);
}

/// We need to initialize app before start to the main page
///
/// This initialize include
/// * Initialize Firebase
/// * Initialize Splash screen
/// * Initialize screen orientation
Future<void> initializeApp() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  /// https://github.com/flutter/flutter/issues/112498
  /// Paint.enableDithering = true;

  // Load Env file
  //
  // Some third-party are dependent on the env file,
  // so we need to load the env before initializing third party
  late String envFileName;
  switch (Environtment.current) {
    case EnvirontmentType.development:
      envFileName = ".env.development";
      break;
    case EnvirontmentType.staging:
      envFileName = ".env.staging";
      break;
    default:
      envFileName = ".env.production";
      break;
  }
  await dotenv.load(fileName: envFileName);

  await Firebase.initializeApp();
  await setupInjection();

  // Initialize all asynchronous methods which possible to initialize at the
  // same time to speed up the initialization process
  await Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    OneSignal.shared.setAppId(Environtment.onesignalAppID),
    EasyLocalization.ensureInitialized(),
    _Logging.initialize(showLog: Environtment.isDevelopment()),
  ]);

  FirebaseMessaging.instance.getToken().then((_) {
    // We need start listen after token ready to use to avoid not executing
    // foreground & background handler
    FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  });

  CallKitHandler.initialize();
  OnesignalHandler.initialize();
  AssistantHandler.initialize();
  SiriHandler.initialize();
  Bloc.observer = AppBlocObserver();
}

class App extends StatefulWidget {
  const App({required this.title, super.key});
  final String title;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final AuthRepository authRepository = sl<AuthRepository>();
  final OnesignalRepository onesignalRepository = sl<OnesignalRepository>();
  final CallKit callKit = sl<CallKit>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    FlutterNativeSplash.remove();

    // We need to update the language to make sure the current onesignal
    // language are same as the last selected language
    onesignalRepository.updateLanguage();

    // We need to syncronize OneSignal Tags to make sure the tags auth status
    // are same with current auth status
    authRepository.syncOneSignalTags();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: widget.title,
      builder: (context, child) => ResponsiveWrapper.builder(
        BouncingScrollWrapper(child: child ?? const SizedBox()),
        minWidth: 450,
        defaultScale: true,
        breakpoints: [
          const ResponsiveBreakpoint.resize(480, name: MOBILE),
          const ResponsiveBreakpoint.autoScale(768, name: TABLET),
        ],
      ),

      /* LOCALE SETUP */
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      /* THEMING SETUP */
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      /* ROUTER SETUP */
      routerDelegate: AppRoutes.router.routerDelegate,
      routeInformationParser: AppRoutes.router.routeInformationParser,
      routeInformationProvider: AppRoutes.router.routeInformationProvider,
    );
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();

    if (context.mounted) {
      sl<AppSystemOverlay>().setSystemUIOverlayStyle();
    }
  }

  @override
  void dispose() {
    super.dispose();

    callKit.endAllCalls();
    authRepository.dispose();
    onesignalRepository.dispose();
  }
}

abstract class _Logging {
  static bool isInitialize = false;

  static Future<void> initialize({bool showLog = false}) async {
    if (!_Logging.isInitialize) {
      if (showLog) {
        await OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
      } else {
        EasyLocalization.logger.enableLevels = [];
      }

      Logger.root.level = showLog ? Level.ALL : Level.OFF;

      Logger.root.onRecord.listen((record) {
        final level = record.level;
        final name = record.loggerName;
        final message = record.message;
        final strackTrace = record.stackTrace;
        final error = record.error;

        if (level == Level.FINE ||
            level == Level.FINER ||
            level == Level.FINEST) {
          log('✅ ${level.name} "$name" : $message');
        } else if (level == Level.SEVERE ||
            level == Level.SHOUT ||
            level == Level.WARNING) {
          log('⛔ ${level.name} "$name" : $message${error != null ? '\nError : $error' : ''}${strackTrace != null ? '\n$strackTrace' : ''}');
        } else if (level == Level.INFO || level == Level.CONFIG) {
          log('ℹ️ ${level.name} "$name" : $message');
        }
      });

      _Logging.isInitialize = true;
    }
  }
}
