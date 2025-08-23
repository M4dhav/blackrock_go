import 'dart:developer';

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
    } catch (e) {
      Get.snackbar('Error', 'Failed to connect to node: $e');
    }
  }

  void getNodeLocations() {
    for (var node in nodes.values) {
      log('Node with id ${node.userId} is at location ${node.longitude}, ${node.latitude}');
    }
  }
}
