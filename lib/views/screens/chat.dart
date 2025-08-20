import 'dart:async';
import 'dart:developer';

import 'package:blackrock_go/controllers/meshtastic_node_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as chat;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:get/get.dart';
import 'package:meshtastic_flutter/meshtastic_flutter.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.title,
  });

  final String title;

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
    await meshtasticNodeController.client.sendTextMessage(text);
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
            icon: const Icon(Icons.arrow_back, color: Color(0xFFB4914B)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(widget.title, style: TextStyle(color: Color(0xFFB4914B))),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/bg.jpg', // Add your background image here
                fit: BoxFit.cover,
              ),
            ),
            Chat(
              currentUserId:
                  meshtasticNodeController.client.localUser?.id ?? "TempId",
              resolveUser: (id) async {
                return chat.User(id: id);
              },
              chatController: _chatController,
              onMessageSend: _handleSendPressed,
            )
            // StreamBuilder<types.Room>(
            //   initialData: widget.room,
            //   stream: FirebaseChatCore.instance.room(widget.room.id),
            //   builder: (context, snapshot) =>
            //       StreamBuilder<List<types.Message>>(
            //     initialData: const [],
            //     stream: FirebaseChatCore.instance.messages(snapshot.data!),
            //     builder: (context, snapshot) => Chat(
            //       messages: snapshot.data ?? [],
            //       onMessageTap: _handleMessageTap,
            //       onPreviewDataFetched: _handlePreviewDataFetched,
            //       onSendPressed: _handleSendPressed,
            //       showUserAvatars: true,
            //       user: types.User(
            //         id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
            //       ),
            //       theme: DefaultChatTheme(
            //         backgroundColor: Colors.transparent,
            //         primaryColor: Colors.black,
            //         secondaryColor: Colors.black,
            //         messageInsetsVertical: 10,
            //         messageInsetsHorizontal: 16,
            //         messageBorderRadius: 10,
            //         userAvatarNameColors: const [Colors.blue, Colors.red],
            //         userAvatarTextStyle: const TextStyle(color: Colors.white),
            //         receivedMessageBodyTextStyle:
            //             const TextStyle(color: Color(0xFFB4914B)),
            //         sentMessageBodyTextStyle:
            //             const TextStyle(color: Color(0xFFB4914B)),
            //         // receivedMessageBorderColor: Color(0xFFB4914B),
            //         // sentMessageBorderColor: Color(0xFFB4914B),
            //         inputTextColor: Colors.white,
            //         inputBackgroundColor: Colors.black,
            //         inputBorderRadius: BorderRadius.circular(10),
            //         inputTextStyle: const TextStyle(color: Colors.white),
            //         // inputButtonIcon: Icon(Icons.send, color: Color(0xFFB4914B)),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      );
}
