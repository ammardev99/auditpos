enum ConnectionType { port, path }

class PosConfig {
  final String name;
  final String ip;

  final ConnectionType connectionType;

  final int httpPort;

  final int wsPort;

  final String basePath;

  const PosConfig({
    required this.name,
    required this.ip,

    required this.connectionType,

    required this.httpPort,

    required this.wsPort,

    required this.basePath,
  });

  String get baseUrl {
    if (connectionType == ConnectionType.port) {
      return "http://$ip:$httpPort";
    }

    if (basePath.isEmpty) {
      return "http://$ip";
    }

    return "http://$ip/$basePath";
  }

  String get wsUrl {
    return "ws://$ip:$wsPort";
  }
}
