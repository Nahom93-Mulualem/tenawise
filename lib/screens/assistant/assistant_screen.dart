import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';

/// Ask TenaWise Mobile Assistant Screen.
/// 100% English when English is selected; 100% Amharic when Amharic is selected.
/// Responsive layout with scroll-to-bottom and clean slate clearing.
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [];

  final List<String> _suggestedPromptsEn = [
    'What are the symptoms of HIV?',
    'How does emergency contraception work?',
    'Where can I find free condoms in Ethiopia?',
    'Is spotting normal with Depo-Provera?',
    'How to use Postpill correctly?',
  ];

  final List<String> _suggestedPromptsAm = [
    'የኤች.አይ.ቪ ምልክቶች ምንድን ናቸው?',
    'ድንገተኛ የእርግዝና መከላከያ እንዴት ይሰራል?',
    'በኢትዮጵያ ነፃ ኮንዶም የት ይገኛል?',
    'የ3 ወር መርፌ የወር አበባን ያዛባል?',
    'Postpill እንዴት መወሰድ አለበት?',
  ];

  @override
  void initState() {
    super.initState();
    _resetToGreeting(AppLanguage.isAmharic);
  }

  void _resetToGreeting(bool isAmharic) {
    _messages.clear();
    _messages.add({
      'sender': 'assistant',
      'text': isAmharic
          ? 'ሰላም! እኔ የጤና ዋይዝ የትምህርት አጋርዎ ነኝ። ስለ አባለዘር በሽታዎች፣ የወሊድ መከላከያ ዘዴዎች ወይም የወር አበባ ጤና ማንኛውንም ጥያቄ በነፃነት መጠየቅ ይችላሉ።'
          : 'Hello! I am your TenaWise educational companion. You can ask me anything about STIs, contraception methods, menstrual health, or safe relationships confidentially.',
      'time': isAmharic ? 'አሁን' : 'Just now',
    });
  }

  void _sendMessage(String text, bool isAmharic) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text.trim(),
        'time': isAmharic ? 'አሁን' : 'Just now',
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
          'text': _generateKnowledgeResponse(text, isAmharic),
          'time': isAmharic ? 'የተረጋገጠ መረጃ' : 'Verified advice',
        });
      });
      _scrollToBottom();
    });
  }

  String _generateKnowledgeResponse(String query, bool isAmharic) {
    final q = query.toLowerCase();

    if (isAmharic) {
      if (q.contains('hiv') || q.contains('ኤች.አይ.ቪ') || q.contains('ምልክት')) {
        return 'ኤች.አይ.ቪ በሰውነት በሽታ የመከላከል ስርዓት ላይ ተጽእኖ የሚያሳድር ቫይረስ ነው። በመጀመሪያዎቹ ሳምንታት ምንም ምልክት ላያሳይ ይችላል። በኢትዮጵያ ውስጥ በሁሉም የመንግስት ጤና ጣቢያዎች ነፃ ፈጣን ምርመራ እና የART ህክምና በነፃ ይሰጣል። ድንገተኛ ንክኪ ካጋጠመ በ72 ሰዓት ውስጥ PEP መውሰድ ይቻላል።';
      } else if (q.contains('spotting') || q.contains('መርፌ') || q.contains('depo') || q.contains('ደፈረሰ')) {
        return 'የ3 ወር መርፌ (Depo-Provera) በሚወስዱበት የመጀመሪያዎቹ ወራት ውስጥ አልፎ አልፎ ደም መፍሰስ ወይም የወር አበባ መዛባት የተለመደ ነው። ይህ ሆርሞኑ ሰውነትን ሲላመድ የሚከሰት ሲሆን በአብዛኛው ከጥቂት ወራት በኋላ ይስተካከላል።';
      } else if (q.contains('መከላከያ') || q.contains('postpill') || q.contains('ድንገተኛ') || q.contains('emergency')) {
        return 'ድንገተኛ የወሊድ መከላከያ እንክብል (እንደ Postinor-2) ጥንቃቄ ከጎደለው ግንኙነት በኋላ በ72 ሰዓታት (3 ቀናት) ውስጥ ሲወሰድ ከፍተኛ ውጤታማ ነው። እንክብሉ እንቁላል እንዳይወጣ በማዘግየት እርግዝናን ይከላከላል። በማንኛውም ፋርማሲ ያለ ሀኪም ማዘዣ ይገኛል።';
      } else if (q.contains('ኮንዶም') || q.contains('ነፃ')) {
        return 'ኮንዶም ከአባለዘር በሽታዎች እና ካልተፈለገ እርግዝና ድርብ ጥበቃ ይሰጣል። በሁሉም የጤና ጣቢያዎች፣ በወጣቶች ማዕከላት፣ በማሪ ስቶፕስ እና በFGAE ክሊኒኮች በነፃ ወይም በዝቅተኛ ዋጋ ይገኛል።';
      } else if (q.contains('ህመም') || q.contains('ቁርጠት') || q.contains('cramp')) {
        return 'የወር አበባ ቁርጠት በማህፀን መኮማተር ምክንያት የሚከሰት ነው። ሞቅ ያለ ውሃ መጠጣት፣ ሆድ ላይ ሞቅ ያለ ጨርቅ ወይም የውሃ ከረጢት ማድረግ እና ቀላል እንቅስቃሴዎችን ማድረግ ህመሙን ይቀንሳል።';
      } else {
        return 'ስለ ጠየቁን እናመሰግናለን። ለግል ክሊኒካዊ ምክር በአቅራቢያዎ ወደሚገኝ ጤና ጣቢያ፣ ማሪ ስቶፕስ (Marie Stopes) ወይም FGAE ክሊኒክ ጎራ ብለው የጤና ባለሙያዎችን ማማከር ይችላሉ። ድንገተኛ ምክር ከፈለጉ በነፃ የስልክ መስመር 8335 ይደውሉ።';
      }
    } else {
      if (q.contains('hiv') || q.contains('symptom')) {
        return 'HIV attacks the body\'s immune system. Many people experience zero symptoms during early stages. In Ethiopia, rapid testing and modern ART treatment are 100% free and confidential at all government health facilities. If exposure occurred within 72 hours, visit a clinic for PEP.';
      } else if (q.contains('depo') || q.contains('spotting') || q.contains('bleeding')) {
        return 'Yes, irregular bleeding or light spotting is completely normal during the first few months of using Depo-Provera (the 3-month injectable). The hormone progestin thins the uterine lining. Over time, periods typically become much lighter or pause entirely.';
      } else if (q.contains('contracept') || q.contains('emergency') || q.contains('postpill')) {
        return 'Emergency contraceptive pills (such as Postinor-2) are most effective when taken as soon as possible, within 72 hours (3 days) after unprotected intercourse. They prevent pregnancy by delaying ovulation. They do not terminate an existing pregnancy and are available over the counter.';
      } else if (q.contains('condom') || q.contains('free')) {
        return 'Condoms provide essential dual protection against both STIs and unintended pregnancy. In Ethiopia, free condoms are distributed at public health centers, youth drop-in centers, university health posts, and through organizations like DKT (Sensation brand) at very affordable prices.';
      } else if (q.contains('cramp') || q.contains('pain') || q.contains('period')) {
        return 'Menstrual cramps are caused by natural uterine contractions. Applying a warm heating pad to your lower abdomen, staying hydrated, engaging in light stretching, and taking mild over-the-counter pain relievers can provide relief.';
      } else {
        return 'Thank you for your question. TenaWise provides peer-reviewed educational guidance. For confidential clinical care in Ethiopia, visit your nearest youth-friendly clinic, Marie Stopes center, or dial free youth hotline 8335.';
      }
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

  void _clearChat(bool isAmharic) {
    setState(() {
      _resetToGreeting(isAmharic);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppLanguage.isAmharicNotifier,
      builder: (context, isAmharic, _) {
        final prompts = isAmharic ? _suggestedPromptsAm : _suggestedPromptsEn;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            title: Text(
              isAmharic ? 'ጤና ዋይዝን ጠይቁ' : 'Ask TenaWise',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => _clearChat(isAmharic),
                icon: const Icon(Icons.history_toggle_off,
                    size: 16, color: AppColors.onSurfaceVariant),
                label: Text(
                  isAmharic ? 'ታሪክ አጽዳ' : 'Clean Slate',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Suggested Prompts Carousel
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: prompts.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final prompt = prompts[index];
                      return ActionChip(
                        label: Text(prompt),
                        labelStyle: const TextStyle(
                            fontSize: 11, color: AppColors.primary),
                        backgroundColor: AppColors.surfaceContainerLowest,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        onPressed: () => _sendMessage(prompt, isAmharic),
                      );
                    },
                  ),
                ),

                // Chat Stream Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg['sender'] == 'user';
                      return _buildChatBubble(
                          msg['text']!, isUser, msg['time']!);
                    },
                  ),
                ),

                // Bottom Message Input Field
                _buildMessageInputField(isAmharic),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatBubble(String text, bool isUser, String timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                color: isUser
                    ? AppColors.primary
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color:
                            AppColors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
              child: Icon(Icons.person,
                  color: AppColors.onSecondaryContainer, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInputField(bool isAmharic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: (txt) => _sendMessage(txt, isAmharic),
              decoration: InputDecoration(
                hintText:
                    isAmharic ? 'በነፃነት ይጠይቁ...' : 'Ask confidentially...',
                hintStyle:
                    const TextStyle(fontSize: 13, color: AppColors.outline),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () => _sendMessage(_textController.text, isAmharic),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.arrow_upward, size: 20),
          ),
        ],
      ),
    );
  }
}
