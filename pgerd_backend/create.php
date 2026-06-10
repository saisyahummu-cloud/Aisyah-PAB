<?php
$koneksi = new mysqli('localhost', 'root', '', 'db_pgerd');

// Tangkap data yang dikirim dari form Flutter
$title = mysqli_real_escape_string($koneksi, $_POST['title']);
$time = mysqli_real_escape_string($koneksi, $_POST['time']);
$date_info = mysqli_real_escape_string($koneksi, $_POST['date_info']);
$reminder_info = mysqli_real_escape_string($koneksi, $_POST['reminder_info']);
$catatan = isset($_POST['catatan']) ? mysqli_real_escape_string($koneksi, $_POST['catatan']) : '-';

// Jalankan query simpan data ke tabel reminders
$data = mysqli_query($koneksi, "INSERT INTO reminders (user_id, title, time, date_info, reminder_info, catatan, status) 
VALUES ('1', '$title', '$time', '$date_info', '$reminder_info', '$catatan', 'Belum Minum')");

if ($data) {
    echo json_encode([
        "success" => true,
        "message" => "Jadwal obat berhasil ditambahkan"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Jadwal gagal ditambahkan: " . mysqli_error($koneksi)
    ]);
}
?>