import 'package:auditpos/shell/network/server_model.dart';

class AppConstants {
  static PosConfig? _activePos;

  static const List<PosConfig> posList = [
    PosConfig(name: "v2/php_mart", ip: "192.168.1.16", basePath: "v2/php_mart"),
    PosConfig(name: "fcc_pos_php/php_mart", ip: "192.168.1.19", basePath: "fcc_pos_php/php_mart"),
  ];

  static void setPos(PosConfig pos) {
    _activePos = pos;
  }

  static PosConfig get pos => _activePos ?? posList.first;

  static String get baseUrl => pos.baseUrl;

  static String get loginUrl => "${pos.baseUrl}/api_login.php";

  static String get wsUrl => pos.wsUrl;
}
