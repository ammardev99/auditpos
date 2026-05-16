
// make sure dont distrub my login
class AppConstants {

  static const String iP = "192.168.1.27";
  static const String baseUrl = "http://$iP/fcc_pos_php/php_mart";

  static const String loginUrl = "$baseUrl/api_login.php";

  static const String wsUrl = "ws://$iP:8080";
}
