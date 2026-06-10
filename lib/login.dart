import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pab_tugas_besar/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pab_tugas_besar/services/notification_service.dart';
import 'reminder_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    const Color pgerdPurpleBg = Color(0xFFF3F1F9);
    const Color pgerdPurpleIcon = Color(0xFF9FA8DA);
    const Color pgerdBlueBtn = Color(0xFF4C86F9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Image.asset('assets/logo_Pgerd.png', width: 200)],
              ),
              const SizedBox(height: 30),

              const Text(
                "Welcome Back! 👋",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B43A6),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: pgerdPurpleBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    customInputField(
                      controller: emailController,
                      hint: "Masukkan Email",
                      icon: Icons.email_outlined,
                      iconColor: pgerdPurpleIcon,
                    ),
                    const SizedBox(height: 10),
                    customInputField(
                      controller: passwordController,
                      hint: "Password",
                      icon: Icons.lock_outline,
                      iconColor: pgerdPurpleIcon,
                      isPassword: true,
                      isObscure: _isObscure,
                      onToggle: () => setState(() => _isObscure = !_isObscure),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 49,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (emailController.text.isEmpty ||
                              passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  "Email dan Password wajib diisi!",
                                ),
                              ),
                            );
                            return;
                          }

                          String urlAPI = ApiConfig.loginEndpoint;

                          try {
                            final response = await http.post(
                              Uri.parse(urlAPI),
                              body: {
                                "email": emailController.text,
                                "password": passwordController.text,
                              },
                            );

                            final data = jsonDecode(response.body);

                            if (response.statusCode == 200 &&
                                data['status'] == 'success') {
                              var dataUser = data;

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      data['message'] ?? 'Login Berhasil!',
                                    ),
                                  ),
                                );
                              }

                              await NotificationService().registerDeviceToken(
                                dataUser['user_id'].toString(),
                              );

                              if (context.mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/dashboard',
                                  arguments: {
                                    "id":
                                        dataUser['user_id'], // Sesuaikan dengan key dari PHP
                                    "nama": dataUser['nama'],
                                    "email": emailController
                                        .text, // Email diambil dari input user
                                  },
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      data['message'] ??
                                          'Email atau Password salah!',
                                    ),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    "Kendala Koneksi API Login: $e",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pgerdBlueBtn,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("Atau", style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () async {
                  bool loginSukses = await Provider.of<ReminderProvider>(
                    context,
                    listen: false,
                  ).signInWithGoogleObat();

                  if (loginSukses) {
                    final prefs = await SharedPreferences.getInstance();
                    String userId = prefs.getString('user_id') ?? '';
                    String namaUser = prefs.getString('nama_user') ?? '';

                    await NotificationService().registerDeviceToken(userId);

                    if (context.mounted) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/dashboard',
                        arguments: {
                          "id": userId,
                          "nama": namaUser,
                          "email": "",
                        },
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            "Gagal masuk menggunakan Google, coba lagi!",
                          ),
                        ),
                      );
                    }
                  }
                },

                icon: Image.asset('assets/google_logo.png', width: 40),
                label: const Text(
                  "Masuk dengan Google",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Colors.black12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 49),
                  elevation: 0,
                ),
              ),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Belum punya akun? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/registrasi');
                    },
                    child: const Text(
                      "Daftar",
                      style: TextStyle(
                        color: pgerdBlueBtn,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isObscure : false,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: iconColor, fontSize: 15),
          prefixIcon: Icon(icon, color: iconColor),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: iconColor,
                  ),
                  onPressed: onToggle,
                )
              : null,
        ),
      ),
    );
  }
}
