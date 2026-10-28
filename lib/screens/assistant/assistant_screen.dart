import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/staggered_entrance.dart';
import '../../core/widgets/tactile_card.dart';
import 'chatbot_api_service.dart';

class _ChatMessageItem {
  final String sender; // 'user' or 'assistant'
  final String text;
  final String time;
  final String? category;
  final bool isUrgent;
  final List<String> followUps;
  final String? source;

  _ChatMessageItem({
    required this.sender,
    required this.text,
    required this.time,
    this.category,
    this.isUrgent = false,
    this.followUps = const [],
    this.source,
  });
}

/// Ask TenaWise Mobile Assistant Screen.
/// 100% English when English is selected; 100% Amharic when Amharic is selected.
/// Features:
/// - Trained SRH (Sexual & Reproductive Health) intelligence with Ethiopian youth context
/// - Hybrid Python AI backend with instant offline knowledge engine fallback
/// - Category badges & urgent PEP 72h / emergency alert badges
/// - Interactive follow-up suggestion chips under answers
/// - Staggered 3-dot bouncing typing indicator
/// - Spring-animated chat bubble entry (scale & slide)
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessageItem> _messages = [];
  bool _isTyping = false;

  final List<String> _suggestedPromptsEn = [
    'What are the symptoms of HIV?',
    'How does emergency contraception work?',
    'Where can I find free condoms in Ethiopia?',
    'Is spotting normal with Depo-Provera?',
    'How to use Postpill correctly?',
    'How to relieve painful period cramps?',
  ];

  final List<String> _suggestedPromptsAm = [
    'የኤች.አይ.ቪ ምልክቶች ምንድን ናቸው?',
    'ድንገተኛ የእርግዝና መከላከያ እንዴት ይሰራል?',
    'በኢትዮጵያ ነፃ ኮንዶም የት ይገኛል?',
    'የ3 ወር መርፌ የወር አበባን ያዛባል?',
    'Postpill እንዴት መወሰድ አለበት?',
    'የወር አበባ ቁርጠት ማስታገሻዎች ምንድን ናቸው?',
  ];

  @override
  void initState() {
    super.initState();
    _resetToGreeting(AppLanguage.isAmharic);
    ChatbotApiService.checkBackendStatus();
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
    _messages.add(
      _ChatMessageItem(
        sender: 'assistant',
        text: isAmharic
            ? 'ሰላም! እኔ የጤና ዋይዝ የትምህርት አጋርዎ ነኝ። ስለ አባለዘር በሽታዎች፣ የወሊድ መከላከያ ዘዴዎች (Postpill፣ የ3 ወር መርፌ፣ ጃዴል) ወይም የወር አበባ ጤና ማንኛውንም ጥያቄ በነፃነት እና በሚስጥር መጠየቅ ይችላሉ።'
            : 'Hello! I am your TenaWise educational companion. You can ask me anything about STIs, contraception methods (Postpill, Depo-Provera, Implants), menstrual health, or safe relationships confidentially.',
        time: isAmharic ? 'አሁን' : 'Just now',
        category: isAmharic ? 'የስነ-ተዋልዶ ጤና አጋር' : 'SRH Companion',
        source: isAmharic ? 'የተረጋገጠ መረጃ' : 'Verified Clinical Advice',
        followUps: isAmharic
            ? [
                'ድንገተኛ የእርግዝና መከላከያ እንዴት ይሰራል?',
                'የኤች.አይ.ቪ ምልክቶች ምንድን ናቸው?',
                'የ3 ወር መርፌ የወር አበባን ያዛባል?'
              ]
            : [
                'How does Postinor-2 work?',
                'What are the symptoms of HIV?',
                'Is spotting normal with Depo-Provera?'
              ],
      ),
    );
  }

  Future<void> _sendMessage(String text, bool isAmharic) async {
    if (text.trim().isEmpty) return;
    final userMessage = text.trim();

    setState(() {
      _messages.add(_ChatMessageItem(
        sender: 'user',
        text: userMessage,
        time: isAmharic ? 'አሁን' : 'Just now',
      ));
      _textController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Call Hybrid API (Python backend -> fallback to offline SrhKnowledgeEngine)
    // Build history list from current messages to give the AI conversation context
    final historyForApi = _messages
        .where((m) => m.sender == 'user' || m.sender == 'assistant')
        .map((m) => {'role': m.sender == 'user' ? 'user' : 'assistant', 'content': m.text})
        .toList();

    final result = await ChatbotApiService.sendMessage(
      message: userMessage,
      isAmharic: isAmharic,
      history: historyForApi,
    );

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessageItem(
        sender: 'assistant',
        text: result.text,
        time: result.source,
        category: result.category,
        isUrgent: result.isUrgent,
        followUps: result.followUpQuestions,
        source: result.source,
      ));
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
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
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
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
                    ValueListenableBuilder<String>(
                      valueListenable: ChatbotApiService.statusNotifier,
                      builder: (context, status, _) {
                        Color dotColor = Colors.grey;
                        String statusText = isAmharic ? 'ከመስመር ውጭ ሞተር' : 'Offline Engine';
                        if (status == 'gemini') {
                          dotColor = Colors.green;
                          statusText = isAmharic ? 'ጀሚኒ AI ተገናኝቷል' : 'Gemini 2.5 Flash Online';
                        } else if (status == 'local_server') {
                          dotColor = Colors.amber.shade800;
                          statusText = isAmharic ? 'ሎካል ሰርቨር (ቁልፍ ይጎድላል)' : 'Local Server (No Key)';
                        }
                        return Row(
                          children: [
                            Container(
                              width: 6.5,
                              height: 6.5,
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: dotColor,
                              ),
                            ),
                          ],
                        );
                      },
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
                // Suggested Prompts Carousel
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
                      final isUser = msg.sender == 'user';
                      return _AnimatedChatBubble(
                        key: ValueKey('msg_${index}_${msg.text.hashCode}'),
                        item: msg,
                        isUser: isUser,
                        isAmharic: isAmharic,
                        onFollowUpSelected: (q) => _sendMessage(q, isAmharic),
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
                hintText: isAmharic
                    ? 'ስለ ስነ-ተዋልዶ ጤና በነፃነት ይጠይቁ...'
                    : 'Ask any SRH question confidentially...',
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

/// Spring-animated chat bubble with category badge, urgent clinical banner,
/// and interactive follow-up question pills
class _AnimatedChatBubble extends StatefulWidget {
  final _ChatMessageItem item;
  final bool isUser;
  final bool isAmharic;
  final ValueChanged<String> onFollowUpSelected;

  const _AnimatedChatBubble({
    super.key,
    required this.item,
    required this.isUser,
    required this.isAmharic,
    required this.onFollowUpSelected,
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

  Future<void> _callHotline() async {
    final uri = Uri.parse('tel:8335');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
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
        child: Column(
          crossAxisAlignment:
              widget.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
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
                          : (widget.item.isUrgent
                              ? const Color(0xFFFFF4F2)
                              : AppColors.surfaceContainerLowest),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(widget.isUser ? 18 : 4),
                        bottomRight: Radius.circular(widget.isUser ? 4 : 18),
                      ),
                      border: widget.isUser
                          ? null
                          : Border.all(
                              color: widget.item.isUrgent
                                  ? const Color(0xFFFFB4AB)
                                  : AppColors.outlineVariant.withValues(alpha: 0.35),
                              width: widget.item.isUrgent ? 1.2 : 1.0,
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
                        // Category Badge
                        if (!widget.isUser && widget.item.category != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: widget.item.isUrgent
                                  ? const Color(0xFFFFDAD6)
                                  : AppColors.secondaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.item.isUrgent
                                      ? Icons.warning_amber_rounded
                                      : Icons.verified_user_outlined,
                                  size: 11,
                                  color: widget.item.isUrgent
                                      ? const Color(0xFFBA1A1A)
                                      : AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.item.category!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: widget.item.isUrgent
                                        ? const Color(0xFFBA1A1A)
                                        : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Main Formatted Text (Eliminates raw ** and renders bold & bullets cleanly)
                        _FormattedMarkdownText(
                          text: widget.item.text,
                          isUser: widget.isUser,
                        ),

                        // Urgent Action Button
                        if (!widget.isUser && widget.item.isUrgent) ...[
                          const SizedBox(height: 10),
                          TactileCard(
                            pressedScale: 0.95,
                            onTap: _callHotline,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFBA1A1A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.phone_in_talk,
                                      color: Colors.white, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.isAmharic
                                        ? 'በነፃ 8335 ይደውሉ'
                                        : 'Call 8335 Free Helpline',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 6),
                        // Timestamp and source
                        Text(
                          widget.item.time,
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

            // Suggested Follow-up chips under assistant answers
            if (!widget.isUser && widget.item.followUps.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 36, top: 6, bottom: 4),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.item.followUps.map((q) {
                    return TactileCard(
                      pressedScale: 0.94,
                      onTap: () => widget.onFollowUpSelected(q),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.subdirectory_arrow_right_rounded,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              q,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 15,
                ),
              ),
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

/// Renders markdown-like text with clean typography, eliminating raw ** asterisks
/// and formatting bold text, bullet points, and numbered lists cleanly.
class _FormattedMarkdownText extends StatelessWidget {
  final String text;
  final bool isUser;

  const _FormattedMarkdownText({
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          height: 1.45,
          color: Colors.white,
        ),
      );
    }

    final lines = text.split('\n');
    final List<Widget> widgets = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 5));
        continue;
      }

      final isBullet = line.trimLeft().startsWith('•') ||
          line.trimLeft().startsWith('- ') ||
          line.trimLeft().startsWith('* ');

      widgets.add(
        Padding(
          padding: EdgeInsets.only(
            top: 2,
            bottom: 2,
            left: isBullet ? 4.0 : 0.0,
          ),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                height: 1.48,
                color: AppColors.onSurface,
              ),
              children: _parseSpans(line),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  List<InlineSpan> _parseSpans(String line) {
    final List<InlineSpan> spans = [];
    final boldPattern = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in boldPattern.allMatches(line)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: line.substring(lastIndex, match.start),
          style: const TextStyle(color: AppColors.onSurface),
        ));
      }
      final boldText = match.group(1) ?? '';
      spans.add(TextSpan(
        text: boldText,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < line.length) {
      spans.add(TextSpan(
        text: line.substring(lastIndex),
        style: const TextStyle(color: AppColors.onSurface),
      ));
    }

    return spans;
  }
}
