import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({Key? key}) : super(key: key);

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final String apiKey = 'AIzaSyCTmf2trLBuQqqLwMacvI3hJ0AHUj6zkdc';

  // Store conversation as list of maps {sender: 'user'|'ai', text: '...'}
  List<Map<String, String>> messages = [];

  bool _loading = false;

  void _askAI() async {
    final question = _questionController.text.trim();
    if (question.isEmpty || _loading) return;

    // Add user message
    setState(() {
      messages.add({'sender': 'user', 'text': question});
      _loading = true;
    });

    _questionController.clear();

    // Scroll to bottom after new message
    _scrollToBottom();

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent?key=AIzaSyCTmf2trLBuQqqLwMacvI3hJ0AHUj6zkdc',
      );

      final requestBody = jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {
                "text":
                    "أنت مساعد ذكي مبرمج للرد فقط على التحيات أو الأسئلة المتعلقة بمجالات الزراعة، الري، والطاقة الشمسية. السؤال هو: \'{$question}\' إذا كان السؤال تحية، قم بالرد بطريقة لطيفة وودية. إذا كان السؤال يتعلق بأي موضوع ضمن الزراعة أو الري أو الطاقة الشمسية، قدم إجابة واضحة ومفيدة. أما إذا كان السؤال خارج هذه المواضيع، فكن واضحًا وأجب بجملة واحدة فقط: \'هذا خارج نطاق اختصاصي\'. يرجى الالتزام بهذا بصرامة.'",
              },
            ],
          },
        ],
        "generationConfig": {
          "temperature": 0.7,
          "topK": 64,
          "topP": 0.95,
          "maxOutputTokens": 1024,
          "responseMimeType": "text/plain",
        },
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            'لا توجد استجابة';

        setState(() {
          messages.add({'sender': 'ai', 'text': reply});
        });
      } else {
        setState(() {
          messages.add({
            'sender': 'ai',
            'text': '❌ فشل الاتصال: ${response.statusCode}\n${response.body}',
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({'sender': 'ai', 'text': '⚠️ حدث خطأ: $e'});
      });
    } finally {
      setState(() {
        _loading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Map<String, String> message) {
    final isUser = message['sender'] == 'user';
    final alignment =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bgColor = isUser ? Colors.green.shade300 : Colors.orange.shade100;
    final textColor = Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Text(
              message['text'] ?? '',
              style: TextStyle(color: textColor, fontSize: 16),
              textAlign: isUser ? TextAlign.right : TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' مساعد الذكاء الاصطناعي'),
        backgroundColor: Colors.green.shade700,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(messages[index]);
                },
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: CircularProgressIndicator(),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _questionController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _askAI(),
                      decoration: InputDecoration(
                        hintText: 'اكتب سؤالك هنا...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.green.shade50,
                      ),
                      maxLines: null,
                      enabled: !_loading,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _loading ? null : _askAI,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
