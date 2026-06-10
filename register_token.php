<?php
$conn = new mysqli("localhost", "root", "", "db_pgerd");

// Tambahkan ini di paling atas file register_token.php
$data = json_decode(file_get_contents("php://input"), true);
$id_user = $data['id_user'];
$token = $data['token'];

// Pastikan query SQL-mu menggunakan variabel $id_user dan $token tersebut

// Tambahkan pengecekan ini agar lebih aman
$id_user = isset($data['id_user']) ? $data['id_user'] : (isset($data['user_id']) ? $data['user_id'] : null);
$token = isset($data['token']) ? $data['token'] : (isset($data['fcm_token']) ? $data['fcm_token'] : null);

if ($id_user && $token) {
    $id_user = $conn->real_escape_string($id_user);
    $token = $conn->real_escape_string($token);

    $sql = "REPLACE INTO fcm_tokens (id_user, token) VALUES ('$id_user', '$token')";
    
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Data tidak lengkap. Terima: " . json_encode($data)]);
}
?>