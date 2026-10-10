import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Interactive Period & Cycle Calculator screen.
/// Implements 100% client-side privacy calculations for estimating
/// the next period arrival, fertile window, and cycle phase breakdown.
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

  DateTime get _nextPeriodDate => _lastPeriodDate.add(Duration(days: _cycleLength.toInt()));
  DateTime get _nextPeriodEndDate => _nextPeriodDate.add(Duration(days: _periodDuration.toInt()));
  int get _daysRemaining => _nextPeriodDate.difference(DateTime.now()).inDays;

  DateTime get _ovulationDate => _nextPeriodDate.subtract(const Duration(days: 14));
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
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Period Calculator (የወር አበባ አስሊ)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Privacy Shield Notice
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield, size: 16, color: AppColors.secondary),
                  SizedBox(width: 6),
                  Text(
                    '100% Client-Side Privacy: No data leaves your phone',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Header text
            const Text(
              'Track Your Cycle Confidentially',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Estimate when your next cycle begins, anticipate fertile windows, and understand natural hormonal rhythms.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),

            // Cycle Input Controls
            _buildInputsCard(),
            const SizedBox(height: 20),

            // Cycle Forecast & Timeline Section
            _buildForecastCard(),
            const SizedBox(height: 20),

            // Phase Breakdown & Tips
            _buildPhaseBreakdown(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInputsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Your Cycle Inputs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Input 1: Last Period Date
          const Text(
            'First day of last period (የጀመረበት ቀን):',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
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
              const Text(
                'Period duration (የቆየበት ቀናት):',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_periodDuration.toInt()} Days',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
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
              const Text(
                'Average cycle length (የዑደት ርዝመት):',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_cycleLength.toInt()} Days',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
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
                const Expanded(
                  child: Text(
                    'How do I calculate cycle length? (እንዴት ማስላት እችላለሁ?)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
                  ),
                ),
                Icon(_showGuide ? Icons.expand_less : Icons.expand_more, size: 20, color: AppColors.secondary),
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
              child: const Text(
                'Cycle length is the count from Day 1 of your period until the day before your next period begins (usually 24–35 days in healthy youth).',
                style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildForecastCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ESTIMATED FORECAST',
                    style: TextStyle(
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
                        ? 'Estimated arrival in ~$_daysRemaining days'
                        : 'Cycle started ~${_daysRemaining.abs()} days ago',
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.secondaryContainer,
                child: Icon(Icons.water_drop, color: AppColors.onSecondaryContainer, size: 26),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Cycle Visual Progress Bar
          const Text(
            'Cycle Architecture (Overview)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
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
              _buildLegendDot(AppColors.tertiaryContainer, 'Bleeding'),
              _buildLegendDot(AppColors.primaryContainer, 'Follicular'),
              _buildLegendDot(AppColors.secondary, 'Fertile Window'),
              _buildLegendDot(AppColors.surfaceDim, 'Luteal'),
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
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildPhaseBreakdown() {
    return Column(
      children: [
        _buildInfoTile(
          icon: Icons.favorite_border,
          color: AppColors.secondary,
          title: 'Fertile Window (የመራባት ቀናት)',
          subtitle: '${_formatDate(_fertileStart)} – ${_formatDate(_fertileEnd)}',
          desc: 'High probability of conception. Use barrier methods if wishing to prevent pregnancy.',
        ),
        const SizedBox(height: 10),
        _buildInfoTile(
          icon: Icons.lightbulb_outline,
          color: AppColors.primary,
          title: 'Daily Symptom Hygiene',
          subtitle: 'Hydration & Nutrition',
          desc: 'Drink plenty of water and maintain iron-rich meals (lentils, spinach) during menstruation.',
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
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
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
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                Text(subtitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
