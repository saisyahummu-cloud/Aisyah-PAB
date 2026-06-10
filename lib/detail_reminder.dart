import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pab_tugas_besar/api_config.dart';

class DetailReminderPage extends StatefulWidget {
  const DetailReminderPage({super.key});

  @override
  State<DetailReminderPage> createState() => _DetailReminderPageState();
}

class _DetailReminderPageState extends State<DetailReminderPage> {
  static const Color primaryBlue = Color(0xFF4285F4);
  static const Color lightGreyBg = Color(0xFFF8FAFC);
  static const Color darkBlueText = Color(0xFF1E3A8A);

  bool _isInitialized = false;

  String _currentStatus = "Belum Minum";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final Map<String, dynamic>? dataJadwal =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      bool isDrunkFromDashboard = dataJadwal?['isDrunk'] ?? false;
      _currentStatus = isDrunkFromDashboard ? "Sudah Minum" : "Belum Minum";
      _isInitialized = true;
    }
  }

  Future<void> _prosesHapusJadwalDariDetail(String idJadwal) async {
    String urlAPI = ApiConfig.deleteEndpoint;
    try {
      final response = await http.post(
        Uri.parse(urlAPI),
        body: {"id": idJadwal},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Jadwal berhasil dihapus!'),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(data['message'] ?? 'Gagal menghapus'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Kendala Koneksi: $e"),
        ),
      );
    }
  }

  void _tampilkanDialogKonfirmasiHapusDetail(
    BuildContext context,
    String idJadwal,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: const [
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
            "Apakah kamu yakin ingin menghapus jadwal ini? Tindakan ini akan menghilangkan pengingat dari halaman utama.",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext), // Tutup dialog jika Batal
              child: const Text(
                "Batal",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Tutup dialog konfirmasi
                _prosesHapusJadwalDariDetail(
                  idJadwal,
                ); // Jalankan fungsi delete bawaanmu ke Laragon
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA4335),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
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
    final Map<String, dynamic>? dataJadwal =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // 🔄 REVISI SAKTI: Menyamakan nama key sesuai dengan yang dikirim dari dashboard.dart
    final String title = dataJadwal?['title'] ?? "Sarapan";
    final String time = dataJadwal?['time'] ?? "07.00";
    final String dateInfo =
        dataJadwal?['date_info'] ?? dataJadwal?['dateInfo'] ?? "1 Jun 2026";
    final String reminderInfo =
        dataJadwal?['reminder_info'] ??
        dataJadwal?['reminderInfo'] ??
        "Reminder: 30 menit sebelum makan";
    final IconData icon = dataJadwal?['icon'] ?? Icons.wb_sunny_outlined;
    final Color iconColor = dataJadwal?['iconColor'] ?? Colors.orange;
    final String catatan = dataJadwal?['catatan'] ?? "-";

    Color statusBgColor;
    Color statusTextColor;
    IconData statusIcon;
    String statusSubtext;

    if (_currentStatus == "Sudah Minum") {
      statusBgColor = const Color(0xFFE8F5E9); // Hijau soft
      statusTextColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusSubtext = "Tepat waktu • Hari ini";
    } else if (_currentStatus == "Terlewat") {
      statusBgColor = const Color(0xFFFEF2F2); // Merah soft
      statusTextColor = Colors.red;
      statusIcon = Icons.cancel;
      statusSubtext = "Jadwal obat terlewat/bocor";
    } else {
      statusBgColor = const Color(0xFFFFF3E0); // Kuning/Orange soft
      statusTextColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
      statusSubtext = "Menunggu jam minum obat";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primaryBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Jadwal",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: lightGreyBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: .1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: iconColor, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: darkBlueText,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _currentStatus == "Sudah Minum"
                                      ? "• Selesai"
                                      : "• Aktif",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _currentStatus == "Sudah Minum"
                                        ? Colors.green
                                        : primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Waktu",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: darkBlueText,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Pengingat",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            reminderInfo.replaceAll("Reminder: ", ""),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: darkBlueText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Informasi Jadwal",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightGreyBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildInfoTile(
                            Icons.calendar_today_outlined,
                            "Tanggal",
                            dateInfo,
                          ),
                          const Divider(height: 24),
                          _buildInfoTile(
                            Icons.refresh,
                            "Pengulangan",
                            "Setiap hari",
                          ),
                          const Divider(height: 24),
                          _buildInfoTile(
                            Icons.notifications_none_outlined,
                            "Waktu Pengingat",
                            reminderInfo.replaceAll("Reminder: ", ""),
                          ),
                          const Divider(height: 24),
                          _buildInfoTile(
                            Icons.edit_note,
                            "Catatan (Opsional)",
                            catatan,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Status Hari Ini",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    PopupMenuButton<String>(
                      onSelected: (String statusBaru) {
                        setState(() {
                          _currentStatus = statusBaru;
                        });
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: "Belum Minum",
                          child: ListTile(
                            leading: Icon(
                              Icons.hourglass_empty,
                              color: Colors.orange,
                            ),
                            title: Text("Belum Minum"),
                          ),
                        ),
                        const PopupMenuItem(
                          value: "Sudah Minum",
                          child: ListTile(
                            leading: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            title: Text("Sudah Minum"),
                          ),
                        ),
                        const PopupMenuItem(
                          value: "Terlewat",
                          child: ListTile(
                            leading: Icon(Icons.cancel, color: Colors.red),
                            title: Text("Terlewat"),
                          ),
                        ),
                      ],
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(statusIcon, color: statusTextColor, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentStatus == "Sudah Minum"
                                        ? "Sudah Minum"
                                        : (_currentStatus == "Terlewat"
                                              ? "Terlewat"
                                              : "Belum Minum"),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: statusTextColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    statusSubtext,
                                    style: TextStyle(
                                      color: statusTextColor.withValues(
                                        alpha: .8,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              size: 20,
                              color: statusTextColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),

            // --- BOTTOM BUTTONS FIXED CRUDS ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final Map<String, dynamic>? dataAsli =
                              ModalRoute.of(context)?.settings.arguments
                                  as Map<String, dynamic>?;

                          Navigator.pushNamed(
                            context,
                            '/reminder',
                            arguments: {
                              'isEdit': true,
                              'id': dataAsli?['id'],
                              'title': title,
                              'time': time,
                              'date_info': dataAsli?['date_info'] ?? dateInfo,
                              'reminder_info':
                                  dataAsli?['reminder_info'] ??
                                  dataAsli?['reminderInfo'] ??
                                  reminderInfo,
                              'catatan': catatan,
                              'user_id': dataAsli?['user_id'],
                            },
                          ).then((value) {
                            if (value == true) {
                              Navigator.pop(context, true);
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.edit,
                          size: 18,
                          color: primaryBlue,
                        ),
                        label: const Text(
                          "Edit Jadwal",
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEFF6FF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final Map<String, dynamic>? dataAsli =
                              ModalRoute.of(context)?.settings.arguments
                                  as Map<String, dynamic>?;

                          if (dataAsli != null && dataAsli['id'] != null) {
                            _tampilkanDialogKonfirmasiHapusDetail(
                              context,
                              dataAsli['id'].toString(),
                            );
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Hapus Jadwal",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA4335),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade400, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
