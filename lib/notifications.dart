import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_core/firebase_core.dart';

import 'handleAudio.dart';
import 'constants.dart' as constants;

class NotificationController extends ChangeNotifier {
  static ReceivedAction? initialAction;
  static late FlutterTts tts;
  static late AudioPlayerHandler audioPlayer;
  static bool speechNotifications = true;

  static final NotificationController _instance =
      NotificationController._internal();

  factory NotificationController() {
    return _instance;
  }

  NotificationController._internal();
  String _firebaseToken = '';
  String get firebaseToken => _firebaseToken;

  String _nativeToken = '';
  String get nativeToken => _nativeToken;

  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
              channelKey: 'alerts',
              channelName: 'Alerts',
              channelDescription: 'Notification tests as alerts',
              playSound: true,
              onlyAlertOnce: true,
              groupAlertBehavior: GroupAlertBehavior.Children,
              importance: NotificationImportance.High,
              defaultPrivacy: NotificationPrivacy.Private,
              defaultColor: Colors.deepPurple,
              ledColor: Colors.deepPurple)
        ],
        debug: kDebugMode);

    AwesomeNotificationsFcm().subscribeToTopic(constants.FCM_TOPIC);
    tts = FlutterTts();
    await tts.awaitSpeakCompletion(true);
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  static Future<void> initializeRemoteNotifications() async {
    await Firebase.initializeApp();
    await AwesomeNotificationsFcm().initialize(
        onFcmSilentDataHandle: NotificationController.mySilentDataHandle,
        onFcmTokenHandle: NotificationController.myFcmTokenHandle,
        onNativeTokenHandle: NotificationController.myNativeTokenHandle,
        licenseKeys: null,
        debug: kDebugMode);
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onNotificationDisplayedMethod: onNotificationDisplayedMethod);
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (kDebugMode) {
      print('New action');
    }
    if (speechNotifications) await tts.speak('New action');
    //SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    if (kDebugMode) {
      print('New notification');
    }
    String text = receivedNotification.title != null
        ? receivedNotification.title!
        : 'notification';
    if (speechNotifications) await tts.speak(text);
    if (!kDebugMode) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  static Future<void> createNewNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: -1, // -1 is replaced by a random number
            channelKey: 'alerts',
            fullScreenIntent: true,
            title: 'Huston! The eagle has landed!',
            body:
                "A small step for a man, but a giant leap to Flutter's community!",
            bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
            largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
            //'asset://assets/images/balloons-in-sky.jpg',
            notificationLayout: NotificationLayout.BigPicture,
            payload: {'notificationId': '1234567890'}),
        actionButtons: [
          NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
          NotificationActionButton(
              key: 'REPLY',
              label: 'Reply Message',
              requireInputText: true,
              actionType: ActionType.SilentAction),
          NotificationActionButton(
              key: 'DISMISS',
              label: 'Dismiss',
              actionType: ActionType.DismissAction,
              isDangerousOption: true)
        ]);
  }

  static Future<void> scheduleNewNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: -1, // -1 is replaced by a random number
            channelKey: 'alerts',
            fullScreenIntent: true,
            wakeUpScreen: false,
            title: "Huston! The eagle has landed!",
            body:
                "A small step for a man, but a giant leap to Flutter's community!",
            bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
            largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
            //'asset://assets/images/balloons-in-sky.jpg',
            notificationLayout: NotificationLayout.BigPicture,
            payload: {
              'notificationId': '1234567890'
            }),
        actionButtons: [
          NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
          NotificationActionButton(
              key: 'DISMISS',
              label: 'Dismiss',
              actionType: ActionType.DismissAction,
              isDangerousOption: true)
        ],
        schedule: NotificationCalendar.fromDate(
            date: DateTime.now().add(const Duration(seconds: 5))));
  }

  static Future<String> requestFirebaseToken() async {
    if (await AwesomeNotificationsFcm().isFirebaseAvailable) {
      try {
        return await AwesomeNotificationsFcm().requestFirebaseAppToken();
      } catch (exception) {
        debugPrint('$exception');
      }
    } else {
      debugPrint('Firebase is not available on this project');
    }
    return '';
  }

  @pragma("vm:entry-point")
  static Future<void> mySilentDataHandle(FcmSilentData silentData) async {
    if (kDebugMode) print('Silent data: $silentData');
  }

  @pragma("vm:entry-point")
  static Future<void> myFcmTokenHandle(String token) async {
    if (kDebugMode) print('Firebase Token: "$token"');
    _instance._firebaseToken = token;
    _instance.notifyListeners();
  }

  /// Use this method to detect when a new native token is received
  @pragma("vm:entry-point")
  static Future<void> myNativeTokenHandle(String token) async {
    if (kDebugMode) print('Native Token:"$token"');
    _instance._nativeToken = token;
    _instance.notifyListeners();
  }
}
