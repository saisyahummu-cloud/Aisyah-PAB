<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$koneksi = new mysqli('localhost', 'root', '', 'db_pgerd');

$nama = isset($_POST['nama']) ? $_POST['nama'] : '';
$email = isset($_POST['email']) ? $_POST['email'] : '';
$password = isset($_POST['password']) ? $_POST['password'] : '';

if (empty($nama) || empty($email) || empty($password)) {
    echo json_encode(["success" => false, "message" => "Data tidak boleh kosong"]);
    exit();
}

// Menyimpan password secara polos tanpa MD5 agar sinkron
$query = mysqli_query($koneksi, "INSERT INTO users (nama, email, password) VALUES ('$nama', '$email', '$password')");

if ($query) {
    echo json_encode(["success" => true, "message" => "Akun berhasil didaftarkan!"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal menyimpan: " . mysqli_error($koneksi)]);
}
?>