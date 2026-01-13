import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../config/routes/route_manager.dart';

class FCMService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  @override
  void onInit() {
    super.onInit();
    _initializeFCM();
    _initializeLocalNotifications();
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'RentNSell Notifications',
      description:
          'This channel is used for important notifications from RentNSell.',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      _handleNotificationNavigation(response.payload!);
    }
  }

  void _handleNotificationNavigation(String payload) {
    try {
      if (payload.contains('product')) {
      } else if (payload.contains('notification')) {
        Get.toNamed(AppRoutes.notification);
      }
    } catch (e) {
      print('FCMService: Error handling notification navigation: $e');
    }
  }

  Future<void> _initializeFCM() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('FCMService: User granted notification permission');
        await _getFCMToken();
        _setupMessageHandlers();
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('FCMService: User granted provisional notification permission');
        await _getFCMToken();
        _setupMessageHandlers();
      } else {
        print(
          'FCMService: User declined or has not accepted notification permission',
        );
      }

      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        print('FCMService: FCM Token refreshed: $newToken');
      });
    } catch (e) {
      print('FCMService: Error initializing FCM: $e');
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('FCMService: Received foreground message: ${message.messageId}');
      _showLocalNotification(message);
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'RentNSell Notifications',
            channelDescription:
                'This channel is used for important notifications from RentNSell.',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      print('FCMService: FCM Token: $_fcmToken');
    } catch (e) {
      print('FCMService: Error getting FCM token: $e');
    }
  }

  Future<String?> getToken() async {
    if (_fcmToken == null) {
      await _getFCMToken();
    }
    return _fcmToken;
  }

  Future<void> handleInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('FCMService: App opened from terminated state via notification');
      _handleNotificationNavigation(initialMessage.data.toString());
    }
  }

  void setupOnMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('FCMService: App opened from background via notification');
      _handleNotificationNavigation(message.data.toString());
    });
  }
}
