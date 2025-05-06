package com.example.agrosys

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.agrosys/sms"
    private val SMS_PERMISSION_REQUEST_CODE = 100
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkSmsPermission" -> {
                    result.success(SmsUtil.hasSmsPermission(context))
                }
                "requestSmsPermission" -> {
                    requestSmsPermission()
                    result.success(null)
                }
                "checkAlarmPermission" -> {
                    result.success(SmsUtil.hasAlarmPermission(context))
                }
                "requestAlarmPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        requestAlarmPermission()
                        result.success(null)
                    } else {
                        result.success(true)
                    }
                }
                "sendSms" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")
                    
                    if (phoneNumber != null && message != null) {
                        val success = SmsUtil.sendSms(context, phoneNumber, message)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Phone number or message is null", null)
                    }
                }
                "scheduleSms" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")
                    val triggerTimeInMillis = call.argument<Long>("triggerTimeInMillis")
                    
                    if (phoneNumber != null && message != null && triggerTimeInMillis != null) {
                        val success = SmsUtil.scheduleSms(context, phoneNumber, message, triggerTimeInMillis)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Invalid arguments provided", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun requestSmsPermission() {
        if (!SmsUtil.hasSmsPermission(context)) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.SEND_SMS),
                SMS_PERMISSION_REQUEST_CODE
            )
        }
    }
    
    private fun requestAlarmPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val intent = Intent().apply {
                action = Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM
            }
            startActivity(intent)
        }
    }
    
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == SMS_PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Log.d(TAG, "SMS permission granted")
            } else {
                Log.d(TAG, "SMS permission denied")
            }
        }
    }
}
