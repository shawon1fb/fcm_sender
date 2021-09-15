import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'cinfig.dart';
import 'devise_list_page.dart';
import 'fcm_notification_model.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM SENDER',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "Prata-Regular",
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff316B83),
          elevation: 1.0,
        ),
      ),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: const DeviceListPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void showNotification() {
    FcmNotificationModel m = FcmNotificationModel(
      notificationTitle: 'notification',
      token: '',
      gameId: '001',
      notificationBody: 'noticication for test',
      routeName: 'empty',
    );

    // sendAndRetrieveMessage(
    //
    // );

    // setState(() {
    //   _counter++;
    // });
    // flutterLocalNotificationsPlugin.show(
    //   0,
    //   "Testing s  $_counter",
    //   "How you doin ?",
    //   const NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       // channelId ?? 'your channel id',
    //       'your channel id',
    //       'your channel name',
    //       'your channel description',
    //       sound: RawResourceAndroidNotificationSound('azan'),
    //       autoCancel: false,
    //       playSound: true,
    //       enableVibration: true,
    //
    //       priority: Priority.high,
    //       importance: Importance.max,
    //       color: Color(0xff198C5F),
    //       ledColor: Colors.green,
    //
    //       icon: "app_icon_4",
    //       ledOffMs: 1,
    //       ledOnMs: 1,
    //
    //       //icon: "food",
    //       // largeIcon: DrawableResourceAndroidBitmap("logoramadan"),
    //       ongoing: true,
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showNotification,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
