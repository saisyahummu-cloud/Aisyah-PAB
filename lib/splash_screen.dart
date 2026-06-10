import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pab_tugas_besar/reminder_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
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
        arguments: {'id': user['id'], 'nama': user['nama']},
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
                  const Icon(Icons.error, size: 100, color: Colors.red),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
