import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';

/// The Home / Education Hub screen.
/// 100% English by default. When the 🌐 icon is tapped, switches to 100% Amharic.
/// Designed with fully responsive components for all screen sizes.
class HomeScreen extends StatelessWidget {
  /// Callback to switch tabs from within cards/buttons on the home screen
  final void Function(int tabIndex)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppLanguage.isAmharicNotifier,
      builder: (context, isAmharic, _) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: _buildCustomHeader(context, isAmharic),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Headline
                  Text(
                    isAmharic
                        ? 'የእርስዎ ጤና። የእርስዎ እውቀት። የእርስዎ ምርጫ።'
                        : 'Your health. Your knowledge. Your choice.',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hero Highlight Card
                  _buildHeroCard(isAmharic),
                  const SizedBox(height: 14),

                  // Supporting description
                  Text(
                    isAmharic
                        ? 'ለኢትዮጵያውያን ወጣቶች የተዘጋጀ ታማኝና በቀላሉ የሚረዳ የሥነ-ተዋልዶ ጤና መረጃ ማዕከል፤ ስለ ጤናዎ በግልጽ ይማሩ።'
                        : 'Learn about sexual and reproductive health through trusted, easy-to-understand information designed for young people in Ethiopia.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Call-to-Action Buttons
                  _buildActionButtons(isAmharic),
                  const SizedBox(height: 28),

                  // Topic Categories Title
                  Text(
                    isAmharic
                        ? 'ምን ማወቅ ይፈልጋሉ?'
                        : 'What would you like to learn about?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAmharic
                        ? 'ከታች ከተዘረዘሩት ርእሶች አንዱን ይምረጡ'
                        : 'Select a topic below to begin exploring',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Responsive 2x2 Grid for Topic Exploration
                  _buildTopicGrid(isAmharic),
                  const SizedBox(height: 24),

                  // Interactive Tool Banner: Cycle Tracker
                  _buildCycleBanner(isAmharic),
                  const SizedBox(height: 24),

                  // Safe Clinic Helpline Notice
                  _buildHelplineCard(context, isAmharic),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Custom top navigation bar featuring the language switch toggle
  PreferredSizeWidget _buildCustomHeader(BuildContext context, bool isAmharic) {
    return AppBar(
      titleSpacing: 12,
      title: Row(
        children: [
          // App Logo loaded from registered assets
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.png',
              height: 34,
              width: 34,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'TenaWise',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                isAmharic ? 'ጥበብ ያለው ምርጫ' : 'Wise Choices',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Language Toggle: displays 🌐 in English, አማ in Amharic
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => AppLanguage.toggleLanguage(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                isAmharic ? 'አማ' : '🌐',
                style: TextStyle(
                  fontSize: isAmharic ? 13 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(bool isAmharic) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 160),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryContainer],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.spa,
              size: 160,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(
                  isAmharic
                      ? 'ደህንነቱ የተጠበቀ፣ ከአድሎ ነፃ ማዕከል'
                      : 'Safe, Stigma-Free Space',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isAmharic
                      ? 'ጥያቄዎችን ይጠይቁ፣ የወር አበባዎን ይከታተሉ እንዲሁም የጤና መረጃዎችን ያግኙ።'
                      : 'Ask questions, track cycles & explore healthcare options safely.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isAmharic) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => onNavigateToTab?.call(2), // Switch to Library
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(isAmharic ? 'ትምህርት ጀምር' : 'Start Learning'),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondaryContainer,
              foregroundColor: AppColors.onSecondaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => onNavigateToTab?.call(3), // Switch to AI Assistant
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.question_answer_outlined,
                  size: 18,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  isAmharic ? 'ጤና ዋይዝን ጠይቁ' : 'Ask TenaWise',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicGrid(bool isAmharic) {
    final topics = isAmharic
        ? [
            {
              'emoji': '🦠',
              'title': 'የአባለዘር በሽታዎች',
              'desc': 'ምልክቶች፣ ምርመራ፣ መከላከያ እና ህክምና።',
              'tab': 2,
            },
            {
              'emoji': '💊',
              'title': 'የእርግዝና መከላከያ',
              'desc': 'ዘዴዎች፣ ውጤታማነት እና የት እንደሚገኝ።',
              'tab': 2,
            },
            {
              'emoji': '🩸',
              'title': 'የወር አበባ ጤና',
              'desc': 'ዑደቶች፣ ንፅህና እና የቀን ስሌት።',
              'tab': 1,
            },
            {
              'emoji': '❤️',
              'title': 'የጾታ ጤና',
              'desc': 'ጤናማ ግንኙነቶች፣ ፈቃደኝነት እና ደህንነት።',
              'tab': 2,
            },
          ]
        : [
            {
              'emoji': '🦠',
              'title': 'STIs',
              'desc': 'Symptoms, testing, prevention and treatment.',
              'tab': 2,
            },
            {
              'emoji': '💊',
              'title': 'Contraception',
              'desc': 'Methods, effectiveness, myths and access.',
              'tab': 2,
            },
            {
              'emoji': '🩸',
              'title': 'Menstrual Health',
              'desc': 'Cycles, hygiene, PMS and tracking rhythms.',
              'tab': 1,
            },
            {
              'emoji': '❤️',
              'title': 'Sexual Health',
              'desc': 'Healthy relationships, consent & wellbeing.',
              'tab': 2,
            },
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final aspectRatio = isCompact ? 0.95 : 1.05;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: aspectRatio,
          ),
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final item = topics[index];
            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onNavigateToTab?.call(item['tab'] as int),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['emoji'] as String,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['desc'] as String,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          isAmharic ? 'ይመልከቱ' : 'Explore',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          size: 12,
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCycleBanner(bool isAmharic) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onNavigateToTab?.call(1), // Switch to Cycle Tracker
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.secondaryContainer),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.secondaryContainer,
              child: Icon(
                Icons.calendar_month,
                color: AppColors.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAmharic
                        ? 'የወር አበባ እና የዑደት አስሊ'
                        : 'Period & Cycle Calculator',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAmharic
                        ? 'የመራባት ቀናትንና ቀጣዩን ቀን በሚስጥር ያስሉ።'
                        : 'Calculate fertile windows and next arrival date privately.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open phone dialer for $phoneNumber')),
        );
      }
    }
  }

  Widget _buildHelplineCard(BuildContext context, bool isAmharic) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.support_agent, color: AppColors.secondary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAmharic
                          ? 'ነፃ ሚስጥራዊ የእርዳታ መስመሮች'
                          : 'Free Ethiopian Confidential Helplines',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAmharic
                          ? 'የድንገተኛ አደጋ (PEP በ72 ሰዓታት) ወይም የወጣቶች የጤና ምክር፡ ቁጥሮቹን በመንካት በቀጥታ ይደውሉ።'
                          : 'Emergency post-exposure (PEP within 72h) or youth counseling. Tap a number to dial directly:',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ActionChip(
                avatar: const Icon(Icons.phone_in_talk, size: 14, color: AppColors.primary),
                label: Text(
                  isAmharic ? '8335 (የወጣቶች ምክር)' : '8335 (Youth Hotline)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                backgroundColor: AppColors.surfaceContainerLowest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: () => _makePhoneCall('8335', context),
              ),
              const SizedBox(width: 8),
              ActionChip(
                avatar: const Icon(Icons.phone_in_talk, size: 14, color: AppColors.secondary),
                label: Text(
                  isAmharic ? '8044 (ድንገተኛ PEP)' : '8044 (Emergency PEP)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                backgroundColor: AppColors.surfaceContainerLowest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: () => _makePhoneCall('8044', context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
