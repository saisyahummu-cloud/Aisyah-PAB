<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// 1. Koneksi ke database
$koneksi = new mysqli('localhost', 'root', '', 'db_pgerd');

if ($koneksi->connect_error) {
    echo json_encode(["success" => false, "message" => "Gagal koneksi database"]);
    exit();
}

// 2. Tangkap input dari Flutter
$email    = isset($_POST['email']) ? mysqli_real_escape_string($koneksi, $_POST['email']) : '';
$password = isset($_POST['password']) ? mysqli_real_escape_string($koneksi, $_POST['password']) : '';

if (empty($email) || empty($password)) {
    echo json_encode(["success" => false, "message" => "Email dan password tidak boleh kosong!"]);
    exit();
}

// 3. Cari user di database
$query = mysqli_query($koneksi, "SELECT * FROM users WHERE email = '$email' AND password = '$password'");
$user  = mysqli_fetch_assoc($query);

if ($user) {
    
    echo json_encode([
        "success" => true,
        "message" => "Login Berhasil! Selamat Datang " . $user['nama'],
        "user" => [
            "id"    => $user['id'],
            "nama"  => $user['nama'],
            "email" => $user['email'] // Baris ini yang wajib ada biar Flutter bisa baca!
        ]
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Email atau Password salah, Syah!"
    ]);
}
?>