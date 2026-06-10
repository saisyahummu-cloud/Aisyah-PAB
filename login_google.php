<?php
header("Content-Type: application/json");

// 1. Konfigurasi koneksi ke MySQL Laragon kamu
$host = "localhost";
$user = "root"; 
$pass = ""; // kosongkan atau sesuaikan jika database kamu ada password-nya
$db   = "db_pgerd"; // Nama database kamu sudah benar db_pgerd

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Koneksi database gagal!"]);
    exit;
}

// 2. Terima token yang dikirim dari Flutter PGerd kamu
$idToken = $_POST["id_token"] ?? "";
if (empty($idToken)) {
    echo json_encode(["status" => "error", "message" => "Token kosong!"]);
    exit;
}

// 3. Verifikasi token langsung ke server resmi Google API (Sesuai Modul Hal 13)
$url = "https://oauth2.googleapis.com/tokeninfo?id_token=" . $idToken;
$context = stream_context_create(["http" => ["ignore_errors" => true]]);
$response = file_get_contents($url, false, $context);
$userData = json_decode($response, true);

// Jika Tokennya palsu atau kadaluarsa
if (isset($userData["error"])) {
    echo json_encode(["status" => "error", "message" => "Token tidak valid!"]);
} else {
    // 4. Jika Token asli, ambil data email dan nama dari Google
    $email = $conn->real_escape_string($userData["email"]);
    $nama  = $conn->real_escape_string($userData["name"]);

    // 5. Cek apakah user ini sudah pernah login/daftar sebelumnya
    $cekUser = $conn->query("SELECT id FROM users WHERE email = '$email'");

    if ($cekUser->num_rows == 0) {
        // 🎯 REVISI DI SINI: Kita tambahkan kolom password dan diisi nilai string kosong '' 
        // Biar MySQL Laragon kamu tidak protes lagi karena kolom password wajib diisi!
        $insert = $conn->query("INSERT INTO users (nama, email, password) VALUES ('$nama', '$email', '')");
        
        // Ambil ID yang baru saja digenerate oleh MySQL
        $new_id = $conn->insert_id;
        
        echo json_encode([
            "status" => "success",
            "message" => "Akun baru berhasil didaftarkan via Google!",
            "user_id" => $new_id,
            "nama" => $nama
        ]);
    } else {
        // Jika sudah ada, langsung ambil ID-nya untuk dilempar ke Dashboard
        $userRow = $cekUser->fetch_assoc();
        
        echo json_encode([
            "status" => "success",
            "message" => "Selamat datang kembali!",
            "user_id" => $userRow["id"],
            "nama" => $nama
        ]);
    }
}
$conn->close();
?>