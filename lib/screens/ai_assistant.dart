import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // New Import
import '../providers/app_state.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      setState(() {
        _messages.add({
          "role": "ai",
          "content": appState.t(
            "### Welcome to Biashara Smart! 🚀\nI am your growth assistant. Ask me about your **sales**, **expenses**, or **business strategy**.",
            "### Karibu kwenye Biashara Smart! 🚀\nMimi ni msaidizi wako wa ukuaji. Niulize kuhusu **mauzo**, **matumizi**, au **mkakati wa biashara**.",
          ),
        });
      });
    });
  }

  void _handleSend(AppState appState) async {
    if (_controller.text.trim().isEmpty) return;

    String userQuery = _controller.text;
    setState(() {
      _messages.add({"role": "user", "content": userQuery});
    });
    _controller.clear();

    // Show a small delay to mimic "thinking"
    String response = await appState.getAIResponse(userQuery);

    if (mounted) {
      setState(() {
        _messages.add({"role": "ai", "content": response});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          appState.t("AI Business Consultant", "Mshauri wa Biashara"),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isAI = _messages[index]['role'] == 'ai';
                return _buildChatBubble(_messages[index]['content']!, isAI);
              },
            ),
          ),
          _buildInputArea(appState),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String content, bool isAI) {
    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: isAI ? const Color(0xFF1E293B) : const Color(0xFF6366F1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isAI ? 0 : 20),
            bottomRight: Radius.circular(isAI ? 20 : 0),
          ),
        ),
        // USING MARKDOWN FOR PROFESSIONAL FORMATTING
        child: MarkdownBody(
          data: content,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
            strong: const TextStyle(
              color: Color(0xFFFACC15),
              fontWeight: FontWeight.bold,
            ),
            h3: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            listBullet: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(AppState appState) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: appState.t(
                  "How can I help your business grow?",
                  "Nisaidie vipi kukuza biashara yako?",
                ),
                hintStyle: const TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _handleSend(appState),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: Color(0xFF6366F1)),
            onPressed: () => _handleSend(appState),
          ),
        ],
      ),
    );
  }
}
