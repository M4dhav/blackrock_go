import 'dart:async';
import 'dart:developer';

import 'package:blackrock_go/controllers/meshtastic_node_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as chat;
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:get/get.dart';
import 'package:meshtastic_flutter/meshtastic_flutter.dart';
import 'package:blackrock_go/models/const_model.dart' as constants;

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.title,
    this.user,
  });

  final String title;
  final NodeInfoWrapper? user;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final MeshtasticNodeController meshtasticNodeController = Get.find();
  final _chatController = chat.InMemoryChatController();
  StreamSubscription<MeshPacketWrapper>? messageSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for incoming messages
    messageSubscription =
        meshtasticNodeController.listenForTextMessages().listen(
      (packet) {
        if (widget.user != null) {
          if (packet.packet.from != widget.user!.num) {
            return; // Ignore messages not from the specified user
          }
        }
        // Add the incoming message to the chat controller
        _chatController.insertMessage(
          chat.Message.text(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            authorId: packet.packet.from.toString(), // Use the sender's ID
            text: packet.textMessage ?? "", // The text of the message
            createdAt: DateTime.now(),
          ),
        );
      },
      onError: (error) {
        // Handle any errors in the stream
        log('Error receiving messages: $error');
      },
    );
  }

  @override
  void dispose() {
    // Cancel the subscription to avoid memory leaks
    messageSubscription?.cancel();
    super.dispose();
  }

  void _handleSendPressed(String text) async {
    if (widget.user == null) {
      await meshtasticNodeController.client.sendTextMessage(text);
    } else {
      await meshtasticNodeController.client
          .sendTextMessage(text, destinationId: widget.user!.num);
    }
    await _chatController.insertMessage(chat.Message.text(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: meshtasticNodeController.client.localUser?.id ?? "TempId",
      text: text,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Colors.black,
          leading: IconButton(
            icon:
                Icon(Icons.arrow_back, color: constants.Constants.primaryGold),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(widget.title,
              style: TextStyle(color: constants.Constants.primaryGold)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(
              height: 2.0,
              color: constants.Constants.primaryGold,
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Chat(
            currentUserId:
                meshtasticNodeController.client.localUser?.id ?? "TempId",
            resolveUser: (id) async {
              return chat.User(id: id);
            },
            chatController: _chatController,
            onMessageSend: _handleSendPressed,
            backgroundColor: Colors.transparent,
            builders: Builders(
                composerBuilder: (context) => Composer(
                      sendIconColor: Colors.white,
                      sendButtonVisibilityMode: SendButtonVisibilityMode.always,
                    )),
            theme: ChatTheme.dark(),
          ),
        ),
      );
}
