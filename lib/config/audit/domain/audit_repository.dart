import '../../../shell/network/websocket_service.dart';

class AuditRepository {
  final WebSocketService socket;

  AuditRepository(this.socket);

  void startAudit() {
    socket.send({
      "action": "start_audit",
      "payload": {}
    });
  }

  void getAuditItems(int auditId) {
    socket.send({
      "action": "get_audit_items",
      "payload": {
        "audit_id": auditId,
      }
    });
  }

  void updateAuditItem({
    required int auditId,
    required int productId,
    required double phyQty,
    required double phyPrice,
  }) {
    socket.send({
      "action": "update_audit_item",
      "payload": {
        "audit_id": auditId,
        "product_id": productId,
        "phyQty": phyQty,
        "phyPrice": phyPrice,
      }
    });
  }

  void completeAudit(int auditId) {
    socket.send({
      "action": "complete_audit",
      "payload": {
        "audit_id": auditId,
      }
    });
  }

  void approveAudit(int auditId) {
    socket.send({
      "action": "approve_audit",
      "payload": {
        "audit_id": auditId,
      }
    });
  }
}