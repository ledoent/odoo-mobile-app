import 'crm_models.dart';
import 'odoo_client.dart';

/// Typed façade for the CRM module flows.
abstract interface class CrmApi {
  /// Open opportunities assigned to the authenticated user.
  Future<List<RemoteLead>> fetchMyOpenLeads();
  Future<List<RemoteCrmStage>> fetchStages();
  Future<void> setLeadStage({required int leadId, required int stageId});
  Future<void> logNote({required int leadId, required String body});
  Future<int> createLead({
    required String name,
    String contactName = '',
    String phone = '',
    String email = '',
  });
}

class JsonRpcCrmApi implements CrmApi {
  JsonRpcCrmApi(this._client);

  final OdooClient _client;

  @override
  Future<List<RemoteLead>> fetchMyOpenLeads() async {
    final uid = _client.uid ?? await _client.authenticate();
    final rows = await _client.searchRead(
      'crm.lead',
      [
        ['user_id', '=', uid],
        ['active', '=', true],
        ['probability', '<', 100],
      ],
      [
        'name',
        'partner_id',
        'contact_name',
        'stage_id',
        'expected_revenue',
        'phone',
        'email_from',
      ],
      order: 'stage_id asc, expected_revenue desc',
    );
    return rows.map(RemoteLead.fromJson).toList();
  }

  @override
  Future<List<RemoteCrmStage>> fetchStages() async {
    final rows = await _client.searchRead('crm.stage', [], [
      'name',
      'sequence',
    ], order: 'sequence asc, id asc');
    return rows.map(RemoteCrmStage.fromJson).toList();
  }

  @override
  Future<void> setLeadStage({required int leadId, required int stageId}) async {
    await _client.executeKw('crm.lead', 'write', [
      [leadId],
      {'stage_id': stageId},
    ]);
  }

  @override
  Future<void> logNote({required int leadId, required String body}) async {
    await _client.executeKw(
      'crm.lead',
      'message_post',
      [
        [leadId],
      ],
      {'body': body},
    );
  }

  @override
  Future<int> createLead({
    required String name,
    String contactName = '',
    String phone = '',
    String email = '',
  }) async {
    final values = <String, dynamic>{'name': name};
    if (contactName.isNotEmpty) values['contact_name'] = contactName;
    if (phone.isNotEmpty) values['phone'] = phone;
    if (email.isNotEmpty) values['email_from'] = email;
    final id = await _client.executeKw('crm.lead', 'create', [values]);
    return id as int;
  }
}
