import 'package:pab_tugas_besar/detail_reminder.dart';
import 'package:pab_tugas_besar/login.dart';
import 'package:pab_tugas_besar/profile.dart';
import 'package:pab_tugas_besar/pengingat_saya.dart';
import 'package:pab_tugas_besar/tentang_aplikasi.dart';
import 'registrasi.dart';
import 'dashboard.dart';
import 'reminder.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pab_tugas_besar/reminder_provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pab_tugas_besar/services/notification_service.dart';
import 'package:pab_tugas_besar/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  NotificationService notificationService = NotificationService();
  await notificationService.initNotification();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ReminderProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const SplashScreen(),
        '/dashboard': (context) => const DashboardPage(),
        '/reminder': (context) => const ReminderPage(),
        '/login': (context) => const LoginPage(),
        '/registrasi': (context) => const RegistrasiPage(),
        '/profile': (context) => const ProfilePage(),
        '/pengingat_saya': (context) => const PengingatSayaPage(),
        '/tentang_aplikasi': (context) => const TentangAplikasiPage(),
        '/detail_reminder': (context) => const DetailReminderPage(),
      },
    );
  }
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil fungsi pengecekan
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    final provider = Provider.of<ReminderProvider>(context, listen: false);
    final user = await provider.cekStatusLogin();

    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacementNamed(
        context,
        '/dashboard',
        arguments: {'id': user['id'], 'nama': user['nama_user']},
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo_Pgerd.png',
              width: 300,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, size: 200, color: Colors.red),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
