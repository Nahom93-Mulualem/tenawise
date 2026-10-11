import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';

/// Interactive Period & Cycle Calculator screen.
/// 100% English when English is selected; 100% Amharic when Amharic is selected.
/// Responsive and client-side only.
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
            title: Text(
              isAmharic ? 'የወር አበባ አስሊ' : 'Period Calculator',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header text
                  Text(
                    isAmharic
                        ? 'የወር አበባ ዑደትዎን ይከታተሉ'
                        : 'Track Your Cycle Confidentially',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAmharic
                        ? 'ቀጣዩ የወር አበባ የሚጀምርበትን ቀን፣ የመራባት ጊዜን እና ተፈጥሯዊ የሆርሞን ዑደትን ይረዱ።'
                        : 'Estimate when your next cycle begins, anticipate fertile windows, and understand natural hormonal rhythms.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Cycle Input Controls Card
                  _buildInputsCard(isAmharic),
                  const SizedBox(height: 20),

                  // Cycle Forecast & Timeline Section
                  _buildForecastCard(isAmharic),
                  const SizedBox(height: 20),

                  // Phase Breakdown & Tips
                  _buildPhaseBreakdown(isAmharic),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                isAmharic ? 'የዑደት መረጃዎች' : 'Your Cycle Inputs',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Input 1: Last Period Date
          Text(
            isAmharic ? 'የጀመረበት ቀን:' : 'First day of last period:',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            borderRadius: BorderRadius.circular(10),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(_lastPeriodDate),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const Icon(Icons.event, color: AppColors.secondary, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Input 2: Period Duration Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAmharic ? 'የቆየበት ቀናት:' : 'Period duration:',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_periodDuration.toInt()} ${isAmharic ? 'ቀናት' : 'Days'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _periodDuration,
            min: 3,
            max: 10,
            divisions: 7,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _periodDuration = val),
          ),
          const SizedBox(height: 8),

          // Input 3: Average Cycle Length Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAmharic ? 'የዑደት ርዝመት:' : 'Average cycle length:',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_cycleLength.toInt()} ${isAmharic ? 'ቀናት' : 'Days'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _cycleLength,
            min: 21,
            max: 40,
            divisions: 19,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _cycleLength = val),
          ),
          const SizedBox(height: 8),

          // Collapsible educational guide
          InkWell(
            onTap: () => setState(() => _showGuide = !_showGuide),
            child: Row(
              children: [
                const Icon(Icons.help_outline, size: 16, color: AppColors.secondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isAmharic
                        ? 'እንዴት ማስላት እችላለሁ?'
                        : 'How do I calculate cycle length?',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                Icon(
                  _showGuide ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
          if (_showGuide) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isAmharic
                    ? 'የዑደት ርዝመት ማለት የወር አበባ ከጀመረበት ቀን አንስቶ የሚቀጥለው እስኪመጣ ያለው የቀናት ብዛት ነው (ብዙውን ጊዜ ከ24 እስከ 35 ቀናት)።'
                    : 'Cycle length is the count from Day 1 of your period until the day before your next period begins (usually 24–35 days in healthy youth).',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildForecastCard(bool isAmharic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
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
                    Text(
                      isAmharic ? 'የተገመተ ትንበያ' : 'ESTIMATED FORECAST',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(_nextPeriodDate)} – ${_formatDate(_nextPeriodEndDate)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      _daysRemaining >= 0
                          ? (isAmharic
                              ? 'በ ~$_daysRemaining ቀናት ውስጥ ይጀምራል ተብሎ ይጠበቃል'
                              : 'Estimated arrival in ~$_daysRemaining days')
                          : (isAmharic
                              ? 'ዑደቱ ከ ~${_daysRemaining.abs()} ቀናት በፊት ጀምሯል'
                              : 'Cycle started ~${_daysRemaining.abs()} days ago'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.secondaryContainer,
                child: Icon(
                  Icons.water_drop,
                  color: AppColors.onSecondaryContainer,
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Cycle Visual Progress Bar
          Text(
            isAmharic ? 'የዑደት ደረጃዎች' : 'Cycle Architecture (Overview)',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(flex: 5, child: Container(color: AppColors.tertiaryContainer)),
                  Expanded(flex: 8, child: Container(color: AppColors.primaryContainer)),
                  Expanded(flex: 4, child: Container(color: AppColors.secondary)),
                  Expanded(flex: 11, child: Container(color: AppColors.surfaceDim)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildLegendDot(AppColors.tertiaryContainer, isAmharic ? 'የደም መፍሰስ' : 'Bleeding'),
              _buildLegendDot(AppColors.primaryContainer, isAmharic ? 'የእንቁላል ማደግ' : 'Follicular'),
              _buildLegendDot(AppColors.secondary, isAmharic ? 'የመራባት ቀናት' : 'Fertile Window'),
              _buildLegendDot(AppColors.surfaceDim, isAmharic ? 'የሉቲያል ደረጃ' : 'Luteal'),
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
        const SizedBox(width: 4),
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
          icon: Icons.favorite_border,
          color: AppColors.secondary,
          title: isAmharic ? 'የመራባት ቀናት' : 'Fertile Window',
          subtitle: '${_formatDate(_fertileStart)} – ${_formatDate(_fertileEnd)}',
          desc: isAmharic
              ? 'እርግዝና የመፈጠር ዕድሉ ከፍተኛ ነው። ጥንቃቄ ያድርጉ።'
              : 'High probability of conception. Use barrier methods if wishing to prevent pregnancy.',
        ),
        const SizedBox(height: 10),
        _buildInfoTile(
          icon: Icons.lightbulb_outline,
          color: AppColors.primary,
          title: isAmharic ? 'የንፅህና እና ጤና ምክር' : 'Daily Symptom Hygiene',
          subtitle: isAmharic ? 'ውሃ እና የተመጣጠነ ምግብ' : 'Hydration & Nutrition',
          desc: isAmharic
              ? 'በቂ ውሃ ይጠጡ እና በብረት የበለፀጉ ምግቦችን (ምስር፣ ቆስጣ) ይመገቡ።'
              : 'Drink plenty of water and maintain iron-rich meals (lentils, spinach) during menstruation.',
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                    height: 1.3,
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
