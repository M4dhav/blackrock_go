import 'package:blackrock_go/controllers/meshtastic_node_controller.dart';
import 'package:blackrock_go/views/widgets/appbar_widget.dart';
import 'package:blackrock_go/views/widgets/golden_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:meshtastic_flutter/meshtastic_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ConnectNodeScreen extends StatefulWidget {
  const ConnectNodeScreen({super.key});

  @override
  State<ConnectNodeScreen> createState() => _ConnectNodeScreenState();
}

class _ConnectNodeScreenState extends State<ConnectNodeScreen> {
  final MeshtasticNodeController meshtasticNodeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/bg.jpg"), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          leadingWidget: BackButton(
            onPressed: () => context.pop(),
            color: Color(0xffb4914b),
          ),
          titleWidget: Text(
            'Available Nodes',
            style: TextStyle(
              color: const Color(0xffb4914b),
              fontSize: 20.px,
            ),
          ),
          actionWidgets: IconButton(
              onPressed: () => meshtasticNodeController.findNodes,
              icon: Icon(
                Icons.refresh,
                color: Color(0xffb4914b),
              )),
        ),
        body: Obx(
          () => ListView.builder(
              itemCount: meshtasticNodeController.availableNodes.length,
              itemBuilder: (context, index) {
                final node = meshtasticNodeController.availableNodes[index];
                return ListTile(
                  title: Text(node.platformName),
                  subtitle: Text(node.remoteId.toString()),
                  trailing: IconButton(
                      onPressed: () async {
                        meshtasticNodeController.client.connectToDevice(node);
                        meshtasticNodeController.listenToConnectionStream();
                        await Get.dialog(
                          AlertDialog(
                            title: Text('Connecting to ${node.platformName}'),
                            content: Obx(() {
                              final status = meshtasticNodeController
                                  .connectionStatus.value;
                              return Text(status.state.toString());
                            }),
                            actions: [
                              GoldenButton(
                                  child: meshtasticNodeController
                                              .connectionStatus.value.state ==
                                          MeshtasticConnectionState.connected
                                      ? Text(
                                          'OK',
                                          style: TextStyle(
                                            color: const Color(0xffb4914b),
                                            fontSize: 20.px,
                                          ),
                                        )
                                      : CircularProgressIndicator(
                                          color: Color(0xffb4914b),
                                        ),
                                  onPressed: () => meshtasticNodeController
                                              .connectionStatus.value.state ==
                                          MeshtasticConnectionState.connected
                                      ? Get.back()
                                      : null)
                            ],
                          ),
                          barrierDismissible: false,
                        );
                        meshtasticNodeController.nodes.value =
                            meshtasticNodeController.client.nodes;
                        if (context.mounted) {
                          context.pop();
                        }
                      },
                      icon: Icon(Icons.bluetooth_connected)),
                );
              }),
        ),
      ),
    );
  }
}
