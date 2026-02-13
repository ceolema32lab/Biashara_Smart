import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    // Karibisho la mwanzo kulingana na lugha iliyochaguliwa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      setState(() {
        _messages.add({
          "role": "ai",
          "content": appState.t(
            "Habari! I am your Biashara Smart Assistant. Ask me about your sales, expenses, or business growth.",
            "Habari! Mimi ni msaidizi wako wa Biashara Smart. Niulize kuhusu mauzo, matumizi, au ukuaji wa biashara yako."
          )
        });
      });
    });
  }

  void _handleSend(AppState appState) {
    if (_controller.text.trim().isEmpty) return;

    String userQuery = _controller.text;
    
    setState(() {
      _messages.add({"role": "user", "content": userQuery});
    });

    // Tunatumia "Brain" iliyopo kwenye AppState kupata majibu
    String response = appState.getAIResponse(userQuery);

    // Simulation ya AI "kufikiri" kidogo
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _messages.add({"role": "ai", "content": response});
        });
      }
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(appState.t("AI Business Assistant", "Msaidizi wa AI")),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      bool isAI = _messages[index]['role'] == 'ai';
                      return _buildChatBubble(
                        _messages[index]['content']!,
                        isAI,
                      );
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
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isAI ? const Color(0xFF1E293B) : const Color(0xFF6366F1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(isAI ? 0 : 15),
            bottomRight: Radius.circular(isAI ? 15 : 0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Text(
          content,
          style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildInputArea(AppState appState) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: appState.t("Ask me anything...", "Niulize chochote..."),
                hintStyle: const TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _handleSend(appState),
            ),
          ),
          CircleAvatar(
            backgroundColor: const Color(0xFF6366F1),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: () => _handleSend(appState),
            ),
          ),
        ],
      ),
    );
  }
}