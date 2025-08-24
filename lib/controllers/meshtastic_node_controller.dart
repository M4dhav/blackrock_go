import 'dart:convert';
import 'dart:developer';

import 'package:blackrock_go/controllers/mapbox_map_controller.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:meshtastic_flutter/meshtastic_flutter.dart';

class MeshtasticNodeController extends GetxController {
  final client = MeshtasticClient();
  RxList<BluetoothDevice> availableNodes = <BluetoothDevice>[].obs;
  Rx<ConnectionStatus> connectionStatus = ConnectionStatus(
          state: MeshtasticConnectionState.disconnected,
          timestamp: DateTime.now())
      .obs;

  RxMap<int, NodeInfoWrapper> nodes = <int, NodeInfoWrapper>{}.obs;
  RxList<NodeInfoWrapper> activeUserChats = <NodeInfoWrapper>[].obs;
  RxList<Channel> activeChannels = <Channel>[].obs;
  final MapboxMapController mapboxMapController = Get.find();

  @override
  void onInit() async {
    super.onInit();
    await client.initialize();
  }

  @override
  void onClose() {
    client.dispose();
    super.onClose();
  }

  void findNodes() async {
    // ChannelSet channel = ChannelSet.fromBuffer(base64Decode(
    //         'Ci4SIDhLvMAdwCLRgb82uGEh4fuWty5Vv3Qifp1q-0jWTLGhGghFdmVyeW9uZToAEhMIARAIOAFABEgBUB5YH2gBwAYB')
    //     .toList());

    // log('Channel created: ${channel.settings[0].name}');
    client.scanForDevices().listen((event) {
      if (!availableNodes.contains(event)) {
        availableNodes.add(event);
      }
    });
  }

  void listenToConnectionStream() async {
    client.connectionStream.listen((event) {
      connectionStatus.value = event;
    });
  }

  Stream<MeshPacketWrapper> listenForTextMessages() async* {
    await for (final packet in client.packetStream) {
      if (packet.isTextMessage) {
        yield packet;
      }
    }
  }

  void connectToNode(BluetoothDevice device) async {
    try {
      await client.connectToDevice(device);
      activeChannels.value = client.config?.channels ?? [];
      mapboxMapController.addNodesModelLayer(nodes.values.where((node) {
        return node.userId != client.localUser?.id;
      }).toList());
    } catch (e) {
      Get.snackbar('Error', 'Failed to connect to node: $e');
    }
  }

  void getNodeLocations() {
    for (var node in nodes.values) {
      log('Node with id ${node.userId} is at location ${node.longitude}, ${node.latitude}');
    }
  }

  Future<void> configureChannels(String qrUrl) async {
    try {
      final channelSet = ChannelConfigHelper.parseChannelSetFromUrl(qrUrl);
      if (ChannelConfigHelper.sessionKey == null) {
        final sessionKeyRequest = AdminMessage(
          getConfigRequest: AdminMessage_ConfigType.SESSIONKEY_CONFIG,
        );

        final sessionKeyPacket = MeshPacket(
          to: 0xffffffff, // Broadcast to get our own session key
          decoded: Data(
            portnum: PortNum.ADMIN_APP,
            payload: sessionKeyRequest.writeToBuffer(),
          ),
          wantAck: true,
          priority: MeshPacket_Priority.RELIABLE,
        );

        await client.sendPacket(sessionKeyPacket);

        // Wait for session key response
        await Future.delayed(const Duration(seconds: 3));
      }
      final configPackets = ChannelConfigHelper.createChannelConfigPackets(
        channelSet!,
        requestSessionKey: false, // We already have the session key
      );

      log('📦 Generated ${configPackets.length} configuration packets');

      // Step 3: Send each packet to the device
      for (int i = 0; i < configPackets.length; i++) {
        final packet = configPackets[i];
        log('   Sending packet ${i + 1}/${configPackets.length}...');

        await client.sendPacket(packet);

        // Add delay between packets to avoid overwhelming the device
        await Future.delayed(const Duration(milliseconds: 500));
      }

      print('✅ Channel configuration applied successfully');
    } catch (e) {
      log(e.toString());
    }
  }
}
