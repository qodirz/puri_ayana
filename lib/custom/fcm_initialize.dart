import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:puri_ayana_gempol/custom/local_notification.dart';


class FirebaseMessage{

  //Define your method
  static void fcmInitialize () {
    final firebaseMessaging = FirebaseMessaging();
    firebaseMessaging.configure(
      onMessage: (message) async {
        print('onMessage');
        print(message);
        LocalNotification.showNotification(message);
      },
      onBackgroundMessage: onBackgroundMessage,
      onResume: (message) async {
        print('onResume');
        print(message);
        // Navigation
      },
      onLaunch: (message) async {
        print('onLaunch');
        print(message);  
        LocalNotification.showNotification(message);
      },
    );
    firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: true),
    );
    firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print('Settings registered: $settings');
    });
  }

  static Future<dynamic> onBackgroundMessage(message) {
    return LocalNotification.showNotification(message);
  }  

}

