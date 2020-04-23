import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  static Function onMessage;
  static Function onResume;

  static void configureFCM({
    Function onMessage,
    Function onResume,
  }) {
    if (onMessage != null) FCMService.onMessage = onMessage;
    if (onResume != null) FCMService.onResume = onResume;

    updateNotificationCallbacks();
  }

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

  static void subscribeToEveryFollowingNews()
  {
    // var newsGroupIds = FirestoreService.getUserFollowsNewsGroups(newsGroupId);
  }

  static void unsubscribeFromEveryFollowingNews()
  {

  }
}
