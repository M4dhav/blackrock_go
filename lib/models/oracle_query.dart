enum OracleStatus { composing, sent, waiting, received, timeout }
enum OraclePath { wifi, lora }

class OracleQuery {
  final String id;
  final String queryText;
  final DateTime sentAt;
  OracleStatus status;
  String? responseText;
  DateTime? respondedAt;
  OraclePath path;

  OracleQuery({
    required this.id,
    required this.queryText,
    required this.sentAt,
    this.status = OracleStatus.composing,
    this.responseText,
    this.respondedAt,
    this.path = OraclePath.wifi,
  });

  Duration get waitTime => (respondedAt ?? DateTime.now()).difference(sentAt);

  bool get isComplete => status == OracleStatus.received;
  bool get isPending  =>
      status == OracleStatus.sent || status == OracleStatus.waiting;
}
