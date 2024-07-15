import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'config/config.dart';
import 'core/core.dart';


/*
 * easy_localization package in Dart (specifically for Flutter) is used
 * to simplify the localization and internationalization of a Flutter
 * application. Localization refers to adapting your app to different
 * languages and regions, which is essential for reaching a global
 * audience.
 * Step 3: Initialize EasyLocalization
 * Wrap your MaterialApp with EasyLocalization and provide the
 * supported locales and path to the translation files:
 */


Future<void> main() async {
  Environtment.setCurrentEnvirontment(EnvirontmentType.development);
  await initializeApp();

  runApp(
    EasyLocalization(
      path: AppTranslations.path,
      supportedLocales: AppTranslations.supportedLocales,
      fallbackLocale: AppTranslations.fallbackLocale,
      useFallbackTranslations: true,
      useOnlyLangCode: true,
      child: const App(title: "OnDemand StudyCoach - Development"),
    ),
  );
}
