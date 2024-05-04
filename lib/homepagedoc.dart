import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MediMateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ghar Ka Doctor',
      home: ChatScreenDoc(),
    );
  }
}

class ChatScreenDoc extends StatefulWidget {
  @override
  State createState() => ChatScreenDocState();
}

class ChatScreenDocState extends State<ChatScreenDoc> {
  bool isChatbotTyping = false;
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  void _handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message = ChatMessage(
      text: text,
      isUserMessage: true,
    );
    setState(() {
      _messages.insert(0, message);
    });
    _getChatbotResponse(text);
  }

  Future<void> _getChatbotResponse(String query) async {
    try {
      setState(() {
        isChatbotTyping = true;
      });


      final response = await http.get(
        Uri.parse(
            'https://gf4.404420.xyz/chatUser?text=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {

        final responseBody = jsonDecode(response.body);
        final botResponse = responseBody['content'];
        print(botResponse);

        // Split the response text wherever '\n' is present and create a list of lines.
        final lines = botResponse.split('\n');

        // Concatenate lines into a single message.
        final concatenatedMessage = lines.join('\n');

        ChatMessage message = ChatMessage(
          text: concatenatedMessage,
          isUserMessage: false,
        );

        setState(() {
          _messages.insert(0, message);
          isChatbotTyping = false;
        });
      } else {
        // Handle API error here
        print('API Error: ${response.reasonPhrase}');
        setState(() {
          isChatbotTyping = false; // Set typing status to false on error.
        });
      }
    } catch (error) {
      // Handle other errors, such as network issues
      print('Error: $error');
      setState(() {
        isChatbotTyping = false; // Set typing status to false on error.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var assetsImage = new AssetImage(
        'assets/robot.png'); //<- Creates an object that fetches an image.
    var image = new Image(image: assetsImage, fit: BoxFit.cover);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: image, // Replace 'MediMate' with the image
              height: 40, // Adjust the height as needed
              width: 40, // Adjust the width as needed
            ),
            const Text(
              'Doctor Assistant',
              style: TextStyle(
                fontSize: 20,
              ),
            ), // Replace 'MediMate' text
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _messages[index],
            ),
          ),
          Divider(height: 1.0),
          isChatbotTyping
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(width: 32.0),
                      CircularProgressIndicator(), // Typing indicator
                    ],
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                  ),
                  child: _buildTextComposer(),
                ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(25.0), // Adjust the border radius as needed
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration.collapsed(
                hintText: 'Describe the patient condition',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            color: Color.fromRGBO(252, 124, 184, 1),
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({required this.text, required this.isUserMessage});

  final String text;
  final bool isUserMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          isUserMessage
              ? SizedBox()
              : Image.asset(
                  'assets/icon.png', // Use the image asset
                  width: 40, // Adjust the width as needed
                  height: 40, // Adjust the height as needed
                ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isUserMessage
                  ? Color.fromRGBO(252, 124, 184, 1)
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Text(text),
          ),
          isUserMessage ? CircleAvatar(child: Icon(Icons.person)) : SizedBox(),
        ],
      ),
    );
  }
}
