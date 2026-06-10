<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// 1. Koneksi ke database db_pgerd
$koneksi = new mysqli('localhost', 'root', '', 'db_pgerd');

if ($koneksi->connect_error) {
    echo json_encode(["success" => false, "message" => "Gagal koneksi database"]);
    exit();
}

// 2. Tangkap parameter user_id yang dikirim secara dinamis oleh Flutter
$user_id = isset($_GET['user_id']) ? mysqli_real_escape_string($koneksi, $_GET['user_id']) : '';

if (empty($user_id)) {
    echo json_encode(["success" => false, "message" => "Parameter user_id tidak ditemukan!"]);
    exit();
}

// 3. Query SQL WAJIB menyaring berdasarkan user_id agar jadwal tersekat sempurna dan tidak bocor antar-user!
$query = mysqli_query($koneksi, "SELECT * FROM reminders WHERE user_id = '$user_id' AND status = 'Aktif' ORDER BY time ASC");
$data  = mysqli_fetch_all($query, MYSQLI_ASSOC);

// 4. Kembalikan data dalam bentuk JSON ke Flutter
echo json_encode($data);
?>