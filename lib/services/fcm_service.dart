import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class FCMService {
  static FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  // static Future<dynamic> myBackgroundMessageHandler(
  //     Map<String, dynamic> message) {
  //   if (message.containsKey('data')) {
  //     // Handle data message
  //     final dynamic data = message['data'];
  //   }

  //   if (message.containsKey('notification')) {
  //     // Handle notification message
  //     final dynamic notification = message['notification'];
  //   }

  //   // Or do other work.
  // }

  static void configureFCM({
    @required Function onMessage,
    @required Function onResume,
  }) {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        onMessage();
        // _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        var data = message['data'];
        print(data['news_group_id']);
        onResume(data['news_group_id']);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        var data = message['data'];
        print(data['news_group_id']);
        onResume(data['news_group_id']);
      },
    );
  }

  static void requestNotificationPermissions() {
    _firebaseMessaging
        .requestNotificationPermissions(const IosNotificationSettings(
      sound: true,
      badge: true,
      alert: true,
      provisional: true,
    ));

    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  static void subscribeToTopic(String topicName) {
    _firebaseMessaging.subscribeToTopic(topicName);
  }

  static void unsubscribeFromTopic(String topicName) {
    _firebaseMessaging.unsubscribeFromTopic(topicName);
  }
}
