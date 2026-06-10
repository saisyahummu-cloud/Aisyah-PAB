import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:pab_tugas_besar/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Izin notifikasi diberikan: ${settings.authorizationStatus}');

    
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', 
      'Notifikasi Penting',
      importance: Importance.max,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(initializationSettings);

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Notifikasi diterima: ${message.notification?.title}');

      if (message.notification != null) {
        _localNotificationsPlugin.show(
          message.hashCode,
          message.notification!.title,
          message.notification!.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails
    androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel', 
      'Notifikasi Penting',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotificationsPlugin.show(
      DateTime.now().millisecond,
      message.notification?.title ?? 'Aplikasi PGerd',
      message.notification?.body ?? '',
      platformChannelSpecifics,
    );
  }

  Future<void> registerDeviceToken(String string) async {
    
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      if (userId == null) {
        debugPrint("Gagal kirim token: User belum login!");
        return;
      }

      String? token = await _messaging.getToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse(ApiConfig.registerTokenEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_user": userId, "token": token}),
      );

      debugPrint("Status Code API: ${response.statusCode}");
      debugPrint("Response API: ${response.body}");
    } catch (e) {
      debugPrint("Error kirim token: $e");
    }
  }
}
