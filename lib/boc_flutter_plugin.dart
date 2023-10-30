import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:botion_flutter_plugin/boc_session_configuration.dart';

typedef EventHandler = Function(Map<String, dynamic> event);

class BocFlutterPlugin {
  static const String flutterLog = "| Botion | Flutter | ";
  static const MethodChannel _channel = MethodChannel('botion_flutter_plugin');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  EventHandler? _onShow;
  EventHandler? _onResult;
  EventHandler? _onError;

  BocFlutterPlugin(String captchaId, [BOCSessionConfiguration? config]) {
    try {
      _channel.invokeMethod(
          'initWithCaptcha',
          {'captchaId': captchaId, 'config': config?.toMap()}
            ..removeWhere((key, value) => value == null));
    } catch (e) {
      debugPrint(flutterLog + e.toString());
    }
  }

  /// Start verification
  void verify() {
    try {
      _channel.invokeMethod('verify');
    } catch (e) {
      debugPrint(flutterLog + e.toString());
    }
  }

  /// Cancel verification
  void close() {
    try {
      _channel.invokeMethod('close');
    } catch (e) {
      debugPrint(flutterLog + e.toString());
    }
  }

  void configurationChanged(Object object) {
    try {
      _channel.invokeMethod('configurationChanged', {'newConfig': object});
    } catch (e) {
      debugPrint(flutterLog + e.toString());
    }
  }

  ///
  /// Register event callback
  ///
  void addEventHandler({
    /// Verification completed, may succeed or fail
    /// Success Structure Example:
    /// {response: {"lot_number":"5df5c616d4aa49aa82d44aceb6c76264",
    /// "pass_token":"282282c00077c1cc11d8b4b29e361fcfb3421916220ed9bf253803711b98f1ef",
    /// "gen_time":"1636015810","captcha_output":"1X_RK3ag_IKlW15iHhSywQ=="}, state: true}
    /// Failure structure example:
    /// {response: {"captchaId":"647f5ed2ed8acb4be36784e01556bb71","captchaType":"slide",
    /// "challenge":"d04423f3-5297-44f5-bafa-cb868095c605"}, state: false}
    EventHandler? onResult,

    /// Error callback
    /// Structure example：{msg: Captcha session canceled, code: -14460, desc: {"description":"User cancelled 'Captcha'"}}
    /// Error codes need to be handled differently according to the terminal type.
    /// Android: https://docs.botion.com/boc/apirefer/errorcode/android
    /// iOS: https://docs.botion.com/boc/apirefer/errorcode/ios
    EventHandler? onError,

    ///
    ///
    ///
    EventHandler? onShow,
  }) {
    debugPrint("${flutterLog}addEventHandler");

    _onShow = onShow;
    _onResult = onResult;
    _onError = onError;
    _channel.setMethodCallHandler(_handler);
  }

  /// Native callback
  Future<dynamic> _handler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case "onShow":
        debugPrint("${flutterLog}onShow:$_onShow");
        return _onShow!(methodCall.arguments.cast<String, dynamic>());
      case "onResult":
        debugPrint("${flutterLog}onResult:$_onResult");
        return _onResult!(methodCall.arguments.cast<String, dynamic>());
      case "onError":
        debugPrint("${flutterLog}onError:$_onError");
        return _onError!(methodCall.arguments.cast<String, dynamic>());
      default:
        throw UnsupportedError("${flutterLog}Unrecognized Event");
    }
  }
}
