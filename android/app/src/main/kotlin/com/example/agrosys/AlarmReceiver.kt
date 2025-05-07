package com.example.agrosys

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.Toast

class AlarmReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "AlarmReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Alarm received")
        
        val phoneNumber = intent.getStringExtra("phoneNumber")
        val message = intent.getStringExtra("message")
        
        if (phoneNumber != null && message != null) {
            Log.d(TAG, "Sending scheduled SMS to $phoneNumber")
            
            val success = SmsUtil.sendSms(context, phoneNumber, message)
            
            if (success) {
                Log.d(TAG, "Scheduled SMS sent successfully")
                Toast.makeText(context, "Scheduled SMS sent successfully", Toast.LENGTH_SHORT).show()
            } else {
                Log.e(TAG, "Failed to send scheduled SMS")
                Toast.makeText(context, "Failed to send scheduled SMS", Toast.LENGTH_SHORT).show()
            }
        } else {
            Log.e(TAG, "Phone number or message is null")
        }
        
        // Handle boot completed if this is a boot completed intent
        if (Intent.ACTION_BOOT_COMPLETED == intent.action) {
            Log.d(TAG, "Boot completed, restore scheduled alarms")
            // Here you would typically restore any persisted alarms
            // This would require storing scheduled alarms in a database or shared preferences
        }
    }
} 