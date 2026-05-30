class PosConfig {
  final String name;

  final String ip;

  final int httpPort;

  final int wsPort;

  final String basePath;

  const PosConfig({
    required this.name,
    required this.ip,
    required this.httpPort,
    required this.wsPort,
    required this.basePath,
  });

  String get baseUrl {
    final root = "http://$ip:$httpPort";

    if (basePath.isEmpty) {
      return root;
    }

    return "$root/$basePath";
  }

  String get wsUrl {
    return "ws://$ip:$wsPort";
  }
}
