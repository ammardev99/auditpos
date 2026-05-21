class AppConstants {
  static String iP = "";

  static String get baseUrl => "http://$iP/fcc_pos_php/php_mart";

  static String get loginUrl => "$baseUrl/api_login.php";

  static String get wsUrl => "ws://$iP:8080";
}
