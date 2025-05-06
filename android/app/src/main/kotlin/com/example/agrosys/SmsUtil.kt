package com.example.agrosys

import android.Manifest
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.SmsManager
import android.util.Log
import androidx.core.content.ContextCompat
import java.util.Calendar

object SmsUtil {
    private const val TAG = "SmsUtil"
    
    /**
     * Check if SMS permission is granted
     */
    fun hasSmsPermission(context: Context): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.SEND_SMS
        ) == PackageManager.PERMISSION_GRANTED
    }
    
    /**
     * Check if alarm permissions are granted (for Android 12+)
     */
    fun hasAlarmPermission(context: Context): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            return alarmManager.canScheduleExactAlarms()
        }
        return true
    }
    
    /**
     * Send SMS immediately
     */
    fun sendSms(context: Context, phoneNumber: String, message: String): Boolean {
        if (!hasSmsPermission(context)) {
            Log.e(TAG, "SMS permission not granted")
            return false
        }
        
        try {
            val smsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                context.getSystemService(SmsManager::class.java)
            } else {
                @Suppress("DEPRECATION")
                SmsManager.getDefault()
            }
            
            smsManager.sendTextMessage(phoneNumber, null, message, null, null)
            Log.d(TAG, "SMS sent successfully to $phoneNumber")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to send SMS", e)
            return false
        }
    }
    
    /**
     * Schedule SMS to be sent at a specific time
     */
    fun scheduleSms(context: Context, phoneNumber: String, message: String, triggerTimeInMillis: Long): Boolean {
        if (!hasSmsPermission(context)) {
            Log.e(TAG, "SMS permission not granted")
            return false
        }
        
        if (!hasAlarmPermission(context)) {
            Log.e(TAG, "Alarm permission not granted")
            return false
        }
        
        try {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            
            val intent = Intent(context, AlarmReceiver::class.java).apply {
                putExtra("phoneNumber", phoneNumber)
                putExtra("message", message)
            }
            
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                System.currentTimeMillis().toInt(),
                intent,
                flags
            )
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeInMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerTimeInMillis, pendingIntent)
            }
            
            Log.d(TAG, "SMS scheduled for $triggerTimeInMillis")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to schedule SMS", e)
            return false
        }
    }
} 