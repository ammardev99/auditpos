import 'package:auditpos/shell/network/server_model.dart';

class AppConstants {
  static PosConfig? _activePos;

  static const List<PosConfig> posList = [
    PosConfig(
      name: "FCC",

      ip: "192.168.10.22",

      httpPort: 8000,

      wsPort: 8080,

      basePath: "",
    ),
  ];

  static void setPos(PosConfig pos) {
    _activePos = pos;
  }

  static PosConfig get pos => _activePos ?? posList.first;

  static String get baseUrl => pos.baseUrl;

  static String get loginUrl => "${pos.baseUrl}/api_login.php";

  static String get wsUrl => pos.wsUrl;
}
