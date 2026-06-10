import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pab_tugas_besar/reminder_provider.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final int _currentIndex = 1;
  bool _isLoading = false;

  String _selectedWaktuMakan = "Sarapan";

  final String _timeSarapan = "07:00";
  final String _timeMakanSiang = "12:00";
  final String _timeMakanMalam = "18:00";

  String _selectedReminderInfo = "30 Menit Sebelum Makan";

  late DateTime _currentCalendarDate;
  late int _selectedDay;

  bool _isInitialized = false;
  final TextEditingController _catatanController = TextEditingController();

  final List<String> _months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mei",
    "Jun",
    "Jul",
    "Agu",
    "Sep",
    "Okt",
    "Nov",
    "Des",
  ];

  @override
  void initState() {
    super.initState();
    _currentCalendarDate = DateTime.now();
    _selectedDay = _currentCalendarDate.day;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args['isEdit'] == true) {
        setState(() {
          if (args['title'] != null) {
            _selectedWaktuMakan = args['title'].toString();
          }
          if (args['catatan'] != null && args['catatan'] != "-") {
            _catatanController.text = args['catatan'];
          }
          if (args['reminder_info'] != null) {
            _selectedReminderInfo = args['reminder_info'].toString();
          }
        });
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int _getWeekdayOfFirstDay(int year, int month) {
    return DateTime(year, month, 1).weekday % 7;
  }

  void _tampilkanPilihanReminder() {
    final List<String> daftarOpsi = [
      "15 Menit Sebelum Makan",
      "30 Menit Sebelum Makan",
      "1 Jam Sebelum Makan",
      "Bersamaan Dengan Makan",
      "30 Menit Sesudah Makan",
      "1 Jam Sesudah Makan",
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Tentukan Waktu Pengingat",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B43A6),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 0.5),

              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: daftarOpsi.length,
                  itemBuilder: (context, index) {
                    String opsi = daftarOpsi[index];
                    bool isMilikIni = opsi == _selectedReminderInfo;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      leading: Icon(
                        Icons.access_time,
                        color: isMilikIni
                            ? const Color(0xFF4285F4)
                            : const Color(0xFF1E3A8A),
                      ),
                      title: Text(
                        opsi,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isMilikIni
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isMilikIni
                              ? const Color(0xFF4285F4)
                              : const Color(0xFF1E3A8A),
                        ),
                      ),
                      trailing: isMilikIni
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFF4285F4),
                            )
                          : const Icon(
                              Icons.circle_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                      onTap: () {
                        setState(() {
                          _selectedReminderInfo = opsi;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _prosesSimpanReminder() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    bool isEditMode = args != null && args['isEdit'] == true;
    String idUserAktif = (args != null && args['user_id'] != null)
        ? args['user_id'].toString()
        : ((args != null && args['id'] != null) ? args['id'].toString() : "1");

    String time = "";
    if (_selectedWaktuMakan == "Sarapan") time = _timeSarapan;
    if (_selectedWaktuMakan == "Makan Siang") time = _timeMakanSiang;
    if (_selectedWaktuMakan == "Makan Malam") time = _timeMakanMalam;

    setState(() {
      _isLoading = true;
    });

    String teksCatatan = _catatanController.text.trim();
    if (teksCatatan.isEmpty) teksCatatan = "-";

    String namaBulan = _months[_currentCalendarDate.month - 1];
    String tahun = _currentCalendarDate.year.toString();

    Map<String, String> bodyData = {
      "user_id": idUserAktif,
      "title": _selectedWaktuMakan,
      "time": time,
      "date_info": "$_selectedDay $namaBulan $tahun",
      "reminder_info": _selectedReminderInfo,
      "catatan": _catatanController.text,
    };

    if (isEditMode) {
      bodyData["id"] = args['id'].toString();
    } else {
      bodyData["user_id"] = idUserAktif;
      bodyData["status"] = "Aktif";
    }

    try {
      bool sukses = false;
      if (isEditMode) {
        sukses = await context.read<ReminderProvider>().prosesEditJadwal(
          bodyData,
          idUserAktif,
        );
      } else {
        sukses = await context.read<ReminderProvider>().prosesTambahJadwal(
          bodyData,
          idUserAktif,
        );
      }

      if (sukses) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil menyimpan jadwal! 📝')),
        );

        if (!isEditMode && args != null && args.containsKey('nama')) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
            arguments: args,
          );
        } else {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Gagal memproses data database'),
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
    const Color primaryBlue = Color(0xFF4285F4);

    int daysInMonth = _getDaysInMonth(
      _currentCalendarDate.year,
      _currentCalendarDate.month,
    );
    int emptyCellsBefore = _getWeekdayOfFirstDay(
      _currentCalendarDate.year,
      _currentCalendarDate.month,
    );
    int totalGridItems = daysInMonth + emptyCellsBefore;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  ModalRoute.of(context)?.settings.arguments != null &&
                          (ModalRoute.of(context)!.settings.arguments
                                  as Map)['isEdit'] ==
                              true
                      ? 'Edit Jadwal'
                      : 'Tambah Jadwal',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B43A6),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _currentCalendarDate = DateTime(
                                _currentCalendarDate.year,
                                _currentCalendarDate.month - 1,
                              );
                              _selectedDay = 1;
                            });
                          },
                        ),
                        Row(
                          children: [
                            _buildDropdownContainer(
                              _months[_currentCalendarDate.month - 1],
                            ),
                            const SizedBox(width: 8),
                            _buildDropdownContainer(
                              _currentCalendarDate.year.toString(),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _currentCalendarDate = DateTime(
                                _currentCalendarDate.year,
                                _currentCalendarDate.month + 1,
                              );
                              _selectedDay = 1;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Text(
                          "Su",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        Text(
                          "Mo",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        Text(
                          "Tu",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        Text(
                          "We",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        Text(
                          "Th",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        Text(
                          "Fr",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        Text(
                          "Sa",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                    const Divider(height: 15, thickness: 0.5),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: totalGridItems,
                      itemBuilder: (context, index) {
                        if (index < emptyCellsBefore) {
                          return const SizedBox();
                        }

                        int dayNumber = index - emptyCellsBefore + 1;
                        bool isSelected = dayNumber == _selectedDay;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedDay = dayNumber),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2B6CB0)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "$dayNumber",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Pilih Waktu Makan (Pilih Salah Satu)"),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildTimeRow(
                      "Sarapan",
                      _timeSarapan,
                      _selectedWaktuMakan == "Sarapan",
                      (val) {
                        if (val == true)
                          setState(() => _selectedWaktuMakan = "Sarapan");
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildTimeRow(
                      "Makan Siang",
                      _timeMakanSiang,
                      _selectedWaktuMakan == "Makan Siang",
                      (val) {
                        if (val == true)
                          setState(() => _selectedWaktuMakan = "Makan Siang");
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildTimeRow(
                      "Makan Malam",
                      _timeMakanMalam,
                      _selectedWaktuMakan == "Makan Malam",
                      (val) {
                        if (val == true)
                          setState(() => _selectedWaktuMakan = "Makan Malam");
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildSectionTitle("Reminder:"),
              GestureDetector(
                onTap: _tampilkanPilihanReminder,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4285F4).withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFF1E3A8A),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedReminderInfo,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF1E3A8A),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildSectionTitle("Catatan Tambahan (Opsional):"),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _catatanController,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E3A8A),
                  ),
                  decoration: const InputDecoration(
                    hintText: "Contoh: Minum pakai air hangat / Obat Kunyah",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.edit_note,
                      color: Color(0xFF1E3A8A),
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _prosesSimpanReminder,
                  icon: _isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.check, color: Colors.white),
                  label: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan',
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
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
              arguments: args,
            );
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profile', arguments: args);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
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

  Widget _buildDropdownContainer(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow(
    String title,
    String time,
    bool isChecked,
    ValueChanged<bool?>? onChanged,
  ) {
    return CheckboxListTile(
      value: isChecked,
      onChanged: onChanged,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E3A8A),
          fontSize: 14,
        ),
      ),
      secondary: Text(
        time,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E3A8A),
        ),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: const Color(0xFF1E3A8A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}
