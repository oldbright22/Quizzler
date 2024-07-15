/*
 * Author     : Mochamad Firgia
 * Website    : https://www.firgia.com
 * Repository : https://github.com/firgia/soca
 * 
 * Created on Wed Jan 25 2023
 * Copyright (c) 2023 Mochamad Firgia
 */

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import '/injection.dart';
import 'package:quizzler/core/enum/environtment_type.dart';

/// This Environment is used for use Third Party Service
abstract class Environtment {
  static final Logger _log = Logger("Environtment");

  static EnvirontmentType _current = EnvirontmentType.development;

  /// OneSignal is a free push notification service for mobile apps.
  /// This plugin makes it easy to integrate your native Android or Amazon app with OneSignal.
  /// https://dashboard.onesignal.com/apps/e2660be3-0a2a-4b0e-acec-e1666f83d0c5
  /// Must configure at least one platform to start sending messages
  /// https://documentation.onesignal.com/docs/android-firebase-credentials
  /// https://docs.tctech.in/index.php/docs/generate-agora-app-id-primary-certificate/

  /// Return OneSignal App ID to access OneSignal
  static String get onesignalAppID {
    String result = sl<DotEnv>().env["ONESIGNAL_APP_ID"] ?? "";
    if (result.isEmpty) {
      _log.shout("Value of ONESIGNAL_APP_ID is not available on .env");
    }
    return result;
  }

  /// Return Agora App ID to access Agora
  static String get agoraAppID {
    String result = sl<DotEnv>().env["AGORA_APP_ID"] ?? "";
    if (result.isEmpty) {
      _log.shout("Value of AGORA_APP_ID is not available on .env");
    }
    return result;
  }

  /// Return current environtment used
  ///
  /// The default environtment is [EnvirontmentType.development]
  static EnvirontmentType get current => _current;

  /// Set the current environtment
  ///
  /// Please set the environtment on the `main` before the app is loaded
  ///
  /// The default of current environtment is [EnvirontmentType.development]
  static setCurrentEnvirontment(EnvirontmentType type) {
    _log.info("Set environtment to ${type.name}");
    _current = type;
  }

  /// Return true if current environtment is for `Production`
  static bool isProduction() => _current == EnvirontmentType.production;

  /// Return true if current environtment is for `Development`
  static bool isDevelopment() => _current == EnvirontmentType.development;

  /// Return true if current environtment is for `Staging`
  static bool isStaging() => _current == EnvirontmentType.staging;
}
