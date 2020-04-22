package com.bit.newspector

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.graphics.Color

class Application : FlutterApplication(), PluginRegistrantCallback {
  private var notificationManager: NotificationManager? = null

  override fun onCreate() {
    super.onCreate()
    FlutterFirebaseMessagingService.setPluginRegistrant(this)

    notificationManager = 
                  getSystemService(
                   Context.NOTIFICATION_SERVICE) as NotificationManager

    createNotificationChannel(
                "very_important",
                "Very Important",
                "Very important Description")
  }

  override fun registerWith(registry: PluginRegistry?) {
  io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin.registerWith(registry?.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
  }

  private fun createNotificationChannel(id: String, name: String,
                                            description: String) {
 
        val importance = NotificationManager.IMPORTANCE_HIGH 
        val channel = NotificationChannel(id, name, importance)
 
        channel.description = description
        channel.enableLights(true)
        channel.lightColor = Color.RED
        channel.enableVibration(true)
        channel.vibrationPattern = 
            longArrayOf(100, 200, 300, 400, 500, 400, 300, 200, 400)
        notificationManager?.createNotificationChannel(channel)
    }

}