/// DTOs for the CRM working set (my open pipeline).
library;

import 'odoo_json.dart';

class RemoteLead {
  const RemoteLead({
    required this.id,
    required this.name,
    this.partnerName = '',
    this.stageId,
    this.stageName = '',
    this.expectedRevenue = 0,
    this.phone = '',
    this.email = '',
  });

  final int id;
  final String name;
  final String partnerName;
  final int? stageId;
  final String stageName;
  final double expectedRevenue;
  final String phone;
  final String email;

  factory RemoteLead.fromJson(Map<String, dynamic> json) => RemoteLead(
    id: json['id'] as int,
    name: odooString(json['name']),
    partnerName: relName(json['partner_id']).isNotEmpty
        ? relName(json['partner_id'])
        : odooString(json['contact_name']),
    stageId: relId(json['stage_id']),
    stageName: relName(json['stage_id']),
    expectedRevenue: (json['expected_revenue'] as num? ?? 0).toDouble(),
    phone: odooString(json['phone']),
    email: odooString(json['email_from']),
  );
}

class RemoteCrmStage {
  const RemoteCrmStage({
    required this.id,
    required this.name,
    required this.sequence,
  });

  final int id;
  final String name;
  final int sequence;

  factory RemoteCrmStage.fromJson(Map<String, dynamic> json) => RemoteCrmStage(
    id: json['id'] as int,
    name: json['name'] as String,
    sequence: json['sequence'] as int? ?? 0,
  );
}
