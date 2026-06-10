import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegistrasiPage extends StatefulWidget {
  const RegistrasiPage({super.key});

  @override
  State<RegistrasiPage> createState() => _RegistrasiPageState();
}

class _RegistrasiPageState extends State<RegistrasiPage> {
  bool _isObscure = true;
  bool _isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _prosesDaftar() async {
    if (passController.text != confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Password tidak sama!"),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String urlAPI = "http://192.168.1.7/pgerd_backend/registrasi.php";

    try {
      final response = await http.post(
        Uri.parse(urlAPI),
        body: {
          "nama": nameController.text,
          "email": emailController.text,
          "password": passController.text,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Registrasi Berhasil!')),
        );

        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(data['message'] ?? 'Registrasi Gagal!'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Kendala Koneksi API: $e"),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
          child: Form(
            key: _formKey,
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
                  "Buat Akun Baru",
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
                      customTextField(
                        controller: nameController,
                        hint: "Masukkan Nama",
                        icon: Icons.person_outline,
                        iconColor: pgerdPurpleIcon,
                      ),
                      const SizedBox(height: 10),
                      customTextField(
                        controller: emailController,
                        hint: "Masukkan Email",
                        icon: Icons.email_outlined,
                        iconColor: pgerdPurpleIcon,
                      ),
                      const SizedBox(height: 10),
                      customTextField(
                        controller: passController,
                        hint: "Masukkan Password",
                        icon: Icons.lock_outline,
                        iconColor: pgerdPurpleIcon,
                        isPassword: true,
                        isObscure: _isObscure,
                        onToggle: () =>
                            setState(() => _isObscure = !_isObscure),
                      ),
                      const SizedBox(height: 10),
                      customTextField(
                        controller: confirmPassController,
                        hint: "Konfirmasi Password",
                        icon: Icons.lock_reset_outlined,
                        iconColor: pgerdPurpleIcon,
                        isPassword: true,
                        isObscure: _isObscure,
                        onToggle: () =>
                            setState(() => _isObscure = !_isObscure),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 49,
                        child: ElevatedButton.icon(
                          icon: _isLoading
                              ? const SizedBox.shrink()
                              : const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                ),
                          label: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Daftar",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pgerdBlueBtn,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _isLoading ? null : _prosesDaftar,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Sudah punya akun?",
                  style: TextStyle(color: Colors.grey),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: pgerdBlueBtn,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customTextField({
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          prefixIcon: Icon(icon, color: iconColor),
          hintText: hint,
          hintStyle: TextStyle(color: iconColor),
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
