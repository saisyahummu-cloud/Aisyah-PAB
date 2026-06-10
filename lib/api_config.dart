class ApiConfig {
  
  static const String _ipAddress = "192.168.1.7";
  static const String baseUrl = "http://$_ipAddress/pgerd_backend";

  // Kumpulan Endpoint PGerd
  static const String loginEndpoint = "$baseUrl/login.php";
  static const String readEndpoint = "$baseUrl/read.php";
  static const String createEndpoint = "$baseUrl/create_reminder.php";
  static const String editEndpoint = "$baseUrl/edit.php";
  static const String deleteEndpoint = "$baseUrl/delete.php";
  static const String updateStatusEndpoint = "$baseUrl/update_status.php";
  static const String registerTokenEndpoint = "$baseUrl/register_token.php";
  static const String updateSudahMinumEndpoint =
      "$baseUrl/update_sudah_minum.php";
}
