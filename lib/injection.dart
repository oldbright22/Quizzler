/*
 * Author     : Berenisse Oldright
 * Website    :
 * Repository : https://github.com/oldbright22
 * 
 * Created on Sun Jul 14 2024
 * Copyright (c) 2024 Berenisse Oldright
 */

import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart' as agora;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/config.dart';
import 'core/core.dart';
import 'data/data.dart';
import 'logic/logic.dart';

/// Service locator
final sl = GetIt.instance;

Future<void> setupInjection() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  /* ---------------------------------> CORE <------------------------------- */
  sl.registerLazySingleton<CallKit>(() => CallKit());
  sl.registerLazySingleton<DeviceFeedback>(() => DeviceFeedbackImpl());
  sl.registerLazySingleton<DeviceInfo>(() => DeviceInfoImpl());
  sl.registerLazySingleton<DeviceSettings>(() => DeviceSettingsImpl());

  /* --------------------------------> CONFIG <------------------------------ */
  sl.registerLazySingleton<AppNavigator>(() => AppNavigator());
  sl.registerLazySingleton<AppSystemOverlay>(() => AppSystemOverlayImpl());

  /* ---------------------------------> DATA <------------------------------- */
  sl.registerLazySingleton<AppProvider>(() => AppProviderImpl());
  sl.registerLazySingleton<AuthoProvider>(() => AuthoProviderImpl());
  sl.registerLazySingleton<CallingProvider>(() => CallingProviderImpl());
  sl.registerLazySingleton<DatabaseProvider>(() => DatabaseProviderImpl());
  sl.registerLazySingleton<DeviceProvider>(() => DeviceProviderImpl());
  sl.registerLazySingleton<FunctionsProvider>(() => FunctionsProviderImpl());
  sl.registerLazySingleton<LocalLanguageProvider>(
      () => LocalLanguageProviderImpl());
  sl.registerLazySingleton<OneSignalProvider>(() => OneSignalProviderImpl());
  sl.registerLazySingleton<SettingsProvider>(() => SettingsProviderImpl());
  sl.registerLazySingleton<UserProvider>(() => UserProviderImpl());
  sl.registerLazySingleton<AppRepository>(() => AppRepositoryImpl());
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  sl.registerLazySingleton<CallingRepository>(() => CallingRepositoryImpl());
  sl.registerLazySingleton<FileRepository>(() => FileRepositoryImpl());
  sl.registerLazySingleton<LanguageRepository>(() => LanguageRepositoryImpl());
  sl.registerLazySingleton<OnesignalRepository>(
      () => OnesignalRepositoryImpl());
  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl());
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());

  /* -----------------------------> DEPENDENCIES <--------------------------- */
  sl.registerFactory<Completer>(() => Completer());
  sl.registerFactory<DefaultCacheManager>(() => DefaultCacheManager());
  sl.registerSingleton<DotEnv>(dotenv);
  sl.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ));
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<FirebaseDatabase>(FirebaseDatabase.instance);
  sl.registerSingleton<FirebaseFunctions>(FirebaseFunctions.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  sl.registerSingleton<GoogleSignIn>(GoogleSignIn());
  sl.registerSingleton<ImageCropper>(ImageCropper());
  sl.registerSingleton<ImagePicker>(ImagePicker());
  sl.registerSingleton<InternetConnectionChecker>(
    InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 5),
      checkInterval: const Duration(seconds: 5),
    ),
  );
  sl.registerSingleton<OneSignal>(OneSignal.shared);
  sl.registerFactory<agora.RtcEngine>(() => agora.createAgoraRtcEngine());
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
  sl.registerSingleton<WidgetsBinding>(WidgetsBinding.instance);

  /* --------------------------------> LOGIC <------------------------------- */
  if (!sl.isRegistered<AssistantCommandBloc>()) {
    sl.registerSingleton<AssistantCommandBloc>(AssistantCommandBloc());
  }
  sl.registerFactory<CallActionBloc>(() => CallActionBloc());
  sl.registerFactory<CallHistoryBloc>(() => CallHistoryBloc());
  sl.registerFactory<CallStatisticBloc>(() => CallStatisticBloc());
  sl.registerFactory<FileBloc>(() => FileBloc());
  sl.registerSingleton<IncomingCallBloc>(IncomingCallBloc());
  sl.registerFactory<LanguageBloc>(() => LanguageBloc());
  sl.registerFactory<SignInBloc>(() => SignInBloc());
  sl.registerFactory<SignUpFormBloc>(() => SignUpFormBloc());
  sl.registerFactory<SignUpBloc>(() => SignUpBloc());
  sl.registerFactory<UserBloc>(() => UserBloc());
  sl.registerFactory<VideoCallBloc>(() => VideoCallBloc());
  sl.registerFactory<AccountCubit>(() => AccountCubit());
  sl.registerFactory<RouteCubit>(() => RouteCubit());
  sl.registerFactory<SettingsCubit>(() => SettingsCubit());
  sl.registerFactory<SignOutCubit>(() => SignOutCubit());
}
