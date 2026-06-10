<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// 1. Koneksi ke database
$koneksi = new mysqli('localhost', 'root', '', 'db_pgerd');

if ($koneksi->connect_error) {
    echo json_encode(["success" => false, "message" => "Gagal koneksi database"]);
    exit();
}

// 2. Tangkap semua data POST dari Flutter secara dinamis
$user_id       = isset($_POST['user_id']) ? mysqli_real_escape_string($koneksi, $_POST['user_id']) : '';
$title         = isset($_POST['title']) ? mysqli_real_escape_string($koneksi, $_POST['title']) : '';
$time          = isset($_POST['time']) ? mysqli_real_escape_string($koneksi, $_POST['time']) : '';
$date_info     = isset($_POST['date_info']) ? mysqli_real_escape_string($koneksi, $_POST['date_info']) : '';
$reminder_info = isset($_POST['reminder_info']) ? mysqli_real_escape_string($koneksi, $_POST['reminder_info']) : '';
$catatan       = isset($_POST['catatan']) ? mysqli_real_escape_string($koneksi, $_POST['catatan']) : '-';
$status        = isset($_POST['status']) ? mysqli_real_escape_string($koneksi, $_POST['status']) : 'Aktif';

// Validasi jika user_id atau data penting lainnya kosong
if (empty($user_id) || empty($title) || empty($time)) {
    echo json_encode(["success" => false, "message" => "Data input tidak lengkap!"]);
    exit();
}

// 3. Query SQL dinamis menggunakan $user_id asli milik user yang sedang input!
$queryStr = "INSERT INTO reminders (user_id, title, time, date_info, reminder_info, catatan, status) 
             VALUES ('$user_id', '$title', '$time', '$date_info', '$reminder_info', '$catatan', '$status')";

$eksekusi = mysqli_query($koneksi, $queryStr);

if ($eksekusi) {
    echo json_encode([
        "success" => true,
        "message" => "Jadwal pengingat berhasil ditambahkan!"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Gagal menambahkan jadwal: " . mysqli_error($koneksi)
    ]);
}
?>