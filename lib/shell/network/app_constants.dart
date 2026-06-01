import 'package:auditpos/shell/network/server_model.dart';

class AppConstants {

  static PosConfig? _activePos;

  static const List<PosConfig> posList = [

    PosConfig(

      name: "FCC Mart",

      ip: "192.168.1.4",

      connectionType:
          ConnectionType.path,

      httpPort: 8000,

      wsPort: 8080,

      basePath: "billinga/billinga",
    ),

    // Example Path Mode

    /*
    PosConfig(

      name: "Billing",

      ip: "192.168.10.22",

      connectionType:
          ConnectionType.path,

      httpPort: 80,

      wsPort: 8080,

      basePath: "billinga",
    ),
    */

  ];

  static void setPos(
    PosConfig pos,
  ) {

    _activePos = pos;
  }

  static PosConfig get pos {

    return _activePos ??
        posList.first;
  }

  static String get baseUrl {

    return pos.baseUrl;
  }

  static String get loginUrl {

    return "${pos.baseUrl}/api_login.php";
  }

  static String get wsUrl {

    return pos.wsUrl;
  }
}