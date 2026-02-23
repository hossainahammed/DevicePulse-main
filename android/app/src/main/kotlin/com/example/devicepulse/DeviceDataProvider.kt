package com.example.devicepulse

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.wifi.WifiManager
import android.os.BatteryManager
import android.os.Build
import android.text.format.Formatter

class DeviceDataProvider(private val context: Context) {

    fun getBatteryInfo(): Map<String, Any> {
        val intent = context.registerReceiver(
            null,
            IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        )

        val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val temp = intent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1) ?: -1

        return mapOf(
            "batteryLevel" to level,
            "batteryTemp" to temp / 10.0,
            "batteryHealth" to "Good"
        )
    }

    fun getWifiInfo(): Map<String, Any> {
        val wifiManager =
            context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager

        val info = wifiManager.connectionInfo

        return mapOf(
            "ssid" to info.ssid,
            "rssi" to info.rssi,
            "ip" to Formatter.formatIpAddress(info.ipAddress)
        )
    }

    fun getDeviceInfo(): Map<String, Any> {
        return mapOf(
            "model" to Build.MODEL,
            "androidVersion" to Build.VERSION.RELEASE,
            "device" to Build.DEVICE
        )
    }
}

//class DeviceDataProvider(private val context: Context) {
//
//    fun collect(): Map<String, Any> {
//        val intent = context.registerReceiver(
//            null,
//            IntentFilter(Intent.ACTION_BATTERY_CHANGED)
//        )!!
//
//        val temp = intent.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) / 10.0
//        val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, 0)
//
//        val wifi = context.applicationContext
//            .getSystemService(Context.WIFI_SERVICE) as WifiManager
//
//        val info = wifi.connectionInfo
//
//        return mapOf(
//            "battery" to mapOf(
//                "temperature" to temp,
//                "level" to level,
//                "health" to "Good"
//            ),
//            "wifi" to mapOf(
//                "ssid" to info.ssid,
//                "rssi" to info.rssi,
//                "ip" to Formatter.formatIpAddress(info.ipAddress)
//            ),
//            "device" to mapOf(
//                "model" to Build.MODEL,
//                "android" to Build.VERSION.RELEASE,
//                "name" to Build.DEVICE
//            )
//        )
//    }
//}
