<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$koneksi = new mysqli('localhost', 'root', '', 'db_pgerd');

if ($koneksi->connect_error) {
    echo json_encode(["success" => false, "message" => "Gagal koneksi database"]);
    exit();
}

$id            = isset($_POST['id']) ? mysqli_real_escape_string($koneksi, $_POST['id']) : '';
$title         = isset($_POST['title']) ? mysqli_real_escape_string($koneksi, $_POST['title']) : '';
$time          = isset($_POST['time']) ? mysqli_real_escape_string($koneksi, $_POST['time']) : '';
$date_info     = isset($_POST['date_info']) ? mysqli_real_escape_string($koneksi, $_POST['date_info']) : '';
$reminder_info = isset($_POST['reminder_info']) ? mysqli_real_escape_string($koneksi, $_POST['reminder_info']) : ''; 
$catatan       = isset($_POST['catatan']) ? mysqli_real_escape_string($koneksi, $_POST['catatan']) : '';

if (empty($id) || empty($title) || empty($time)) {
    echo json_encode(["success" => false, "message" => "Data editan tidak lengkap!"]);
    exit();
}

// 🚀 REVISI SAKTI: Ubah status menjadi 'Aktif' biar lolos filter query dashboard!
$query = "UPDATE reminders SET 
            title='$title', 
            time='$time', 
            date_info='$date_info', 
            reminder_info='$reminder_info', 
            catatan='$catatan',
            status='Aktif' 
          WHERE id='$id'";

$eksekusi = mysqli_query($koneksi, $query);

if ($eksekusi) {
    echo json_encode(["success" => true, "message" => "Jadwal berhasil diperbarui! 📝"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal: " . mysqli_error($koneksi)]);
}
?>