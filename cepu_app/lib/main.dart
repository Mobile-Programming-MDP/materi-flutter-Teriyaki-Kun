import 'package:cepu_app/firebase_options.dart';
import 'package:cepu_app/screens/home_screen.dart';
import 'package:cepu_app/screens/sign_in_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  print('Izin Notifikasi Diberikan');
} else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
  print('Izin Notifikasi Sementara Diberikan');
} else {
  print('Izin Notifikasi Ditolak');
}
}

Future<void> showBasicNotification(String? title, String? body) async {
  final android = AndroidNotificationDetails(
    'Default_Channel',
    'Notifikasi Default',
    channelDescription: 'Notifikasi Masuk Dari CFM',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
  );

 final platform = NotificationDetails(android: android);
 await flutterLocalNotificationsPlugin.show(
    id: 0,
    title: title,
    body: body,
    notificationDetails: platform,
  );
  
} 

Future<void> showNotificationFromData(Map<String, dynamic> data) async {
  String? title = data['title'];
  String? body = data['body'];
  final sender = data['senderName'] ?? 'Unknown Sender';
  final time = data['sentAt'] ?? '';
  final photoUrl = data['senderPhotoUrl'] ?? '';
  await showBasicNotification(title, body);

  ByteArrayAndroidBitmap? largeIconBitmap;
  if (photoUrl.isNotEmpty) {
    final base64 = await _networkImageToBase64(photoUrl);
    if(base64 != null) {
      largeIconBitmap = ByteArrayAndroidBitmap.fromBase64String(base64);
    }
  }

  final styleInfo = 
  largeIconBitmap != null
  ? BigPictureStyleInformation(
    largeIconBitmap,
    contentTitle: title,
    summaryText: '$body\nDari: $sender - $time',
    largeIcon: largeIconBitmap,
    hideExpandedLargeIcon: true,
  ) : BigTextStyleInformation('$body\n\nDari : $sender - $time', 
  contentTitle: title);

  final simpleStyleInfo = BigTextStyleInformation('$body\n\nDari : $sender - $time',
  contentTitle: title);

  final androidDetails = AndroidNotificationDetails(
   'Detailed Channel' , 
   'Notifikasi Detail',
   channelDescription: 'Notifikasi dengan Detail Tambahan',
   styleInformation: simpleStyleInfo,
   largeIcon: largeIconBitmap,
   importance: Importance.max,
   priority: Priority.max);

   final platform = NotificationDetails(android: androidDetails);
   await flutterLocalNotificationsPlugin.show(
    id: 0,
    title: title,
    body: body,
    notificationDetails: platform,
   );
}

Future<String?> _networkImageToBase64(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return base64Encode(response.bodyBytes);
    }
  } catch(_){}
  return null;
}






void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cepu App",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const SignInScreen();
          }
        },
      ),
    );
  }
}
