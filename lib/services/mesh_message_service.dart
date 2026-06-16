import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:meshtastic_flutter/meshtastic_flutter.dart';

import '../controllers/meshtastic_node_controller.dart';
import 'camp_service.dart';
import 'location_link_service.dart';
import 'pythia_service.dart';

/// Central router for all outgoing and incoming mesh messages.
///
/// Outgoing: provides sendDm() and sendChannel() used by all services.
/// Incoming: routes packets from MeshtasticNodeController to the correct
///           service handler based on message type prefix.
class MeshMessageService extends GetxService {
  late final MeshtasticNodeController _mesh;
  StreamSubscription? _sub;

  @override
  Future<void> onInit() async {
    super.onInit();
    _mesh = Get.find<MeshtasticNodeController>();
    _sub  = _mesh.listenForTextMessages().listen(_route);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  // ── Outgoing ──────────────────────────────────────────────────────────────

  Future<void> sendDm(String targetNodeId, String text) async {
    // Parse "!a3f92c1b" hex string to int for Meshtastic API
    final nodeInt = int.tryParse(
      targetNodeId.startsWith('!') ? targetNodeId.substring(1) : targetNodeId,
      radix: 16,
    );
    await _mesh.client.sendTextMessage(
      text,
      destinationId: nodeInt,
    );
  }

  Future<void> sendChannel(int slot, String text) async {
    await _mesh.client.sendTextMessage(
      text,
      channel: slot,
    );
  }

  // ── Incoming router ───────────────────────────────────────────────────────

  void _route(MeshPacketWrapper packet) {
    if (!packet.isTextMessage) return;
    final raw = packet.textMessage ?? '';
    if (raw.isEmpty) return;

    // Try to parse as structured JSON envelope
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final type = m['type'] as String?;

      switch (type) {
        case 'camp_join_request':
          // TODO: notify camp lead via local notification
          break;
        case 'camp_key_delivery':
          final campId = m['camp_id'] as String;
          final data   = m['data'] as String;
          Get.find<CampService>().handleKeyDelivery(campId, data);
        case 'link_accept':
          Get.find<LocationLinkService>().handleAcceptance(m);
        case 'link_pos':
          Get.find<LocationLinkService>().handlePositionUpdate(m);
        case 'link_revoke':
          Get.find<LocationLinkService>().handleRevocation(m);
        case 'pythia_response':
          final requestId = m['rid'] as String;
          final response  = m['response'] as String;
          Get.find<PythiaService>().handleLoraResponse(requestId, response);
        default:
          // Plain text message — handled by existing chat controllers
          break;
      }
    } catch (_) {
      // Not a JSON envelope — plain text, ignore at this layer
    }
  }
}
