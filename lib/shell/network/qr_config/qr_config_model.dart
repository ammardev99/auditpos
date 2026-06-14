import 'package:auditpos/shell/network/server_model.dart';

class PosQrConfig {
  final int version;
  final String martName;
  final String serverIp;
  final int httpPort;
  final int wsPort;
  final String basePath;
  final String dbName;
  final int dbPort;

  PosQrConfig({
    required this.version,
    required this.martName,
    required this.serverIp,
    required this.httpPort,
    required this.wsPort,
    required this.basePath,
    required this.dbName,
    required this.dbPort,
  });

  factory PosQrConfig.fromJson(Map<String, dynamic> json) {
    return PosQrConfig(
      version: json['version'] ?? 1,
      martName: json['martName'] ?? '',
      serverIp: json['serverIp'] ?? '',
      httpPort: json['httpPort'] ?? 8000,
      wsPort: json['wsPort'] ?? 8080,
      basePath: json['basePath'] ?? '',
      dbName: json['dbName'] ?? '',
      dbPort: json['dbPort'] ?? 3306,
    );
  }
}

extension PosQrMapper on PosQrConfig {
  PosConfig toPosConfig() {
    return PosConfig(
      name: martName,
      ip: serverIp,
      connectionType: ConnectionType.path,
      httpPort: httpPort,
      wsPort: wsPort,
      basePath: basePath,
    );
  }
}
