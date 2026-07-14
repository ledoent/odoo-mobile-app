/// DTOs for the CRM working set (my open pipeline).
library;

String _rel(dynamic value) =>
    value is List && value.length > 1 ? value[1] as String : '';

int? _relId(dynamic value) => value is List ? value[0] as int : null;

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
    name: json['name'] as String? ?? '',
    partnerName: _rel(json['partner_id']).isNotEmpty
        ? _rel(json['partner_id'])
        : (json['contact_name'] is String
              ? json['contact_name'] as String
              : ''),
    stageId: _relId(json['stage_id']),
    stageName: _rel(json['stage_id']),
    expectedRevenue: (json['expected_revenue'] as num? ?? 0).toDouble(),
    phone: json['phone'] is String ? json['phone'] as String : '',
    email: json['email_from'] is String ? json['email_from'] as String : '',
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
