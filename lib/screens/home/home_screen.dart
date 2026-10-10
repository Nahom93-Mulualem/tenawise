import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// The Home / Education Hub screen.
/// Serves as the landing dashboard welcoming Ethiopian youth with
/// evidence-based reproductive health information in both English and Amharic.
class HomeScreen extends StatelessWidget {
  /// Callback to switch tabs from within cards/buttons on the home screen
  final void Function(int tabIndex)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildCustomHeader(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Evidence-informed Pill Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user_outlined, size: 16, color: AppColors.secondary),
                  SizedBox(width: 6),
                  Text(
                    'Evidence-informed • በማስረጃ የተደገፈ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Bilingual Headline
            const Text(
              'Your health. Your knowledge. Your choice.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'የእርስዎ ጤና። የእርስዎ እውቀት። የእርስዎ ምርጫ።',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 16),

            // Hero Highlight Card
            _buildHeroCard(),
            const SizedBox(height: 14),

            // Supporting description
            const Text(
              'Learn about sexual and reproductive health through trusted, easy-to-understand information designed for young people in Ethiopia.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Quick Call-to-Action Buttons
            _buildActionButtons(),
            const SizedBox(height: 28),

            // Topic Categories Title
            const Text(
              'What would you like to learn about?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Text(
              'ምን ማወቅ ይፈልጋሉ?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),

            // 2x2 Grid for Topic Exploration
            _buildTopicGrid(),
            const SizedBox(height: 24),

            // Interactive Tool Banner: Cycle Tracker
            _buildCycleBanner(),
            const SizedBox(height: 24),

            // Safe Clinic Hotline Notice
            _buildHelplineCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// Custom top navigation bar matching the Stitch layout
  PreferredSizeWidget _buildCustomHeader(BuildContext context) {
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
                child: const Icon(Icons.favorite, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TenaWise',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'ጤናማ እውቀት፣ ጥበብ ያለው ምርጫ',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Quick Privacy Exit Button (ደህንነቴ)
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(0, 34),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quick Exit / ደህንነቴ activated for privacy.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, size: 14),
                SizedBox(width: 4),
                Text('ደህንነቴ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryContainer,
          ],
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline, size: 13, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        '100% Anonymous & Confidential',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Safe, Stigma-Free Space',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ask questions, track cycles & explore healthcare options safely.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => onNavigateToTab?.call(2), // Switch to Library
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Start Learning (ትምህርት ጀምር)'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => onNavigateToTab?.call(3), // Switch to AI Assistant
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 18, color: AppColors.secondary),
                SizedBox(width: 8),
                Text(
                  'Ask TenaWise AI (አስስ)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicGrid() {
    final topics = [
      {
        'emoji': '🦠',
        'title': 'STIs',
        'amharic': 'የአባለዘር በሽታዎች',
        'desc': 'Symptoms, testing, prevention and treatment.',
        'tab': 2,
      },
      {
        'emoji': '💊',
        'title': 'Contraception',
        'amharic': 'የእርግዝና መከላከያ',
        'desc': 'Methods, effectiveness, myths and access.',
        'tab': 2,
      },
      {
        'emoji': '🩸',
        'title': 'Menstrual Health',
        'amharic': 'የወር አበባ ጤና',
        'desc': 'Cycles, hygiene, PMS and tracking rhythms.',
        'tab': 1,
      },
      {
        'emoji': '❤️',
        'title': 'Sexual Health',
        'amharic': 'የጾታ ጤና',
        'desc': 'Healthy relationships, consent & wellbeing.',
        'tab': 2,
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.05,
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
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['emoji'] as String, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 6),
                    Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      item['amharic'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
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
                const Row(
                  children: [
                    Text(
                      'Explore',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 12, color: AppColors.secondary),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCycleBanner() {
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
        child: const Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.secondaryContainer,
              child: Icon(Icons.calendar_month, color: AppColors.onSecondaryContainer),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Period & Cycle Calculator',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Calculate fertile windows and next arrival date privately.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildHelplineCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.support_agent, color: AppColors.secondary, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free Ethiopian Confidential Helplines',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Emergency Post-exposure (PEP within 72h) or youth counseling: Call 8335 or 8044.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
