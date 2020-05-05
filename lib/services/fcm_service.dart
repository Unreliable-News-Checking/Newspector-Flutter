import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  static Function onMessage;
  static Function onResume;

  /// Configures the FCM callback functions.
  ///
  /// Functions are optional parameters. If there is no override, the old callback remains active.
  static void configureFCM({
    Function onMessage,
    Function onResume,
  }) {
    if (onMessage != null) FCMService.onMessage = onMessage;
    if (onResume != null) FCMService.onResume = onResume;

    updateNotificationCallbacks();
  }

  /// Applies the callback functions to the FCM library.
  static void updateNotificationCallbacks() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        var data = message['data'];
        FCMService.onMessage(data);
      },
      onLaunch: (Map<String, dynamic> message) async {
        var data = message['data'];
        FCMService.onResume(data);
      },
      onResume: (Map<String, dynamic> message) async {
        var data = message['data'];
        FCMService.onResume(data);
      },
    );
  }

  /// Requests notification permissions for the FCM library.
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

  /// Subscribes the device to a notification topic.
  static void subscribeToTopic(String topicName) {
    _firebaseMessaging.subscribeToTopic(topicName);
  }

  /// Unsubscribes the device from a notification topic.
  static void unsubscribeFromTopic(String topicName) {
    _firebaseMessaging.unsubscribeFromTopic(topicName);
  }

  /// Subscribes the device to topic of news group that the user is currently following.
  static void subscribeToEveryFollowingNews() {
    // var newsGroupIds = FirestoreService.getUserFollowsNewsGroups(newsGroupId);
  }

  /// Unsubscribes the device from all the notification topics.
  static void unsubscribeFromEveryFollowingNews() {}
}
