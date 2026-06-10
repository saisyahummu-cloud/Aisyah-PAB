<?php
// 1. Koneksi database
$conn = new mysqli("localhost", "root", "", "db_pgerd");

// Cek apakah koneksi berhasil
if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Koneksi database gagal"]);
    exit;
}

// 2. Tangkap data dari Flutter (Gunakan default kosong jika tidak ada)
$user_id = $_POST['user_id'] ?? "";
$title   = $_POST['title'] ?? "";
$time    = $_POST['time'] ?? "";
$date_info     = $_POST['date_info'] ?? "";
$reminder_info = $_POST['reminder_info'] ?? "";
$catatan       = $_POST['catatan'] ?? "";
$status        = "Aktif"; 

// 3. CEK DATA KOSONG
if (empty($user_id) || empty($title) || empty($time)) {
    echo json_encode(["success" => false, "message" => "Data wajib tidak lengkap!"]);
    exit;
}

// 4. GUNAKAN PREPARED STATEMENT (INI SOLUSI AMAN DARI ERROR SQL)
$stmt = $conn->prepare("INSERT INTO reminders (user_id, title, time, date_info, reminder_info, catatan, status) VALUES (?, ?, ?, ?, ?, ?, ?)");
$stmt->bind_param("sssssss", $user_id, $title, $time, $date_info, $reminder_info, $catatan, $status);

// 5. Eksekusi
if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Data berhasil masuk!"]);
} else {
    echo json_encode(["success" => false, "message" => "Error Query: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>