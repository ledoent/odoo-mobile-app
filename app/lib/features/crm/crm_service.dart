import '../../data/local/database.dart';
import '../../data/sync/op.dart';

/// CRM mutations: optimistic local update + queued op, same pattern as the
/// warehouse scan service. Never talks to Odoo directly.
class CrmService {
  CrmService(this._db);

  final AppDatabase _db;

  Future<void> setStage({
    required int leadId,
    required int stageId,
    required String stageName,
  }) async {
    final op = SetLeadStageOp(leadId: leadId, stageId: stageId);
    await _db.setLocalLeadStage(leadId, stageId, stageName);
    await _db.enqueue(op);
  }

  Future<void> logNote({required int leadId, required String body}) async {
    final op = LogLeadNoteOp(leadId: leadId, body: body);
    await _db.enqueue(op);
  }

  Future<int> createLead({
    required String name,
    String contactName = '',
    String phone = '',
    String email = '',
  }) async {
    final localId = await _db.insertLocalLead(
      name: name,
      partnerName: contactName,
      phone: phone,
      email: email,
    );
    final op = CreateLeadOp(
      name: name,
      contactName: contactName,
      phone: phone,
      email: email,
      localLeadId: localId,
    );
    await _db.enqueue(op);
    return localId;
  }
}
