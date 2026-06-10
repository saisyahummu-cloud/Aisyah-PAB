import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pab_tugas_besar/api_config.dart';
import 'reminder_provider.dart';

class PengingatSayaPage extends StatefulWidget {
  const PengingatSayaPage({super.key});

  @override
  State<PengingatSayaPage> createState() => _PengingatSayaPageState();
}

class _PengingatSayaPageState extends State<PengingatSayaPage> {
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('user_id') ?? '';
    setState(() {
      _userId = savedUserId;
    });

    if (savedUserId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ReminderProvider>(
          context,
          listen: false,
        ).ambilDataReminder(savedUserId);
      });
    }
  }

  Future<void> prosesSudahMinum(String reminderId) async {
    if (_userId.isEmpty) return;

    try {
      String urlAPI = ApiConfig.updateSudahMinumEndpoint;

      final response = await http.post(
        Uri.parse(urlAPI),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"reminder_id": reminderId, "user_id": _userId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Status diperbarui! Notifikasi apresiasi meluncur 🚀",
              ),
            ),
          );
        }

        if (mounted) {
          await Provider.of<ReminderProvider>(
            context,
            listen: false,
          ).ambilDataReminder(_userId);
        }
      } else {
        debugPrint("Gagal memproses tombol: ${response.body}");
      }
    } catch (e) {
      debugPrint("Eror koneksi tombol ke Laragon: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF4285F4);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<ReminderProvider>(
          builder: (context, reminderProvider, child) {
            return SingleChildScrollView(
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
                  const SizedBox(height: 25),

                  const Text(
                    "Pengingat Saya",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (reminderProvider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30.0),
                        child: CircularProgressIndicator(color: primaryBlue),
                      ),
                    )
                  else if (reminderProvider.daftarJadwal.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Text(
                          "Belum ada jadwal obat hari ini.",
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reminderProvider.daftarJadwal.length,
                      itemBuilder: (context, index) {
                        final jadwal = reminderProvider.daftarJadwal[index];
                        bool isSelesai =
                            (jadwal['status_minum'] == 'Selesai' ||
                            jadwal['status'] == 'Selesai');

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: _buildJadwalCard(
                            context,
                            reminderId: jadwal['id'].toString(),
                            icon: Icons.medication_liquid_outlined,
                            iconColor: isSelesai ? Colors.teal : Colors.blue,
                            title:
                                jadwal['nama_obat'] ??
                                (jadwal['title'] ?? 'Nama Obat'),
                            time: jadwal['jam'] ?? (jadwal['time'] ?? '00.00'),
                            dateInfo: isSelesai
                                ? "Status: Selesai ✅"
                                : "Belum Diminum ⏰",
                            reminderInfo:
                                "Keterangan: ${jadwal['keterangan'] ?? 'Reminder aktif'}",
                            isSelesai: isSelesai,
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/reminder');
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Tambah Jadwal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildJadwalCard(
    BuildContext context, {
    required String reminderId,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
    required String dateInfo,
    required String reminderInfo,
    bool isSelesai = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelesai ? const Color(0xFFE8F5E9) : const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: .1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelesai
                      ? Colors.green.withValues(alpha: .1)
                      : Colors.blue.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  dateInfo,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelesai ? Colors.green : const Color(0xFF4285F4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: isSelesai
                        ? null
                        : () => prosesSudahMinum(reminderId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelesai ? Colors.grey : Colors.teal,
                      minimumSize: const Size(80, 30),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isSelesai ? "Sudahan" : "Sudah Minum",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      minimumSize: const Size(50, 30),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Edit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA4335),
                      minimumSize: const Size(55, 30),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Hapus",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reminderInfo,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4285F4),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
