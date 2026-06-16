import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/oracle_query.dart';
import 'camp_network_service.dart';

/// Sends oracle queries to Pythia and routes responses back.
///
/// Path selection:
///   Camp WiFi detected → HTTP POST to camp.local:8000/oracle (fast, ~10s)
///   LoRa only          → publish via mesh DM to gateway (slow, ~45s)
///
/// Pythia responses arrive either via HTTP response body (WiFi path)
/// or via an incoming mesh DM on the pythia.response channel (LoRa path).
class PythiaService extends GetxService {
  final _network = Get.find<CampNetworkService>();
  final _uuid    = const Uuid();

  final RxList<OracleQuery> queryHistory = <OracleQuery>[].obs;
  final Rx<OracleQuery?> activeQuery = Rx<OracleQuery?>(null);

  static const _timeout = Duration(seconds: 90);

  // ── Query ─────────────────────────────────────────────────────────────────

  /// Submit a query to Pythia. Updates [activeQuery] with live status.
  /// Returns the completed query when a response arrives, or null on timeout.
  Future<OracleQuery?> ask(String queryText) async {
    final query = OracleQuery(
      id: _uuid.v4(),
      queryText: queryText,
      sentAt: DateTime.now(),
      path: _network.isOnCampWifi ? OraclePath.wifi : OraclePath.lora,
    );

    activeQuery.value = query;
    queryHistory.insert(0, query);

    try {
      if (_network.isOnCampWifi) {
        return await _askViaWifi(query);
      } else {
        return await _askViaLora(query);
      }
    } catch (_) {
      query.status = OracleStatus.timeout;
      activeQuery.value = query;
      return null;
    }
  }

  // ── WiFi path ─────────────────────────────────────────────────────────────

  Future<OracleQuery?> _askViaWifi(OracleQuery query) async {
    query.status = OracleStatus.sent;
    activeQuery.refresh();

    final campHost = _network.campHost.value ?? 'camp.local';
    final uri      = Uri.parse('http://$campHost:8000/oracle');

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'query': query.queryText,
            'request_id': query.id,
            'path': 'wifi',
          }),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final body       = jsonDecode(response.body) as Map<String, dynamic>;
      query.status      = OracleStatus.received;
      query.responseText = body['response'] as String?;
      query.respondedAt  = DateTime.now();
    } else {
      query.status = OracleStatus.timeout;
    }

    activeQuery.value = query;
    queryHistory.refresh();
    return query;
  }

  // ── LoRa path ─────────────────────────────────────────────────────────────

  Future<OracleQuery?> _askViaLora(OracleQuery query) async {
    query.status = OracleStatus.sent;
    activeQuery.refresh();

    // TODO: send via MeshMessageService to gateway node's oracle channel
    // The mesh message service will publish to the pythia.query NATS topic
    // via the gateway. Response comes back as an incoming DM routed to
    // handleLoraResponse() by the message router.

    // Wait for response with timeout
    query.status = OracleStatus.waiting;
    activeQuery.refresh();

    final completer = _pendingLora[query.id] = _LoraCompleter();
    return completer.future.timeout(_timeout, onTimeout: () {
      query.status = OracleStatus.timeout;
      _pendingLora.remove(query.id);
      activeQuery.value = query;
      return null;
    });
  }

  /// Called by the mesh message router when a pythia.response DM arrives.
  void handleLoraResponse(String requestId, String responseText) {
    final completer = _pendingLora.remove(requestId);
    if (completer == null) return;

    final query = queryHistory.firstWhereOrNull((q) => q.id == requestId);
    if (query == null) return;

    query.status       = OracleStatus.received;
    query.responseText = responseText;
    query.respondedAt  = DateTime.now();
    activeQuery.value  = query;
    queryHistory.refresh();

    completer.complete(query);
  }

  final _pendingLora = <String, _LoraCompleter>{};
}

// Simple completer wrapper for the LoRa async wait
class _LoraCompleter {
  OracleQuery? _result;

  Future<OracleQuery?> get future => Future(() async {
    while (_result == null) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return _result;
  });

  void complete(OracleQuery? result) {
    _result = result;
  }
}
