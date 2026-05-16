class AuditSessionModel {
  final int auditId;
  final String auditNo;

  AuditSessionModel({
    required this.auditId,
    required this.auditNo,
  });

  factory AuditSessionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AuditSessionModel(
      auditId: int.parse(
        json['audit_id'].toString(),
      ),

      auditNo: json['audit_no'] ?? '',
    );
  }
}