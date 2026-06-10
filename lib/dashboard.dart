import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pab_tugas_besar/reminder_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final int _selectedIndex = 0;
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isFirstLoad) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      String idUserAktif = (args != null && args['id'] != null)
          ? args['id'].toString()
          : "1";

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ReminderProvider>().ambilDataReminder(idUserAktif);
      });

      _isFirstLoad = false;
    }
  }

  void _tampilkanPopUpSukses(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: const Center(
            child: Column(
              children: [
                Icon(Icons.stars, color: Colors.amber, size: 60),
                SizedBox(height: 10),
                Text(
                  "Yeeay, Awesome! 🌟",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          content: const Text(
            "Kamu sudah menyelesaikan jadwal minum obat lambung tepat waktu!\n\nTetap semangat ya! 🌸💪",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            Center(
              child: SizedBox(
                width: 150,
                height: 40,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    "Oke, Lanjut!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _tampilkanDialogKonfirmasiHapus(
    BuildContext context,
    String idJadwal,
    String idUser,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFEA4335),
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                "Hapus Jadwal?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: const Text(
            "Apakah kamu yakin ingin menghapus jadwal pengingat obat ini? Data tidak bisa dikembalikan.",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                );

                await Future.delayed(const Duration(seconds: 4));

                Navigator.pop(context);
                Navigator.pop(context);

                await context.read<ReminderProvider>().prosesHapusJadwal(
                  idJadwal,
                  idUser,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA4335),
              ),
              child: const Text(
                "Ya, Hapus",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    String idUserAktif = (args != null && args['id'] != null)
        ? args['id'].toString()
        : "1";
    String namaUserAktif = (args != null && args['nama'] != null)
        ? args['nama']
        : "PAB";

    final provider = context.watch<ReminderProvider>();
    final List<dynamic> daftarJadwal = provider.daftarJadwal;
    final daftarJadwalAktif = daftarJadwal
        .where((item) => item['status'] == 'Aktif')
        .toList();

    final Map<String, dynamic>? jadwalAktif = daftarJadwalAktif.isNotEmpty
        ? daftarJadwalAktif[0]
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4285F4)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Spacer(),
                        Image.asset('assets/logo_Pgerd.png', width: 200),
                        const Spacer(),
                        const SizedBox(width: 20),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Hi, $namaUserAktif 👋",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B43A6),
                      ),
                    ),
                    const Text(
                      "Keep your stomach healthy!",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 15),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: AssetImage('assets/layar.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.notifications_active,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Next Reminder",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(51),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: jadwalAktif == null
                                    ? Column(
                                        children: [
                                          const Text(
                                            "Belum ada jadwal mendekati",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: _bukaHalamanReminder,
                                              icon: const Icon(
                                                Icons.add,
                                                color: Color(0xFF4285F4),
                                              ),
                                              label: const Text(
                                                "Tambah Jadwal",
                                                style: TextStyle(
                                                  color: Color(0xFF4285F4),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                shape: const StadiumBorder(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          Text(
                                            jadwalAktif['time'] ?? '07:00',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 42,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "${jadwalAktif['title'] ?? 'Sarapan'} - ${jadwalAktif['reminder_info'] ?? '30 Menit Sebelum Makan'}",
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (daftarJadwal.isNotEmpty && jadwalAktif != null) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            bool sukses = await context
                                .read<ReminderProvider>()
                                .prosesSudahMinumObat(
                                  jadwalAktif['id'].toString(),
                                  idUserAktif,
                                );

                            if (sukses) {
                              try {
                                await http.post(
                                  Uri.parse(
                                    'http://192.168.1.7/pgerd_backend/update_sudah_minum.php',
                                  ),
                                  headers: {"Content-Type": "application/json"},
                                  body: jsonEncode({
                                    "reminder_id": jadwalAktif['id'].toString(),
                                    "user_id": idUserAktif,
                                  }),
                                );

                                // 3. Tampilkan popup sukses
                                if (context.mounted)
                                  _tampilkanPopUpSukses(context);
                                await context
                                    .read<ReminderProvider>()
                                    .ambilDataReminder(idUserAktif);
                              } catch (e) {
                                print("Gagal panggil PHP Notifikasi: $e");
                              }
                            }
                          },
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text(
                            'Sudah Minum',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4285F4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],

                    if (daftarJadwal.isNotEmpty) ...[
                      const Text(
                        "Jadwal Hari Ini",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: daftarJadwalAktif.length,
                        itemBuilder: (context, index) {
                          final item = daftarJadwal[index];

                          return InkWell(
                            onTap: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              );

                              await Future.delayed(const Duration(seconds: 2));

                              if (context.mounted) Navigator.pop(context);

                              if (context.mounted) {
                                Navigator.pushNamed(
                                  context,
                                  '/detail_reminder',
                                  arguments: {
                                    'id': item['id'],
                                    'title': item['title'],
                                    'time': item['time'],
                                    'date_info': item['date_info'],
                                    'reminder_info': item['reminder_info'],
                                    'catatan':
                                        item['catatan'] ?? 'Tidak ada catatan',
                                    'user_id': idUserAktif,
                                  },
                                );
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.wb_sunny_outlined,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        item['title'] ?? 'Sarapan',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        item['date_info'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF4285F4),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item['time'] ?? '07:00',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          // 📝 BUTTON EDIT JADWAL
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/reminder',
                                                arguments: {
                                                  'isEdit': true,
                                                  'id': item['id'],
                                                  'title': item['title'],
                                                  'time': item['time'],
                                                  'date_info':
                                                      item['date_info'],
                                                  'reminder_info':
                                                      item['reminder_info'],
                                                  'catatan': item['catatan'],
                                                  'user_id': idUserAktif,
                                                },
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF4285F4,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: const Text(
                                              "Edit",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // 🗑️ BUTTON HAPUS JADWAL
                                          ElevatedButton(
                                            onPressed: () =>
                                                _tampilkanDialogKonfirmasiHapus(
                                                  context,
                                                  item['id'].toString(),
                                                  idUserAktif,
                                                ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFEA4335,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: const Text(
                                              "Hapus",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    item['reminder_info'] ?? '',
                                    style: const TextStyle(
                                      color: Color(0xFF4285F4),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4285F4),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) _bukaHalamanReminder();
          if (index == 2)
            Navigator.pushNamed(context, '/profile', arguments: args);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: "Reminder",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  void _bukaHalamanReminder() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    Navigator.pushNamed(context, '/reminder', arguments: args);
  }
}
