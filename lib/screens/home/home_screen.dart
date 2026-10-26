import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/language_switch.dart';
import '../../core/widgets/staggered_entrance.dart';
import '../../core/widgets/tactile_card.dart';

/// The Home / Education Hub screen.
/// 100% English by default. When the 🌐 icon is tapped, switches to 100% Amharic.
/// Designed with Apple Human Interface & Emil Kowalski design engineering principles:
/// - Tactile spring squash on tap (0.97x)
/// - Cascading staggered entrance animations
/// - Layered visual hierarchy and refined micro-details
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
                  // Staggered Item 0: Headline
                  StaggeredEntrance(
                    index: 0,
                    child: Text(
                      isAmharic
                          ? 'የእርስዎ ጤና። የእርስዎ እውቀት። የእርስዎ ምርጫ።'
                          : 'Your health. Your knowledge. Your choice.',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                        height: 1.22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Staggered Item 1: Hero Highlight Card
                  StaggeredEntrance(
                    index: 1,
                    child: _buildHeroCard(isAmharic),
                  ),
                  const SizedBox(height: 14),

                  // Staggered Item 2: Supporting Description & CTAs
                  StaggeredEntrance(
                    index: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAmharic
                              ? 'ለኢትዮጵያውያን ወጣቶች የተዘጋጀ ታማኝና በቀላሉ የሚረዳ የሥነ-ተዋልዶ ጤና መረጃ ማዕከል፤ ስለ ጤናዎ በግልጽ ይማሩ።'
                              : 'Learn about sexual and reproductive health through trusted, easy-to-understand information designed for young people in Ethiopia.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActionButtons(isAmharic),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Staggered Item 3: Topic Section Header
                  StaggeredEntrance(
                    index: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAmharic
                              ? 'ምን ማወቅ ይፈልጋሉ?'
                              : 'What would you like to learn about?',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: -0.3,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Staggered Item 4: Responsive 2x2 Grid for Topic Exploration
                  StaggeredEntrance(
                    index: 4,
                    child: _buildTopicGrid(isAmharic),
                  ),
                  const SizedBox(height: 24),

                  // Staggered Item 5: Interactive Tool Banner: Cycle Tracker
                  StaggeredEntrance(
                    index: 5,
                    child: _buildCycleBanner(isAmharic),
                  ),
                  const SizedBox(height: 24),

                  // Staggered Item 6: Safe Clinic Helpline Notice
                  StaggeredEntrance(
                    index: 6,
                    child: _buildHelplineCard(context, isAmharic),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Custom top navigation bar featuring the tactile language switch toggle
  PreferredSizeWidget _buildCustomHeader(BuildContext context, bool isAmharic) {
    return AppBar(
      titleSpacing: 12,
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Row(
        children: [
          // Interactive App Logo with rounded squircle & spring press feedback
          TactileCard(
            pressedScale: 0.88,
            onTap: () => onNavigateToTab?.call(3),
            borderRadius: BorderRadius.circular(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logo.png',
                height: 36,
                width: 36,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 20,
                  ),
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
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                isAmharic ? 'ጥበብ ያለው ምርጫ' : 'Wise Choices',
                style: const TextStyle(
                  fontSize: 11,
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
          padding: const EdgeInsets.only(right: 14.0),
          child: LanguageSegmentedSwitch(isAmharic: isAmharic),
        ),
      ],
    );
  }

  /// Apple HIG styled Hero Card with depth and spring tap feedback
  Widget _buildHeroCard(bool isAmharic) {
    return TactileCard(
      pressedScale: 0.98,
      onTap: () => onNavigateToTab?.call(2), // Switch to Library
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 165),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryContainer,
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              bottom: -15,
              child: Icon(
                Icons.spa,
                size: 155,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subtle glass security pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAmharic
                              ? 'ሙሉ በሙሉ ሚስጥራዊ • ከአድሎ ነፃ'
                              : '100% Confidential • Stigma-Free',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isAmharic
                        ? 'ደህንነቱ የተጠበቀ ማዕከል'
                        : 'Safe, Stigma-Free Space',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAmharic
                        ? 'ጥያቄዎችን ይጠይቁ፣ የወር አበባዎን ይከታተሉ እንዲሁም የጤና መረጃዎችን ያግኙ።'
                        : 'Ask questions, track cycles & explore healthcare options safely.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        isAmharic ? 'ማዕከሉን ያስሱ' : 'Explore Knowledge Hub',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Modern tactile buttons with spring reaction
  Widget _buildActionButtons(bool isAmharic) {
    return Column(
      children: [
        TactileCard(
          pressedScale: 0.98,
          onTap: () => onNavigateToTab?.call(2), // Switch to Library
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.24),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isAmharic ? 'ትምህርት ጀምር' : 'Start Learning',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        TactileCard(
          pressedScale: 0.98,
          onTap: () => onNavigateToTab?.call(3), // Switch to AI Assistant
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  isAmharic ? 'ጤና ዋይዝን ጠይቁ' : 'Ask TenaWise AI',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.onSecondaryContainer,
                  ),
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
              'podColor': const Color(0xFFFFE8E4),
              'title': 'የአባለዘር በሽታዎች',
              'desc': 'ምልክቶች፣ ምርመራ፣ መከላከያ እና ህክምና።',
              'tab': 2,
            },
            {
              'emoji': '💊',
              'podColor': const Color(0xFFE4F6F1),
              'title': 'የእርግዝና መከላከያ',
              'desc': 'ዘዴዎች፣ ውጤታማነት እና የት እንደሚገኝ።',
              'tab': 2,
            },
            {
              'emoji': '🩸',
              'podColor': const Color(0xFFFFEBF0),
              'title': 'የወር አበባ ጤና',
              'desc': 'ዑደቶች፣ ንፅህና እና የቀን ስሌት።',
              'tab': 1,
            },
            {
              'emoji': '❤️',
              'podColor': const Color(0xFFF0EBFC),
              'title': 'የጾታ ጤና',
              'desc': 'ጤናማ ግንኙነቶች፣ ፈቃደኝነት እና ደህንነት።',
              'tab': 2,
            },
          ]
        : [
            {
              'emoji': '🦠',
              'podColor': const Color(0xFFFFE8E4),
              'title': 'STIs',
              'desc': 'Symptoms, testing, prevention and treatment.',
              'tab': 2,
            },
            {
              'emoji': '💊',
              'podColor': const Color(0xFFE4F6F1),
              'title': 'Contraception',
              'desc': 'Methods, effectiveness, myths and access.',
              'tab': 2,
            },
            {
              'emoji': '🩸',
              'podColor': const Color(0xFFFFEBF0),
              'title': 'Menstrual Health',
              'desc': 'Cycles, hygiene, PMS and tracking rhythms.',
              'tab': 1,
            },
            {
              'emoji': '❤️',
              'podColor': const Color(0xFFF0EBFC),
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
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final item = topics[index];
            return TactileCard(
              pressedScale: 0.96,
              onTap: () => onNavigateToTab?.call(item['tab'] as int),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Soft tinted icon pod
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: item['podColor'] as Color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            item['emoji'] as String,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: -0.2,
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
                            height: 1.3,
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
                          Icons.arrow_forward_rounded,
                          size: 13,
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

  /// Interactive Cycle Tracker Banner with live indicator dot and tactile feedback
  Widget _buildCycleBanner(bool isAmharic) {
    return TactileCard(
      pressedScale: 0.98,
      onTap: () => onNavigateToTab?.call(1), // Switch to Cycle Tracker
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.secondaryContainer,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.onSecondaryContainer,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Active tracking indicator
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isAmharic
                              ? 'የወር አበባ እና የዑደት አስሊ'
                              : 'Period & Cycle Calculator',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isAmharic
                        ? 'የመራባት ቀናትንና ቀጣዩን ቀን በሚስጥር ያስሉ።'
                        : 'Calculate fertile windows and next arrival date privately.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
              size: 24,
            ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
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
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TactileCard(
                  pressedScale: 0.94,
                  onTap: () => _makePhoneCall('8335', context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_in_talk, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isAmharic ? '8335 (ምክር)' : '8335 (Youth)',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TactileCard(
                  pressedScale: 0.94,
                  onTap: () => _makePhoneCall('8044', context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_in_talk, size: 14, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isAmharic ? '8044 (PEP)' : '8044 (PEP)',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
