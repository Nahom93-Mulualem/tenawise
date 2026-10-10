import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Ask TenaWise AI Mobile Assistant Screen.
/// Provides a confidential, judgment-free conversational Q&A interface for sexual health questions.
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [
    {
      'sender': 'assistant',
      'text':
          'ሰላም! I am your TenaWise educational assistant. You can ask me anything about STIs, contraception methods, menstrual health, or safe relationships in English or አማርኛ.',
      'time': 'Just now',
    },
    {
      'sender': 'user',
      'text':
          'Can an STI have no symptoms? I\'ve been feeling really anxious after an encounter two weeks ago.',
      'time': 'Just now',
    },
    {
      'sender': 'assistant',
      'text':
          'Yes, absolutely. Many sexually transmitted infections—such as Chlamydia, Gonorrhea, HPV, and early-stage HIV—can cause zero or completely unnoticeable symptoms, especially in the first few weeks.\n\nKey steps to take:\n1. Do not panic—most STIs are completely curable or manageable.\n2. Consider a confidential rapid test at a local health center or Marie Stopes clinic.\n3. If your exposure was within 72 hours, you can access PEP (Post-Exposure Prophylaxis) for HIV protection.',
      'time': 'Verified advice',
    },
  ];

  final List<String> _suggestedPrompts = [
    'What are the symptoms of HIV?',
    'How does emergency contraception work?',
    'Where can I find free condoms in Ethiopia?',
    'Is spotting normal with Depo-Provera?',
    'How to use Postpill correctly?',
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text.trim(),
        'time': 'Just now',
      });
      _textController.clear();
    });

    _scrollToBottom();

    // Simulated responsive AI guidance
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'assistant',
          'text': _generateKnowledgeResponse(text),
          'time': 'Verified advice',
        });
      });
      _scrollToBottom();
    });
  }

  String _generateKnowledgeResponse(String query) {
    final q = query.toLowerCase();
    if (q.contains('hiv') || q.contains('ኤችአይቪ')) {
      return 'HIV is a virus that affects the immune system. Early stages often feel like a mild flu or have no symptoms at all. In Ethiopia, rapid testing and modern ART treatment are completely free and confidential at all government health centers.';
    } else if (q.contains('contracept') || q.contains('መከላከያ') || q.contains('postpill') || q.contains('emergency')) {
      return 'Emergency contraceptive pills (such as Postinor-2) are most effective when taken within 72 hours (3 days) after unprotected sex. They prevent or delay ovulation. They are available over the counter at any local pharmacy.';
    } else if (q.contains('condom') || q.contains('ኮንዶም')) {
      return 'Condoms provide dual protection against both unintended pregnancy and STIs. Free condoms are widely available in Ethiopia at public youth centers, health centers, and through social marketing brands like Sensation.';
    } else {
      return 'Thank you for asking. Your sexual and reproductive wellness is essential. Remember to consult a youth-friendly healthcare professional at Marie Stopes or your nearest health center for personal clinical guidance.';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add({
        'sender': 'assistant',
        'text': 'Chat history cleared. All session data has been erased.',
        'time': 'New session',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Ask TenaWise (ጠይቁ)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _clearChat,
            icon: const Icon(Icons.history_toggle_off, size: 16, color: AppColors.onSurfaceVariant),
            label: const Text(
              'Clean Slate',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Privacy sanctuary status banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock, size: 14, color: AppColors.secondary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '100% Anonymous • No IP logged • RAM encrypted',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),

          // Suggested Prompts Carousel
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _suggestedPrompts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prompt = _suggestedPrompts[index];
                return ActionChip(
                  label: Text(prompt),
                  labelStyle: const TextStyle(fontSize: 11, color: AppColors.primary),
                  backgroundColor: AppColors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onPressed: () => _sendMessage(prompt),
                );
              },
            ),
          ),

          // Chat Stream Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return _buildChatBubble(msg['text']!, isUser, msg['time']!);
              },
            ),
          ),

          // Bottom Input Field
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser, String timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primaryContainer,
              child: Icon(Icons.psychology_alt, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser ? null : Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isUser ? Colors.white : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: TextStyle(
                      fontSize: 9,
                      color: isUser ? Colors.white70 : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.secondaryContainer,
              child: Icon(Icons.person, color: AppColors.onSecondaryContainer, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: AppColors.surface,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: _sendMessage,
                decoration: InputDecoration(
                  hintText: 'Ask confidentially (በግልፅ ይጠይቁ)...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.outline),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () => _sendMessage(_textController.text),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.arrow_upward, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
