import 'package:blackrock_go/controllers/meshtastic_node_controller.dart';
import 'package:blackrock_go/views/widgets/appbar_widget.dart';
import 'package:blackrock_go/views/widgets/golden_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:meshtastic_flutter/meshtastic_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:blackrock_go/models/const_model.dart' as constants;

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
            color: constants.Constants.primaryGold,
          ),
          titleWidget: Text(
            'Available Nodes',
            style: TextStyle(
              color: constants.Constants.primaryGold,
              fontSize: 20.px,
            ),
          ),
          actionWidgets: IconButton(
              onPressed: () => meshtasticNodeController.findNodes(),
              icon: Icon(
                Icons.refresh,
                color: constants.Constants.primaryGold,
              )),
        ),
        body: Obx(
          () => ListView.builder(
              itemCount: meshtasticNodeController.availableNodes.length,
              itemBuilder: (context, index) {
                final node = meshtasticNodeController.availableNodes[index];
                return ListTile(
                  title: Text(
                    node.platformName,
                    style: TextStyle(color: Colors.white, fontSize: 22.px),
                  ),
                  subtitle: Text(node.remoteId.toString()),
                  trailing: IconButton(
                      onPressed: () async {
                        meshtasticNodeController.connectToNode(node);
                        meshtasticNodeController.listenToConnectionStream();
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.px),
                              side: BorderSide(
                                  color: constants.Constants.primaryGold,
                                  width: 2.px),
                            ),
                            title: Text(
                              'Connecting to ${node.platformName}',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: Obx(() {
                              final status = meshtasticNodeController
                                  .connectionStatus.value;
                              return Text(
                                status.state.name,
                                style: TextStyle(color: Colors.white),
                              );
                            }),
                            actions: [
                              Obx(
                                () => GoldenButton(
                                    child: meshtasticNodeController
                                                .connectionStatus.value.state ==
                                            MeshtasticConnectionState.connected
                                        ? Text(
                                            'OK',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20.px,
                                            ),
                                          )
                                        : CircularProgressIndicator(),
                                    onPressed: () => meshtasticNodeController
                                                .connectionStatus.value.state ==
                                            MeshtasticConnectionState.connected
                                        ? context.pop()
                                        : null),
                              )
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
                      icon: Icon(
                        Icons.bluetooth_connected,
                        color: constants.Constants.primaryGold,
                      )),
                );
              }),
        ),
      ),
    );
  }
}
