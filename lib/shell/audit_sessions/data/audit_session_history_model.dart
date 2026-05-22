class AuditSessionHistoryModel {
  final int auditId;
  final String auditNo;
  final String status;
  final bool isClosed; // Added
  final int mismatchCount; // Added
  final String createdAt;
  final String? completedAt;

  AuditSessionHistoryModel({
    required this.auditId,
    required this.auditNo,
    required this.status,
    required this.isClosed,
    required this.mismatchCount,
    required this.createdAt,
    this.completedAt,
  });

  factory AuditSessionHistoryModel.fromJson(Map<String, dynamic> json) {
    return AuditSessionHistoryModel(
      auditId: int.parse(json['id'].toString()),
      auditNo: json['audit_no'] ?? '',
      status: json['status'] ?? 'open',
      // Explicitly convert tinyint/int/bool values from DB
      isClosed: json['is_closed'] == 1 || json['is_closed'] == true,
      mismatchCount: int.tryParse(json['mismatch_count']?.toString() ?? '0') ?? 0,
      createdAt: json['started_at'] ?? '',
      completedAt: json['completed_at'],
    );
  }
}