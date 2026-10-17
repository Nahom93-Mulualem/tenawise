import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/staggered_entrance.dart';
import '../../core/widgets/tactile_card.dart';

/// Ask TenaWise Mobile Assistant Screen.
/// 100% English when English is selected; 100% Amharic when Amharic is selected.
/// Features Apple & Emil Kowalski inspired chat animations:
/// - Staggered 3-dot bouncing typing indicator
/// - Spring-animated chat bubble entry (scale & slide)
/// - Tactile interactive prompt suggestion pills
/// - Spring press feedback on send button
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

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

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _resetToGreeting(bool isAmharic) {
    _messages.clear();
    _isTyping = false;
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
    final userMessage = text.trim();

    setState(() {
      _messages.add({
        'sender': 'user',
        'text': userMessage,
        'time': isAmharic ? 'አሁን' : 'Just now',
      });
      _textController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulated responsive AI guidance with realistic typing cadence
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add({
          'sender': 'assistant',
          'text': _generateKnowledgeResponse(userMessage, isAmharic),
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
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
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
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isAmharic ? 'ጤና ዋይዝን ጠይቁ' : 'Ask TenaWise',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      isAmharic ? 'ሚስጥራዊ የትምህርት አጋር' : 'Confidential AI Companion',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TactileCard(
                  pressedScale: 0.92,
                  onTap: () => _clearChat(isAmharic),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.restart_alt_rounded,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAmharic ? 'አጽዳ' : 'Reset',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Suggested Prompts Carousel with TactileCards
                StaggeredEntrance(
                  index: 0,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: prompts.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final prompt = prompts[index];
                        return TactileCard(
                          pressedScale: 0.94,
                          onTap: () => _sendMessage(prompt, isAmharic),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.outlineVariant.withValues(alpha: 0.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                prompt,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Chat Stream Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isTyping && index == _messages.length) {
                        return const _TypingIndicatorBubble();
                      }

                      final msg = _messages[index];
                      final isUser = msg['sender'] == 'user';
                      return _AnimatedChatBubble(
                        key: ValueKey('msg_${index}_${msg['text'].hashCode}'),
                        text: msg['text']!,
                        isUser: isUser,
                        timestamp: msg['time']!,
                      );
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

  Widget _buildMessageInputField(bool isAmharic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: (txt) => _sendMessage(txt, isAmharic),
              decoration: InputDecoration(
                hintText: isAmharic ? 'በነፃነት ይጠይቁ...' : 'Ask confidentially...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.outline),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          TactileCard(
            pressedScale: 0.90,
            onTap: () => _sendMessage(_textController.text, isAmharic),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Spring-animated chat bubble that glides up and scales smoothly
class _AnimatedChatBubble extends StatefulWidget {
  final String text;
  final bool isUser;
  final String timestamp;

  const _AnimatedChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  @override
  State<_AnimatedChatBubble> createState() => _AnimatedChatBubbleState();
}

class _AnimatedChatBubbleState extends State<_AnimatedChatBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment:
                  widget.isUser ? Alignment.bottomRight : Alignment.bottomLeft,
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisAlignment:
              widget.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!widget.isUser) ...[
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(bottom: 2),
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.isUser
                      ? AppColors.primary
                      : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(widget.isUser ? 18 : 4),
                    bottomRight: Radius.circular(widget.isUser ? 4 : 18),
                  ),
                  border: widget.isUser
                      ? null
                      : Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.35),
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: widget.isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: widget.isUser ? Colors.white : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.timestamp,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: widget.isUser
                            ? Colors.white70
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.isUser) ...[
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(bottom: 2),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.onSecondaryContainer,
                  size: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bouncing 3-dot typing indicator bubble for incoming assistant responses
class _TypingIndicatorBubble extends StatefulWidget {
  const _TypingIndicatorBubble();

  @override
  State<_TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<_TypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Staggered sine oscillation
        final progress = (_controller.value - (index * 0.18)) % 1.0;
        final bounce = -6.0 * (progress < 0.5 ? progress * 2 : (1 - progress) * 2);

        return Transform.translate(
          offset: Offset(0, bounce),
          child: Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.75),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 15,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                _buildDot(1),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
