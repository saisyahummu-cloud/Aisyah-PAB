import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pab_tugas_besar/api_config.dart';

class ReminderProvider extends ChangeNotifier {
  List<dynamic> _daftarJadwal = [];
  bool _isLoading = false;

  List<dynamic> get daftarJadwal => _daftarJadwal;
  bool get isLoading => _isLoading;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  ReminderProvider() {
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await _googleSignIn.initialize();
      await _googleSignIn.attemptLightweightAuthentication();
    } catch (e) {
      debugPrint("Gagal inisialisasi Google Sign In: $e");
    }
  }

  Future<void> simpanStatusLogin(String userId, String nama) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('user_id', userId);

    await prefs.setString('nama_user', nama);
    notifyListeners();
  }

  Future<Map<String, dynamic>?> cekStatusLogin() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      String? userId = prefs.getString('user_id');
      String? nama = prefs.getString('nama_user');

      return {'id': userId, 'nama': nama};
    }
    return null;
  }

  Future<bool> signInWithGoogleObat() async {
    try {
      debugPrint("Membuka popup Google Sign-In v7.x...");
      final googleUser = await _googleSignIn.authenticate();

      final String? idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        debugPrint("Error: ID Token tidak ditemukan.");
        return false;
      }

      try {
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
        debugPrint("Jabat tangan dengan Firebase Console Sukses!");
      } catch (firebaseError) {
        debugPrint("Firebase Auth dilewati/error: $firebaseError");
      }

      String urlAPI = "${ApiConfig.baseUrl}/login_google.php";
      debugPrint("Mencoba kirim ke PHP: $urlAPI");

      final response = await http.post(
        Uri.parse(urlAPI),
        body: {"id_token": idToken},
      );

      debugPrint("Status HTTP: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('user_id', data['user_id'].toString());
        await prefs.setString('nama_user', data['nama'].toString());

        notifyListeners();
        debugPrint("Login Berhasil! Session tersimpan.");
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error login Google PGerd: $e");
      return false;
    }
  }

  Future<void> ambilDataReminder(String idUserAktif) async {
    _isLoading = true;

    Future.microtask(() => notifyListeners());

    String urlAPI = "${ApiConfig.readEndpoint}?user_id=$idUserAktif";
    try {
      final response = await http.get(Uri.parse(urlAPI));
      if (response.statusCode == 200) {
        _daftarJadwal = jsonDecode(response.body);
      } else {
        _daftarJadwal = [];
      }
    } catch (e) {
      _daftarJadwal = [];
    } finally {
      _isLoading = false;

      Future.microtask(() => notifyListeners());
    }
  }

  Future<bool> prosesTambahJadwal(
    Map<String, String> bodyData,
    String idUserAktif,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.createEndpoint),
        body: bodyData,
      );

      debugPrint("Respons Tambah Jadwal: ${response.body}");

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await ambilDataReminder(idUserAktif);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error Tambah Jadwal: $e");
      return false;
    }
  }

  Future<bool> prosesEditJadwal(
    Map<String, String> bodyData,
    String idUserAktif,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.editEndpoint),
        body: bodyData,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await ambilDataReminder(idUserAktif);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> prosesHapusJadwal(String idJadwal, String idUserAktif) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.deleteEndpoint),
        body: {"id": idJadwal},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await ambilDataReminder(idUserAktif);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> prosesSudahMinumObat(String idJadwal, String idUserAktif) async {
    debugPrint("DEBUG: Tombol sudah minum ditekan untuk jadwal ID: $idJadwal");
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.7/pgerd_backend/update_sudah_minum.php'),
        body: {"id": idJadwal, "user_id": idUserAktif},
      );

      debugPrint("Respons Update Minum: ${response.body}");

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await ambilDataReminder(idUserAktif); // Refresh data
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error Update: $e");
      return false;
    }
  }
}
