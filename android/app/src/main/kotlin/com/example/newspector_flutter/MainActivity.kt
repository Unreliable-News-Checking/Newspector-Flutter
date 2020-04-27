package com.bit.newspector

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

import android.app.NotificationManager
import android.content.Context

class MainActivity: FlutterActivity() {
    private var notificationManager: NotificationManager? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }

    override fun onResume() {
    super.onResume()

    notificationManager = 
                  getSystemService(
                   Context.NOTIFICATION_SERVICE) as NotificationManager

    notificationManager?.cancelAll();
  }
}
