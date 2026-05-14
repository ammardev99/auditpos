class AuditSessionModel {
  final int id;
  final String auditNo;
  final String status;

  AuditSessionModel({
    required this.id,
    required this.auditNo,
    required this.status,
  });

  factory AuditSessionModel.fromJson(
      Map<String, dynamic> json) {
    return AuditSessionModel(
      id: json['id'],
      auditNo: json['audit_no'],
      status: json['status'],
    );
  }
}