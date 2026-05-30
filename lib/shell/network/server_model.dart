class PosConfig {
  final String name;
  final String ip;
  final String basePath;

  const PosConfig({
    required this.name,
    required this.ip,
    required this.basePath,
  });

  String get baseUrl => "http://$ip/$basePath";
  String get wsUrl => "ws://$ip:8080";
}