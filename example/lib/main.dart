import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:botion_flutter_plugin/boc_flutter_plugin.dart';
import 'package:botion_flutter_plugin/boc_session_configuration.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  /// Monitor page configuration changes
  static const MethodChannel _demoChannel = MethodChannel('boc_flutter_demo');

  /// TO-DO
  /// Before initial new instance, replace `captchaId` sample with one of the captchaId registered from account backend.
  late final BocFlutterPlugin captcha;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    BOCSessionConfiguration config = BOCSessionConfiguration();
    config.logEnable = false;
    captcha = BocFlutterPlugin("123456789012345678901234567890ab", config);

    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await BocFlutterPlugin.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    try {
      _demoChannel.setMethodCallHandler(_configurationChanged);

      captcha.addEventHandler(onShow: (Map<String, dynamic> message) async {
        // TO-DO
        // Verification view is shown
        debugPrint("Captcha did show");
      }, onResult: (Map<String, dynamic> message) async {
        debugPrint("Captcha result: $message");
        Fluttertoast.showToast(
          msg: message.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        String status = message["status"];
        if (status == "1") {
          // TODO
          // Send the data in message["result"] to the server secondary query interface to query the results
          Map result = message["result"] as Map;
          await validateCaptchaResult(result
              .map((key, value) => MapEntry(key.toString(), value.toString())));
        } else {
          // End user completed verification error, automatically refreshed
          debugPrint("Captcha 'onResult' state: $status");
        }
      }, onError: (Map<String, dynamic> message) async {
        debugPrint("Captcha onError: $message");
        Fluttertoast.showToast(
          msg: message.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        String code = message["code"];
        // TODO Handling errors returned in validation
        if (Platform.isAndroid) {
          // Android platform
          if (code == "-14460") {
            // Captcha session canceled
          } else {
            // For more error codes, please refer to the development documentation.
            // https://docs.botion.com/boc/apirefer/errorcode/android
          }
        }

        if (Platform.isIOS) {
          // iOS platform
          if (code == "-20201") {
            // Verification request timed out
          } else if (code == "-20200") {
            // Captcha session canceled
          } else {
            // For more error codes, please refer to the development documentation.
            // https://docs.botion.com/boc/apirefer/errorcode/ios
          }
        }
      });
    } catch (e) {
      debugPrint("Event handler exception $e");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void verify() {
    debugPrint("Start captcha. Current version: $_platformVersion");
    captcha.verify();
  }

  void close() {
    debugPrint("Close captcha.");
    captcha.close();
  }

  Future<dynamic> _configurationChanged(MethodCall methodCall) async {
    debugPrint("Activity configurationChanged");
    return captcha
        .configurationChanged(methodCall.arguments.cast<String, dynamic>());
  }

  Future<dynamic> validateCaptchaResult(Map<String, String> result) async {
    // TODO
    // Submit captcha result for validation
    debugPrint("Captcha validateCaptchaResult");
    String validate = "Your server url";
    final response = await http.post(Uri.parse(validate),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
        },
        body: result);
    if (response.statusCode == 200) {
      debugPrint("Validate response: ${response.body}");
    } else {
      debugPrint("URL: $validate, Response statusCode: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              TextButton(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Colors.blue.withOpacity(0.04);
                        }
                        if (states.contains(MaterialState.focused) ||
                            states.contains(MaterialState.pressed)) {
                          return Colors.blue.withOpacity(0.12);
                        }
                        return null; // Defer to the widget's default.
                      },
                    ),
                  ),
                  onPressed: verify,
                  child: const Text('click to start verification')),
            ],
          ),
        ),
      ),
    );
  }
}
