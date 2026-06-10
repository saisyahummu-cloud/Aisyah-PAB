<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$koneksi = new mysqli('localhost', 'root', '', 'db_pgerd');

if ($koneksi->connect_error) {
    echo json_encode(["success" => false, "message" => "Gagal koneksi database"]);
    exit();
}

// Tangkap ID jadwal yang mau dihapus
$id = isset($_POST['id']) ? mysqli_real_escape_string($koneksi, $_POST['id']) : '';

if (empty($id)) {
    echo json_encode(["success" => false, "message" => "ID jadwal kosong!"]);
    exit();
}

// Eksekusi hapus permanen dari MySQL
$query = "DELETE FROM reminders WHERE id = '$id'";
$eksekusi = mysqli_query($koneksi, $query);

if ($eksekusi) {
    echo json_encode(["success" => true, "message" => "Jadwal berhasil dihapus! 🗑️"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal menghapus data"]);
}
?>