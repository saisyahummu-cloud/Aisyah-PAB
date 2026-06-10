import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    String namaUser = (args != null && args['nama'] != null)
        ? args['nama']
        : "Aisyahee";
    String emailUser = (args != null && args['email'] != null)
        ? args['email']
        : "aisyahee@gmail.com";

    const Color primaryBlue = Color(0xFF4285F4);

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
              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9).withValues(alpha: .5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0B43A6),
                              width: 3,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Color(0xFFE2E8F0),
                            backgroundImage: AssetImage('assets/me.png'),
                          ),
                        ),

                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Color(0xFF0B43A6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    Text(
                      namaUser,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B43A6),
                      ),
                    ),
                    const SizedBox(height: 2),

                    Text(
                      emailUser,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final args =
                              ModalRoute.of(context)?.settings.arguments
                                  as Map<String, dynamic>?;

                          Navigator.pushNamed(
                            context,
                            '/reminder',
                            arguments: {
                              'id': (args != null && args['id'] != null)
                                  ? args['id'].toString()
                                  : "1",
                              'nama': (args != null && args['nama'] != null)
                                  ? args['nama']
                                  : "User",
                              'email': (args != null && args['email'] != null)
                                  ? args['email']
                                  : "user@email.com",
                            },
                          ).then((value) {
                            if (value == true) {
                              setState(() {});
                            }
                          });
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "Tambah Jadwal",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- LIST MENU BAWAH CARD ---
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9).withValues(alpha: .5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Menu Tentang Aplikasi
                    _buildMenuListRow(
                      Icons.info_outline,
                      "Tentang Aplikasi",
                      () {
                        Navigator.pushNamed(context, '/tentang_aplikasi');
                      },
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey.withValues(alpha: .1),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    // Menu Logout
                    _buildMenuListRow(Icons.logout, "Logout", () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();

                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
              arguments: args,
            );
          } else if (index == 1) {
            Navigator.pushNamed(context, '/reminder', arguments: args);
          } else if (index == 2) {
            return;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: "Reminder",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildMenuListRow(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1E3A8A), size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E3A8A),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFF1E3A8A),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
