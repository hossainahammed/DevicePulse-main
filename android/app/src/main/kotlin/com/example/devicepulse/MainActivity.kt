package com.example.devicepulse

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.wifi.WifiManager
import android.os.BatteryManager
import android.os.Build
import android.os.Bundle
import android.telephony.TelephonyManager
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "native/device"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceData" -> {
                    // Check for location permission at runtime
                    if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), 100)
                    }

                    val data = HashMap<String, Any>()

                    // Device Info
                    data["deviceName"] = Build.DEVICE ?: "Unknown"
                    data["model"] = Build.MODEL
                    data["androidVersion"] = Build.VERSION.RELEASE
                    data["brand"] = Build.BRAND
                    data["sdk"] = Build.VERSION.SDK_INT

                    // Battery Data (real readings)
                    val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                    data["batteryLevel"] = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY) // %

                    // Battery Temp via Intent (fallback for BATTERY_PROPERTY_TEMPERATURE issues)
                    val batteryIntent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                    val temp = batteryIntent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) ?: 0
                    data["batteryTemp"] = temp / 10.0 // °C

                    val health = batteryIntent?.getIntExtra(BatteryManager.EXTRA_HEALTH, BatteryManager.BATTERY_HEALTH_UNKNOWN) ?: BatteryManager.BATTERY_HEALTH_UNKNOWN
                    data["batteryHealth"] = when (health) {
                        BatteryManager.BATTERY_HEALTH_GOOD -> "Good"
                        BatteryManager.BATTERY_HEALTH_OVERHEAT -> "Overheat"
                        else -> "Unknown"
                    }

                    // Step Count (placeholder; real tracking requires sensor listener)
                    data["stepCount"] = 0 // Cumulative since boot; expand for live updates

                    // Detected Activity (placeholder; real detection requires Google Play Services)
                    data["detectedActivity"] = "Still" // Expand for live activity recognition

                    // Wi-Fi Data
                    val wifiManager = getSystemService(Context.WIFI_SERVICE) as WifiManager
                    val wifiInfo = wifiManager.connectionInfo
                    
                    var ssid = wifiInfo?.ssid ?: "Not Connected"
                    // Sanitize SSID: Remove extra quotes if present
                    if (ssid.startsWith("\"") && ssid.endsWith("\"")) {
                        ssid = ssid.substring(1, ssid.length - 1)
                    }
                    if (ssid == "<unknown ssid>") {
                        ssid = "Unknown (Check Location/Permissions)"
                    }
                    
                    data["wifiSSID"] = ssid
                    data["wifiRSSI"] = wifiInfo?.rssi ?: -100
                    data["localIP"] = wifiInfo?.ipAddress?.let { intToIp(it) } ?: "Unknown"

                    // Carrier/SIM Data
                    val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                    data["carrierName"] = telephonyManager.networkOperatorName ?: "Unknown"
                    data["cellularSignalStrength"] = if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED) {
                        val cellInfo = telephonyManager.allCellInfo
                        cellInfo?.firstOrNull()?.let { (it as? android.telephony.CellInfoLte)?.cellSignalStrength?.dbm } ?: -100
                    } else {
                        -100
                    }
                    data["simState"] = when (telephonyManager.simState) {
                        TelephonyManager.SIM_STATE_READY -> "Ready"
                        TelephonyManager.SIM_STATE_ABSENT -> "Absent"
                        else -> "Unknown"
                    }

                    result.success(data)
                }
                else -> result.notImplemented()
            }
        }
    }

    // Helper to convert IP int to string
    private fun intToIp(ip: Int): String {
        return (ip and 0xFF).toString() + "." +
                ((ip shr 8) and 0xFF) + "." +
                ((ip shr 16) and 0xFF) + "." +
                ((ip shr 24) and 0xFF)
    }
}

//package com.example.devicepulse
//
//import android.os.Bundle
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//
//class MainActivity : FlutterActivity() {
//
//    private val CHANNEL = "native/device"
//
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        MethodChannel(
//            flutterEngine.dartExecutor.binaryMessenger,
//            CHANNEL
//        ).setMethodCallHandler { call, result ->
//            when (call.method) {
//                "getDeviceData" -> {
//                    val data = HashMap<String, Any>()
//                    data["brand"] = android.os.Build.BRAND
//                    data["model"] = android.os.Build.MODEL
//                    data["sdk"] = android.os.Build.VERSION.SDK_INT
//                    result.success(data)
//                }
//                else -> result.notImplemented()
//            }
//        }
//    }
//}

//package com.example.devicepulse
//
//import androidx.annotation.NonNull
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//
//class MainActivity : FlutterActivity() {
//
//    private val CHANNEL = "devicepulse/native"
//
//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        val provider = DeviceDataProvider(this)
//
//        MethodChannel(
//            flutterEngine.dartExecutor.binaryMessenger,
//            CHANNEL
//        ).setMethodCallHandler { call, result ->
//            if (call.method == "getDeviceData") {
//                val data = HashMap<String, Any>()
//                data.putAll(provider.getBatteryInfo())
//                data.putAll(provider.getWifiInfo())
//                data.putAll(provider.getDeviceInfo())
//                result.success(data)
//            } else {
//                result.notImplemented()
//            }
//        }
//    }
//}
//
//
////package com.example.devicepulse
////
////import android.os.Bundle
////import androidx.annotation.NonNull
////import io.flutter.embedding.android.FlutterActivity
////import io.flutter.embedding.engine.FlutterEngine
////import io.flutter.plugin.common.MethodChannel
////
////class MainActivity : FlutterActivity() {
////
////    private val CHANNEL = "devicepulse/native"
////
////    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
////        super.configureFlutterEngine(flutterEngine)
////
////        val provider = DeviceDataProvider(this)
////
////        MethodChannel(
////            flutterEngine.dartExecutor.binaryMessenger,
////            CHANNEL
////        ).setMethodCallHandler { call, result ->
////            when (call.method) {
////                "getDeviceData" -> {
////                    val data = HashMap<String, Any>()
////                    data.putAll(provider.getBatteryInfo())
////                    data.putAll(provider.getWifiInfo())
////                    data.putAll(provider.getDeviceInfo())
////                    result.success(data)
////                }
////                else -> result.notImplemented()
////            }
////        }
////    }
////}
//
//
////class MainActivity : FlutterActivity() {
////    private val CHANNEL = "native/device"
////
////    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
////        super.configureFlutterEngine(flutterEngine)
////        val provider = DeviceDataProvider(this)
////
////        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
////            .setMethodCallHandler { call, result ->
////                if (call.method == "getDeviceData") {
////                    result.success(provider.collect())
////                }
////            }
////    }
////}
////
