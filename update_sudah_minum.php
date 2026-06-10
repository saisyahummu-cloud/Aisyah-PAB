<?php
header("Content-Type: application/json");
$conn = new mysqli("localhost", "root", "", "db_pgerd");

// Menangkap data dari Flutter (sesuaikan key dengan yang dikirim di Provider)
$reminderId = $_POST["id"] ?? ""; 
$userId     = $_POST["user_id"] ?? "";

// DEBUG: Kirim balik data untuk memastikan PHP menerima input
if (empty($reminderId) || empty($userId)) {
    echo json_encode(["success" => false, "message" => "ID atau User ID kosong", "received_id" => $reminderId]);
    exit;
}

// 1. Update status
$query = $conn->prepare("UPDATE reminders SET status = 'Selesai' WHERE id = ? AND user_id = ?");
$query->bind_param("ss", $reminderId, $userId);
$execute = $query->execute();

if (!$execute) {
    echo json_encode(["success" => false, "message" => "Gagal update database"]);
    exit;
}

// 2. Ambil token
$getToken = $conn->prepare("SELECT token FROM fcm_tokens WHERE id_user = ? ORDER BY id DESC LIMIT 1");
$getToken->bind_param("s", $userId);
$getToken->execute();
$result = $getToken->get_result();

if ($result->num_rows > 0) {
    $token_data = $result->fetch_assoc();
    $token_fcm = $token_data['token'];

    include 'fcm_helper.php';
    
    // Coba kirim notifikasi
    $notifStatus = sendFcmNotification($token_fcm, "Pengingat Minum", "Yeeay, Awesome! Kamu sudah minum obat!");
    
    echo json_encode([
        "success" => true, 
        "message" => "Status update", 
        "notif_status" => $notifStatus ? "Terkirim" : "Gagal Kirim"
    ]);
} else {
    echo json_encode(["success" => true, "message" => "Status update, token tidak ditemukan di DB"]);
}
?>