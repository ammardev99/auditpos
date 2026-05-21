class AuditSessionHistoryModel {
  final int auditId;
  final String auditNo;
  final String status;
  final String createdAt;
  final String? completedAt;

  AuditSessionHistoryModel({
    required this.auditId,
    required this.auditNo,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory AuditSessionHistoryModel.fromJson(Map<String, dynamic> json) {
    return AuditSessionHistoryModel(
      auditId: int.parse(json['id'].toString()),
      auditNo: json['audit_no'] ?? '',
      status: json['status'] ?? 'open',
      createdAt: json['started_at'] ?? '',
      completedAt: json['completed_at'],
    );
  }
}