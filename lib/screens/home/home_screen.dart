import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/language_switch.dart';
import '../../core/widgets/staggered_entrance.dart';
import '../../core/widgets/tactile_card.dart';

/// The Home / Education Hub screen for TenaWise (ጤና ዋይዝ).
/// Designed with empathetic behavioral UX:
/// - Reassuring header with quick bilingual toggle
/// - Calming color psychology (reassuring forest green, soft clinical teal, gentle coral)
/// - 4 Key Interactive Pillars: Period Calculator, Contraception Guide, STI Encyclopedia, TenaWise AI
/// - Localized 100% in English & Amharic
class HomeScreen extends StatelessWidget {
  final void Function(int tabIndex)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppLanguage.isAmharicNotifier,
      builder: (context, isAmharic, _) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: _buildHeader(context, isAmharic),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Reassuring Greeting & Safe Space Badge
                  StaggeredEntrance(
                    index: 0,
                    child: _buildGreetingBanner(isAmharic),
                  ),
                  const SizedBox(height: 18),

                  // 2. Featured AI Companion Hero Card
                  StaggeredEntrance(
                    index: 1,
                    child: _buildAiCompanionHero(isAmharic),
                  ),
                  const SizedBox(height: 24),

                  // 3. Section Title: Core Health Tools & Guides
                  StaggeredEntrance(
                    index: 2,
                    child: Text(
                      isAmharic ? 'የስነ-ተዋልዶ ጤና መመሪያዎች' : 'Essential Health Guides',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4. 2x2 Feature Pillar Grid (Contraception, STIs, Cycle, Self-Care)
                  StaggeredEntrance(
                    index: 3,
                    child: _buildPillarsGrid(context, isAmharic),
                  ),
                  const SizedBox(height: 22),

                  // 5. Interactive Cycle Quick-Check Card
                  StaggeredEntrance(
                    index: 4,
                    child: _buildCycleQuickCard(isAmharic),
                  ),
                  const SizedBox(height: 20),

                  // 6. Ethiopian Local Youth Partners & Free Clinic Info
                  StaggeredEntrance(
                    index: 5,
                    child: _buildLocalPartnersSection(context, isAmharic),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Refined AppBar with Brand Identity & Bilingual toggle
  PreferredSizeWidget _buildHeader(BuildContext context, bool isAmharic) {
    return AppBar(
      titleSpacing: 16,
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.asset(
                'assets/images/logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.spa_rounded,
                  color: AppColors.primary,
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
              Text(
                isAmharic ? 'ጤና ዋይዝ' : 'TenaWise',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.4,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.successGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isAmharic ? '100% ሚስጥራዊ እና ነፃ' : '100% Private & Free',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Bilingual Segmented Capsule Switch
        Padding(
          padding: const EdgeInsets.only(right: 14.0),
          child: LanguageSegmentedSwitch(isAmharic: isAmharic),
        ),
      ],
    );
  }

  /// Supportive Greeting with Psychological Safety
  Widget _buildGreetingBanner(bool isAmharic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAmharic
                ? 'ጤናዎ፣ ምርጫዎ፣ መብትዎ ነው።'
                : 'Your health, your choice, your safe space.',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.4,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isAmharic
                ? 'ስለ ስነ-ተዋልዶ ጤና፣ የወሊድ መከላከያ እና የወር አበባ ዑደት የተረጋገጠ መረጃ በነፃነት ያግኙ።'
                : 'Access verified sexual and reproductive health information without judgment or stigma.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// Hero Banner for the AI Health Assistant
  Widget _buildAiCompanionHero(bool isAmharic) {
    return TactileCard(
      pressedScale: 0.98,
      onTap: () => onNavigateToTab?.call(3),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primary,
              Color(0xFF1E5B40),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFFA6E3C3),
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isAmharic ? 'የስነ-ተዋልዶ ጤና AI አጋር' : 'SRH AI Companion',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              isAmharic ? 'ስለ ጤናዎ ማንኛውንም ጥያቄ በነፃነት ይጠይቁ' : 'Ask confidential health questions anytime',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.3,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isAmharic
                  ? 'ስለ Postpill፣ የ3 ወር መርፌ፣ የአባለዘር በሽታዎች እና ኤች.አይ.ቪ መከላከያ (PEP) ፈጣን መልስ ያግኙ።'
                  : 'Get instant, empathetic clinical answers powered by verified Ethiopian MoH & WHO guidelines.',
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.88),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAmharic ? 'አሁን ይጠይቁ' : 'Start Private Chat',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 2x2 Clean Pillars Grid with Accessible Touch Targets (Min 48dp)
  Widget _buildPillarsGrid(BuildContext context, bool isAmharic) {
    final pillars = [
      _PillarItem(
        title: isAmharic ? 'የወሊድ መከላከያ' : 'Contraceptive Guide',
        subtitle: isAmharic ? 'Postpill፣ መርፌ፣ ጃዴል፣ ኮንዶም' : 'Emergency pills, implants & injectables',
        icon: Icons.shield_moon_rounded,
        color: AppColors.primary,
        lightBg: AppColors.primaryLight,
        onTap: () => onNavigateToTab?.call(2), // Library -> Contraception
      ),
      _PillarItem(
        title: isAmharic ? 'የአባለዘር በሽታዎች (STIs)' : 'STI Encyclopedia',
        subtitle: isAmharic ? 'ምልክቶች፣ ምርመራ እና መከላከያ' : 'Symptoms, testing & syndromic care',
        icon: Icons.biotech_rounded,
        color: AppColors.secondary,
        lightBg: AppColors.secondaryContainer,
        onTap: () => onNavigateToTab?.call(2), // Library -> STIs
      ),
      _PillarItem(
        title: isAmharic ? 'የወር አበባ አስሊ' : 'Period Calculator',
        subtitle: isAmharic ? 'ቀጣይ ዑደት እና የመራባት ቀናት' : 'Cycle timeline & fertile window',
        icon: Icons.calendar_month_rounded,
        color: AppColors.tertiary,
        lightBg: AppColors.tertiaryFixed,
        onTap: () => onNavigateToTab?.call(1), // Cycle Screen
      ),
      _PillarItem(
        title: isAmharic ? 'የአእምሮ እና ግንኙነት' : 'Youth Wellbeing',
        subtitle: isAmharic ? 'የፍቅር ግንኙነት፣ ስምምነት፣ መብት' : 'Consent, anatomy & healthy relationships',
        icon: Icons.favorite_border_rounded,
        color: const Color(0xFF6B4226),
        lightBg: const Color(0xFFF7ECE4),
        onTap: () => onNavigateToTab?.call(2), // Library -> Relationships
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pillars.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final p = pillars[index];
        return TactileCard(
          pressedScale: 0.95,
          onTap: p.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.45),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: p.lightBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(p.icon, color: p.color, size: 20),
                ),
                const Spacer(),
                Text(
                  p.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  p.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Interactive Cycle Tracker Quick Preview
  Widget _buildCycleQuickCard(bool isAmharic) {
    return TactileCard(
      pressedScale: 0.98,
      onTap: () => onNavigateToTab?.call(1),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cycleFertileLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.cycleFertile,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAmharic ? 'የወር አበባ እና የመራባት ዑደትዎን ይወቁ' : 'Track Your Cycle & Fertile Window',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAmharic
                        ? 'የወር አበባ ቀንዎን በማስገባት የመፀነስ እድልን እና ቀጣይ ዑደትን ይተንብዩ'
                        : 'Accurate estimates of ovulation, fertile window and next period onset',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(launchUri);
      }
    } catch (e) {
      debugPrint('Error launching dialer: $e');
    }
  }

  /// Local Ethiopian Healthcare Partners & Direct Dial Hotlines
  Widget _buildLocalPartnersSection(BuildContext context, bool isAmharic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                isAmharic ? 'በኢትዮጵያ የታመኑ የጤና አጋሮች' : 'Trusted Health Partners in Ethiopia',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isAmharic
                ? 'በማንኛውም የመንግስት ጤና ጣቢያ፣ ማሪ ስቶፕስ ኢትዮጵያ (MSE) ወይም FGAE ወጣቶች ማዕከል ሚስጥራዊ እና ነፃ አገልግሎት ማግኘት ይችላሉ። ለፈጣን የምክር አገልግሎት ነፃ የስልክ መስመሮቹን በቀጥታ ይደውሉ።'
                : 'Access free, youth-friendly SRH counseling and free PEP at your nearest Woreda Health Center, Marie Stopes, or FGAE clinic. Tap toll-free numbers below to call directly.',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Interactive Toll-Free Youth SRH Helpline (8335)
              InkWell(
                onTap: () => _makePhoneCall('8335'),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.phone_in_talk_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isAmharic ? 'ነፃ መስመር 8335' : 'Toll-Free 8335',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Interactive National GBV Helpline (6788)
              InkWell(
                onTap: () => _makePhoneCall('6788'),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECEB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.emergencyRed.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.phone_in_talk_rounded,
                        size: 12,
                        color: AppColors.emergencyRed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isAmharic ? 'የጥቃት ድጋፍ 6788' : 'Helpline 6788',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.emergencyRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildPartnerChip(isAmharic ? 'የመንግስት ጤና ጣቢያዎች' : 'Public Health Centers'),
              _buildPartnerChip('Marie Stopes Ethiopia'),
              _buildPartnerChip('FGAE Youth Centers'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

class _PillarItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color lightBg;
  final VoidCallback onTap;

  const _PillarItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.lightBg,
    required this.onTap,
  });
}
