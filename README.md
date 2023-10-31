# botion_flutter_plugin

The official flutter plugin project for Botion Adaptive CAPTCHA. Support Flutter 2.0.

[Official](https://www.botion.com)

## Install

Follow the steps below to set up dependencies in project pubspec.yaml

**Github integration**

```yaml
dependencies:
  botion_flutter_plugin:
    git:
      url: https://github.com/BotionTeam/botion_flutter_plugin.git
      ref: main
```

or

**pub integration**

```yaml
dependencies:
  botion_flutter_plugin: ^0.0.2
```

## Configuration

Create your IDs and keys (Botion CAPTCHA) on [Botion dashboard](https://www.botion.com/), and deploy the corresponding back-end API based on [otion documents](https://docs.botion.com/BehaviorVerification/overview/start/).

## Example

### Init

> Please replace random captchaID in the below example with captchaID that you created from [Botion dashboard](https://botion.com/) before you process the integration. ）

```dart
var config = BOCSessionConfiguration();
    config.language = "en";
    config.debugEnable = true;
    config.backgroundColor = Colors.orange;
    captcha =
        BocFlutterPlugin("123456789012345678901234567890ab",config);
```

config explanation

attribute|attribute types|attribute explanation
-----|-----|------
resourcePath | String | Static resource file path is the load local file path by default. If ther is no special requirements, you don't need to configure it. You should set the full path for configurable remote files.
protocol | String | It is used for remote access to static resources. The default value is `https`
userInterfaceStyle | BOC4UserInterfaceStyle | Interface style, enumeration<br>`system` system style <br>`light` normal style <br>`dark` dark style <br> iOS default interface is `light`, Android default interface is `system`
backgroundColor| Color | it is used for set background color, the default value is transparency.
debugEnable | bool | Debugging mode switch, the default value is turn off
canceledOnTouchOutside | bool | It is used for interaction of background clicking, the default value is on.
timeout | int |  Request timeout duration. The unit is milliseconds. The default value is `8000` for iOS and `10000` for Android
language | String | It is used for language setting, the default value is the same as system language. <br>The default language will be Chinese if your system language is not included in Botion multilingual setting. <br>Refer to the list of language short codes in the documentation (ISO 639-2) to specify the language.
additionalParameter | Map<String,dynamic> | Additional parameters, null by default. The parameters will be assembled and submitted to the verification service.

### Verify

```dart
captcha.verify();
```

### Close

```dart
captcha.close();
```

### addEventHandler

```dart
captcha.addEventHandler(onShow: (Map<String, dynamic> message) async {
    // TO-DO
    //  the captcha view is displayed
    debugPrint("Captcha did show");
}, onResult: (Map<String, dynamic> message) async {
    debugPrint("Captcha result: " + message.toString());

    String status = message["status"];
    if (status == "1") {
        // TODO
        //  Send the data in the message ["result"] to query your API
        //  validate the result
        Map result = message["result"] as Map;

    } else {
        //  If the verification fails, it will be automatically retried.
        debugPrint("Captcha 'onResult' state: $status");
    }
}, onError: (Map<String, dynamic> message) async {
    debugPrint("Captcha onError: " + message.toString());
    String code = message["code"];
    // TODO Handling errors returned in verification
    if (Platform.isAndroid) {
        // Android 
        if (code == "-14460") {
        // The authentication session has been canceled
        } else {
        // More error codes refer to the development document
        // https://docs.botion.com/boc/apirefer/errorcode/android
        }
    }

    if (Platform.isIOS) {
        // iOS
        if (code == "-20201") {
        // Verify request timeout
        }
        else if (code == "-20200") {
        // The authentication session has been canceled
        }
        else {
        // More error codes refer to the development document
        // https://docs.botion.com/boc/apirefer/errorcode/ios
        }
    }
});
```
