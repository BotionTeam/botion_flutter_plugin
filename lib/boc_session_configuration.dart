import 'dart:ui';

import 'boc_enum.dart';

class BOCSessionConfiguration {
  // The path of static resources, which is empty by default.
  String? resourcePath;

  // Protocol for remote access to static resources, default is @ “https”
  String? protocol;

  // User interface and statusBar style, which is light by default
  BOCUserInterfaceStyle? userInterfaceStyle;

  // Defines color for captcha background. Default is transparent
  Color? backgroundColor;

  // Determines whether the debug information is shown on background, which is disable by default
  bool? debugEnable;

  // Log switch, only effective for Android
  bool? logEnable;

  // Determines whether the background is able to interact,
  // which is able by default.
  bool? canceledOnTouchOutside;

  // The timeout of each request. Default is 8000ms for iOS，10000ms for Android
  int? timeout;

  /*
  Defines Language for captcha, which is same as system language by default.
  Display in English, if not supported.
  Please refer to the language short code(ISO 639-2 standard) for setting the language.
  */
  String? language;

  // Static service address, empty by default
  List<String>? staticServers;

  // Interface service address, default is empty
  List<String>? apiServers;

  // Additional parameter, which is empty by default.
  // Parameters will be assembled and submitted to the captcha server.
  Map<String, dynamic>? additionalParameter;

  Map<String, dynamic> toMap() {
    return {
      "resourcePath": resourcePath,
      "protocol": protocol,
      "userInterfaceStyle": userInterfaceStyle?.index,
      "backgroundColor": backgroundColor?.value.toRadixString(16),
      "debugEnable": debugEnable,
      "logEnable": logEnable,
      "canceledOnTouchOutside": canceledOnTouchOutside,
      "timeout": timeout,
      "language": language,
      "additionalParameter": additionalParameter,
      "staticServers": staticServers,
      "apiServers": apiServers
    }..removeWhere((key, value) => value == null);
  }
}
