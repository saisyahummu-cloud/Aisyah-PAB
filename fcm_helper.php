<?php
function sendFcmNotification($deviceToken, $title, $body) {
    // 1. TENTUKAN PATH-NYA DI PALING ATAS
    $serviceAccountPath = __DIR__ . '/config/service-account.json'; 

    // 2. CEK APAKAH FILE ADA
    if (!file_exists($serviceAccountPath)) {
        error_log("FILE JSON TIDAK DITEMUKAN DI: " . $serviceAccountPath);
        return false; 
    }
    
    // 3. LOAD DATA JSON
    $serviceAccount = json_decode(file_get_contents($serviceAccountPath), true);
    if (!$serviceAccount) {
        error_log("Gagal decode JSON service account");
        return false;
    }

    // 4. Buat JWT untuk mendapatkan Access Token
    $header = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
    $now = time();
    $payload = base64_encode(json_encode([
        'iss' => $serviceAccount['client_email'],
        'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
        'aud' => 'https://oauth2.googleapis.com/token',
        'exp' => $now + 3600,
        'iat' => $now
    ]));

    $signature = '';
    openssl_sign("$header.$payload", $signature, $serviceAccount['private_key'], 'SHA256');
    $jwt = "$header.$payload." . base64_encode($signature);

    // 5. Ambil Access Token
    $ch = curl_init('https://oauth2.googleapis.com/token');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
        'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion' => $jwt
    ]));
    $response = json_decode(curl_exec($ch), true);
    curl_close($ch);

    $accessToken = $response['access_token'] ?? null;
    if (!$accessToken) {
        error_log("Gagal mendapatkan Access Token: " . json_encode($response));
        return false;
    }

    // 6. Kirim Notifikasi ke FCM V1
    $url = "https://fcm.googleapis.com/v1/projects/" . $serviceAccount['project_id'] . "/messages:send";
    
    $message = [
        "message" => [
            "token" => $deviceToken,
            "notification" => [
                "title" => $title,
                "body" => $body
            ],
            "android" => [
                "priority" => "high",
                "notification" => [
                    "channel_id" => "high_importance_channel" 
                ]
            ]
        ]
    ];

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($message));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $accessToken, 
        'Content-Type: application/json'
    ]);
    
    $result = curl_exec($ch);
    
    // 7. DEBUGGING HASIL KIRIM
    if (curl_errno($ch)) {
        error_log('Error FCM CUrl: ' . curl_error($ch));
    } else {
        error_log('Respon FCM: ' . $result);
    }
    
    curl_close($ch);

    return true; 
}
?>