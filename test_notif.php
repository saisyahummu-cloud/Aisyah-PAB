<?php
require 'fcm_helper.php';

// Masukkan token HP Realme kamu di sini (hasil debugPrint dari VS Code)
$token_test = "MASUKKAN_TOKEN_DI_SINI"; 

$hasil = sendFcmNotification($token_test, "Tes Notifikasi", "Ini pesan percobaan dari PHP!");

if ($hasil) {
    echo "Sukses! Notifikasi terkirim.";
} else {
    echo "Gagal kirim notifikasi. Cek kredensial/token.";
}
?>