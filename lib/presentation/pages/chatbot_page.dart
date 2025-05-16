import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = ["Bonjour, comment puis-je vous aider ?"];

  // TODO: Replace with your actual API key and handle securely
  final String _apiKey = 'AIzaSyAhiUAdq3OFHxy6g-d6we_O_JpXPoYdbaM';
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    // Changed model name to gemini-1.5-flash-latest
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
  }

  void _handleSubmitted(String text) async {
    _textController.clear();
    setState(() {
      _messages.add("You: $text");
    });

    if (_apiKey.isEmpty) {
      setState(() {
        _messages.add("Bot: Please set your API key.");
      });
      return;
    }

    try {
      final content = [Content.text(text)];
      final response = await _model.generateContent(content);
      final textResponse = response.text;

      if (textResponse != null) {
        setState(() {
          _messages.add("Bot: $textResponse");
        });
      } else {
        setState(() {
          _messages.add("Bot: No response from the model.");
        });
      }
    } catch (e) {
      setState(() {
        _messages.add("Bot: Error: ${e.toString()}");
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true, // Show latest messages at the bottom
              itemCount: _messages.length,
              itemBuilder: (_, int index) {
                final reversedIndex = _messages.length - 1 - index;
                return _buildMessage(_messages[reversedIndex]);
              },
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String message) {
    final parts = message.split(':');
    final sender = parts[0];
    final text = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sender, style: Theme.of(context).textTheme.titleMedium),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Send a message',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
