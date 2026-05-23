class AuditSessionHistoryModel {
  final int auditId;
  final String auditNo;
  final String status;
  final bool isClosed;
  final int mismatchCount;
  final String createdAt;
  final String? completedAt;
  final String openByName;
  final String? closedByName; // Added field for closer's name

  AuditSessionHistoryModel({
    required this.auditId,
    required this.auditNo,
    required this.status,
    required this.isClosed,
    required this.mismatchCount,
    required this.createdAt,
    this.completedAt,
    required this.openByName,
    this.closedByName, // Added field
  });

  factory AuditSessionHistoryModel.fromJson(Map<String, dynamic> json) {
    return AuditSessionHistoryModel(
      auditId: int.parse(json['id'].toString()),
      auditNo: json['audit_no'] ?? '',
      status: json['status'] ?? 'open',
      isClosed: json['is_closed'].toString() == '1',
      mismatchCount:
          int.tryParse(json['mismatch_count']?.toString() ?? '0') ?? 0,
      createdAt: json['started_at'] ?? '',
      completedAt: json['completed_at'],
      openByName: json['open_by_name'] ?? 'Unknown',
      closedByName: json['closed_by_name'], // Extracted field
    );
  }
}
