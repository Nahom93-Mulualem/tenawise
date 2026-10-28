import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/staggered_entrance.dart';
import '../../core/widgets/tactile_card.dart';

/// Confidential, calm, and empowering Period & Menstrual Cycle Tracker.
/// Redesigned with:
/// - Soothing biological color palette (soft coral for period, fresh teal for fertile window)
/// - Privacy first: all calculations run purely on-device (zero cloud sync)
/// - Intuitive date picker + interactive sliders with clear visual feedback
/// - Reassuring hormonal and hygiene guidance
class CycleScreen extends StatefulWidget {
  const CycleScreen({super.key});

  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen> {
  DateTime _lastPeriodDate = DateTime.now().subtract(const Duration(days: 14));
  double _periodDuration = 5;
  double _cycleLength = 28;
  bool _showGuide = false;

  DateTime get _nextPeriodDate =>
      _lastPeriodDate.add(Duration(days: _cycleLength.toInt()));
  DateTime get _nextPeriodEndDate =>
      _nextPeriodDate.add(Duration(days: _periodDuration.toInt()));
  int get _daysRemaining => _nextPeriodDate.difference(DateTime.now()).inDays;

  DateTime get _ovulationDate =>
      _nextPeriodDate.subtract(const Duration(days: 14));
  DateTime get _fertileStart => _ovulationDate.subtract(const Duration(days: 4));
  DateTime get _fertileEnd => _ovulationDate.add(const Duration(days: 1));

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppLanguage.isAmharicNotifier,
      builder: (context, isAmharic, _) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Text(
              isAmharic ? 'የወር አበባ እና የመራባት አስሊ' : 'Period & Fertile Window Tracker',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Safe Space Reassurance
                  StaggeredEntrance(
                    index: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAmharic ? '100% በስልክዎ ላይ ብቻ የተጠበቀ' : '100% Private On-Device Tracking',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  isAmharic
                                      ? 'ምንም አይነት የግል መረጃ ከስልክዎ ውጭ አይላክም'
                                      : 'Zero cloud upload. Your health data stays solely on this device.',
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
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Forecast Summary Card (Hero)
                  StaggeredEntrance(
                    index: 1,
                    child: _buildForecastCard(isAmharic),
                  ),
                  const SizedBox(height: 18),

                  // Input Controls
                  StaggeredEntrance(
                    index: 2,
                    child: _buildInputsCard(isAmharic),
                  ),
                  const SizedBox(height: 18),

                  // Phase Breakdown & Self-Care Guidance
                  StaggeredEntrance(
                    index: 3,
                    child: _buildPhaseBreakdown(isAmharic),
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

  Widget _buildInputsCard(bool isAmharic) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.onSecondaryContainer,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isAmharic ? 'የዑደት መለኪያዎችዎን ያስተካክሉ' : 'Adjust Cycle Details',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Date Picker
          Text(
            isAmharic ? 'የመጨረሻው የወር አበባ የጀመረበት ቀን:' : 'First day of last menstrual period:',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          TactileCard(
            pressedScale: 0.98,
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _lastPeriodDate,
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _lastPeriodDate = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _formatDate(_lastPeriodDate),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isAmharic ? 'ቀይር' : 'Change',
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
          const SizedBox(height: 18),

          // Slider 1: Period Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAmharic ? 'የደም መፍሰስ ቆይታ:' : 'Period duration:',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.cyclePeriodLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_periodDuration.toInt()} ${isAmharic ? 'ቀናት' : 'Days'}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cyclePeriod,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.cyclePeriod,
              thumbColor: AppColors.cyclePeriod,
              trackHeight: 4,
            ),
            child: Slider(
              value: _periodDuration,
              min: 3,
              max: 10,
              divisions: 7,
              onChanged: (val) => setState(() => _periodDuration = val),
            ),
          ),
          const SizedBox(height: 10),

          // Slider 2: Average Cycle Length
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAmharic ? 'አማካይ የዑደት ርዝመት:' : 'Average cycle length:',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_cycleLength.toInt()} ${isAmharic ? 'ቀናት' : 'Days'}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              thumbColor: AppColors.primary,
              trackHeight: 4,
            ),
            child: Slider(
              value: _cycleLength,
              min: 21,
              max: 40,
              divisions: 19,
              onChanged: (val) => setState(() => _cycleLength = val),
            ),
          ),
          const SizedBox(height: 10),

          // Collapsible educational guide with smooth AnimatedSize
          TactileCard(
            pressedScale: 0.98,
            onTap: () => setState(() => _showGuide = !_showGuide),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.help_outline_rounded, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isAmharic
                          ? 'የዑደት ርዝመት እንዴት ይሰላል?'
                          : 'How to calculate your cycle length?',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _showGuide ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: _showGuide
                ? Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isAmharic
                          ? 'የዑደት ርዝመት ማለት የወር አበባ ከጀመረበት ቀን አንስቶ የሚቀጥለው እስኪመጣ ያለው የቀናት ብዛት ነው (ብዙውን ጊዜ ከ24 እስከ 35 ቀናት)።'
                          : 'Count from Day 1 of your bleeding until the day before your next period begins (typically 24–35 days for most healthy women).',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard(bool isAmharic) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.successGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAmharic ? 'ቀጣዩ የወር አበባ ትንበያ' : 'Estimated Next Cycle',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_formatDate(_nextPeriodDate)} – ${_formatDate(_nextPeriodEndDate)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _daysRemaining >= 0
                          ? (isAmharic
                              ? 'በ ~$_daysRemaining ቀናት ውስጥ ይጀምራል'
                              : 'Expected in ~$_daysRemaining days')
                          : (isAmharic
                              ? 'ዑደቱ ከ ~${_daysRemaining.abs()} ቀናት በፊት ጀምሯል'
                              : 'Started ~${_daysRemaining.abs()} days ago'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.cyclePeriodLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: AppColors.cyclePeriod,
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Cycle Visual Progress Bar
          Text(
            isAmharic ? 'የዑደት ክፍሎች በጨረፍታ' : 'Cycle Architecture (Timeline)',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: _periodDuration.toInt().clamp(3, 10),
                    child: Container(color: AppColors.cyclePeriod),
                  ),
                  const SizedBox(width: 2),
                  Expanded(flex: 8, child: Container(color: AppColors.primaryContainer)),
                  const SizedBox(width: 2),
                  Expanded(flex: 5, child: Container(color: AppColors.cycleFertile)),
                  const SizedBox(width: 2),
                  Expanded(flex: 11, child: Container(color: AppColors.surfaceDim)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildLegendDot(AppColors.cyclePeriod, isAmharic ? 'የደም መፍሰስ' : 'Menstruation'),
              _buildLegendDot(AppColors.primaryContainer, isAmharic ? 'ፎሊኩላር' : 'Follicular'),
              _buildLegendDot(AppColors.cycleFertile, isAmharic ? 'የመራባት ቀናት' : 'Fertile Window'),
              _buildLegendDot(AppColors.surfaceDim, isAmharic ? 'ሉቲያል' : 'Luteal'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildPhaseBreakdown(bool isAmharic) {
    return Column(
      children: [
        _buildInfoTile(
          icon: Icons.favorite_border_rounded,
          color: AppColors.cycleFertile,
          lightBg: AppColors.cycleFertileLight,
          title: isAmharic ? 'የመራባት ቀናት (Fertile Window)' : 'Fertile Window Estimate',
          subtitle: '${_formatDate(_fertileStart)} – ${_formatDate(_fertileEnd)}',
          desc: isAmharic
              ? 'እርግዝና የመፈጠር ዕድሉ ከፍተኛ ነው። ጥንቃቄ የጎደለው ግንኙነት ካጋጠመዎት በ72 ሰዓት ውስጥ ድንገተኛ መከላከያ ይውሰዱ።'
              : 'High probability of conception. Use barrier methods if wishing to prevent pregnancy, or take emergency pills within 72h.',
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          icon: Icons.spa_rounded,
          color: AppColors.primary,
          lightBg: AppColors.primaryLight,
          title: isAmharic ? 'የንፅህና እና የቁርጠት ማስታገሻ ምክር' : 'Period Hygiene & Cramp Relief',
          subtitle: isAmharic ? 'ውሃ፣ ሞቅ ያለ ሻይ እና እረፍት' : 'Hydration, Warmth & Self-Care',
          desc: isAmharic
              ? 'በቂ ውሃ ይጠጡ፣ ሞቅ ያለ ውሃ በሆድዎ ላይ ያድርጉ እና በብረት የበለፀጉ ምግቦችን (ምስር፣ ቆስጣ) ይመገቡ።'
              : 'Stay hydrated, apply a warm compress for cramps, and eat iron-rich foods (spinach, lentils) during bleeding.',
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color color,
    required Color lightBg,
    required String title,
    required String subtitle,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: lightBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
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
