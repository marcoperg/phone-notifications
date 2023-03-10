import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'notifications.dart';
import 'constants.dart' as constants;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AwesomeNotifications().requestPermissionToSendNotifications();
  await NotificationController.initializeLocalNotifications();
  await NotificationController.initializeRemoteNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Notifications',
        theme: ThemeData(
          primarySwatch: constants.MAIN_COLOR,
        ),
        home: const MyHomePage(title: 'Notifications'));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() async {
    NotificationController.testNewNotification();
  }

  @override
  void initState() {
    NotificationController.startListeningNotificationEvents();
    NotificationController.requestFirebaseToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Speech notifications:',
                          style: Theme.of(context).textTheme.headline5),
                      Switch(
                        // This bool value toggles the switch.
                        value: NotificationController.speechNotifications,
                        activeColor: constants.MAIN_COLOR,
                        onChanged: (bool value) {
                          // This is called when the user toggles the switch.
                          setState(() {
                            NotificationController.speechNotifications = value;
                          });
                        },
                      )
                    ],
                  ),
                ],
              )),
        ),
        floatingActionButton: (kDebugMode
            ? (FloatingActionButton(
                onPressed: _incrementCounter,
                tooltip: 'Increment',
                child: const Icon(Icons.announcement_sharp),
              ))
            : null));
  }
}
