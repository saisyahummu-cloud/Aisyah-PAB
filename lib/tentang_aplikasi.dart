import 'package:flutter/material.dart';

class TentangAplikasiPage extends StatelessWidget {
  const TentangAplikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF0D47A1),
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  const Spacer(),
                  Image.asset('assets/logo_Pgerd.png', width: 200),
                  const Spacer(),
                  const SizedBox(width: 5),
                ],
              ),
              const SizedBox(height: 35),

              const Text(
                "Tentang PGerd",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withValues(alpha: .05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PGerd membantu pengguna mengingat jadwal minum obat sebelum makan dan membantu kepatuhan dengan cara sederhana.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 1,
                      color: Colors.grey.withValues(alpha: .15),
                    ),
                    const SizedBox(height: 15),

                    const Text(
                      "Versi Aplikasi:",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "1.0.0",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 1,
                      color: Colors.grey.withValues(alpha: .15),
                    ),
                    const SizedBox(height: 15),

                    const Text(
                      "Dikembangkan oleh:",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Aisyah - D4 SIKC 2B",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 1,
                      color: Colors.grey.withValues(alpha: .15),
                    ),
                    const SizedBox(height: 15),

                    Text(
                      "@2026 PGerd",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
