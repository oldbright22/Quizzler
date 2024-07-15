/*
 * Author     : Mochamad Firgia
 * Website    : https://www.firgia.com
 * Repository : https://github.com/firgia/soca
 * 
 * Created on Thu Feb 02 2023
 * Copyright (c) 2023 Mochamad Firgia
 */

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../core/core.dart';
import '../../injection.dart';

abstract class DeviceProvider {
  /// Get device ID
  ///
  /// The device id is only generated once, so each device has a unique ID.
  Future<String> getDeviceID();

  /// Get onesignal Player ID
  Future<String?> getOnesignalPlayerID();

  /// {@macro get_device_push_token_voip}
  Future<String?> getVoIP();

  /// Get current device platform
  DevicePlatform? getPlatform();
}

class DeviceProviderImpl implements DeviceProvider {
  String get deviceIDKey => "device_id_key";

  final DeviceInfo _deviceInfo = sl<DeviceInfo>();
  final FlutterSecureStorage _secureStorage = sl<FlutterSecureStorage>();
  final OneSignal _oneSignal = sl<OneSignal>();
  final Logger _logger = Logger("Device Provider");

  @override
  Future<String> getDeviceID() async {
    _logger.info("Getting device ID...");
    final deviceID = await _secureStorage.read(key: deviceIDKey);
    _logger.info("Successfully to get device ID");
    // Applied fix due dart analyze issue - Jul14
    return deviceID == null ? "" : deviceID;
    }

  @override
  Future<String?> getOnesignalPlayerID() async {
    _logger.info("Getting onesignal player ID...");
    final deviceState = await _oneSignal.getDeviceState();
    final playerID = deviceState?.userId;
    _logger.info("Successfully to get onesignal player ID");

    return playerID;
  }

  @override
  Future<String?> getVoIP() async {
    return _deviceInfo.getDevicePushTokenVoIP();
  }

  @override
  DevicePlatform? getPlatform() {
    return _deviceInfo.platform;
  }
}
