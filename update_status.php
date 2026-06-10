<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$koneksi = new mysqli('localhost', 'root', '', 'db_pgerd');

if ($koneksi->connect_error) {
    echo json_encode(["success" => false, "message" => "Gagal koneksi database"]);
    exit();
}

// Tangkap id dari jadwal reminder yang mau diubah statusnya
$id = isset($_POST['id']) ? mysqli_real_escape_string($koneksi, $_POST['id']) : '';

if (empty($id)) {
    echo json_encode(["success" => false, "message" => "ID jadwal tidak ditemukan!"]);
    exit();
}

// Update status menjadi 'Selesai' agar tidak muncul lagi di dashboard
$query = "UPDATE reminders SET status = 'Selesai' WHERE id = '$id'";
$eksekusi = mysqli_query($koneksi, $query);

if ($eksekusi) {
    echo json_encode(["success" => true, "message" => "Status berhasil diperbarui!"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal memperbarui status"]);
}
?>