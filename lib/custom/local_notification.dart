import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class LocalNotification {
  static Future<void> showNotification(Map<String, dynamic> message) async {
    print("LocalNotification");
    String title = message['notification']['title'];
    if (title == null){
      return ;
    }else{
      String body = message['notification']['body'];
      int notifID = int.parse(message['data']['notif_id']);
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'PURI', 'Notification', 'All Notification is Here',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');    
      const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          notifID, title, body, platformChannelSpecifics,
          payload: title);
    }
  }

  Future<void> notificationHandler() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
          if (payload != null) {
            print(payload);
            print("OKOK");
          }
        });
  }
}
