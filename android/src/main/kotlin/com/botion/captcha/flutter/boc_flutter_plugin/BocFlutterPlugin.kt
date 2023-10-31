package com.botion.captcha.flutter.boc_flutter_plugin

import android.app.Activity
import android.content.Context
import android.content.res.Configuration
import android.os.Build
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import com.botion.captcha.BOCaptchaClient
import com.botion.captcha.BOCaptchaConfig
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONArray
import org.json.JSONObject

/** BocFlutterPlugin */
class BocFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private var activity: Activity? = null
    private lateinit var channel: MethodChannel
    private var boCaptchaClient: BOCaptchaClient? = null
    private val tag = "| Botion | Android | "

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "botion_flutter_plugin")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initWithCaptcha" -> {
                initWithCaptcha(activity!!, call.arguments)
            }
            "verify" -> {
                verifyWithCaptcha()
            }
            "close" -> {
                boCaptchaClient?.cancel()
            }
            "configurationChanged" -> {
                configurationChanged(Configuration())
            }
            "getPlatformVersion" -> {
                result.success(BOCaptchaClient.getVersion())
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    private fun initWithCaptcha(context: Context, param: Any?) {
        if (param !is Map<*, *>) {
            return
        }

        boCaptchaClient = BOCaptchaClient.getClient(context)

        if (param.containsKey("config")) {
            val configBuilder = BOCaptchaConfig.Builder()
            val configParams = param["config"] as Map<String, Any>
            if (configParams.containsKey("resourcePath")) {
                configBuilder.setResourcePath(configParams["resourcePath"] as String)
            }
            val hashMap = HashMap<String, Any>()
            if (configParams.containsKey("protocol")) {
                hashMap["protocol"] = configParams["protocol"] as String
            }
            if (configParams.containsKey("userInterfaceStyle")) {
                hashMap["displayMode"] = configParams["userInterfaceStyle"] as Int
            }
            if (configParams.containsKey("backgroundColor")) {
                val backgroundColorStr = configParams["backgroundColor"] as String
                if (backgroundColorStr.length == 8) {
                    hashMap["bgColor"] = String.format("#%s", backgroundColorStr)
                } else {
                    hashMap["bgColor"] = String.format("#FF%s", backgroundColorStr)
                }
            }
            if (configParams.containsKey("debugEnable")) {
                configBuilder.setDebug(configParams["debugEnable"] as Boolean)
            }
            if (configParams.containsKey("logEnable")) {
                boCaptchaClient?.setLogEnable(configParams["logEnable"] as Boolean)
            }
            if (configParams.containsKey("canceledOnTouchOutside")) {
                configBuilder.setCanceledOnTouchOutside(configParams["canceledOnTouchOutside"] as Boolean)
            }
            if (configParams.containsKey("timeout")) {
                configBuilder.setTimeOut(configParams["timeout"] as Int)
            }
            if (configParams.containsKey("language")) {
                configBuilder.setLanguage(configParams["language"] as String)
            }
            if (configParams.containsKey("staticServers")) {
                val staticServers =configParams["staticServers"] as ArrayList<String>
                configBuilder.setStaticServers(staticServers.toTypedArray())
            }
            if (configParams.containsKey("apiServers")) {
                val apiServers =configParams["apiServers"] as ArrayList<String>
                configBuilder.setApiServers(apiServers.toTypedArray())
            }
            if (configParams.containsKey("additionalParameter")) {
                val additionalParameter: Map<String, Any> =
                    configParams["additionalParameter"] as Map<String, Any>
                additionalParameter.forEach {
                    hashMap[it.key] =
                        if (it.value is ArrayList<*>) JSONArray(it.value as ArrayList<*>) else it.value
                }
            }
            configBuilder.setParams(hashMap)
            boCaptchaClient?.init(param["captchaId"] as String, configBuilder.build())
        } else {
            boCaptchaClient?.init(param["captchaId"] as String)
        }
    }

    private fun verifyWithCaptcha() {
        boCaptchaClient
            ?.addOnSuccessListener { status, response ->
                val jsonObject: JSONObject
                val valueMap = HashMap<String, Any>()
                try {
                    jsonObject = JSONObject(response)
                    val iterator: Iterator<String> = jsonObject.keys()
                    var key: String
                    var value: Any
                    while (iterator.hasNext()) {
                        key = iterator.next()
                        value = jsonObject[key] as Any
                        valueMap[key] = value
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
                channel.invokeMethod(
                    "onResult",
                    hashMapOf("status" to if (status) "1" else "0", "result" to valueMap)
                )
            }
            ?.addOnFailureListener { message ->
                val jsonObject = JSONObject(message)
                channel.invokeMethod(
                    "onError",
                    hashMapOf(
                        "code" to jsonObject.optString("code"),
                        "msg" to jsonObject.optString("msg"),
                        "desc" to jsonObject.optJSONObject("desc")?.toString()
                    )
                )
            }
            ?.verifyWithCaptcha()
    }

    private fun configurationChanged(newConfig: Configuration?) {
        boCaptchaClient?.configurationChanged(newConfig)
    }

    private fun destroy() {
        boCaptchaClient?.destroy()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        destroy()
        activity = null
    }

}
