import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/routes/route_manager.dart';
import 'services/fcm_service.dart';
import 'utils/shared_pref.dart';
import 'utils/theme_manager.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(
    'FCM Background Handler: Received background message: ${message.messageId}',
  );
  print('FCM Background Handler: Message data: ${message.data}');
  print(
    'FCM Background Handler: Message notification: ${message.notification?.title}',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await preferences.init();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  final fcmService = Get.put(FCMService());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    fcmService.handleInitialMessage();
    fcmService.setupOnMessageOpenedApp();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RentNSell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: colorMainTheme),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}
