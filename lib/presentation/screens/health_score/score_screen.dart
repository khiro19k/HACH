import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/glucose_provider.dart';
import '../../providers/health_stats_provider.dart';
import '../../../domain/models/glucose_record.dart';

class HealthScoreScreen extends ConsumerStatefulWidget {
  const HealthScoreScreen({super.key});

  @override
  ConsumerState<HealthScoreScreen> createState() => _HealthScoreScreenState();
}

class _HealthScoreScreenState extends ConsumerState<HealthScoreScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glucoseState = ref.watch(glucoseProvider);
    final healthStats = ref.watch(healthStatsProvider);
    final records = glucoseState.records;

    final tir = _calculateTimeInRange(records);
    final avgGlucose = _calculateAverage(records);
    final hba1c = _calculateHbA1c(avgGlucose);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.bgGradientStart, AppTheme.bgGradientEnd],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  'تقرير الحالة الصحية',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          _buildMainScoreCard(tir, hba1c),
                          const SizedBox(height: 24),
                          _buildChartCard(records),
                          const SizedBox(height: 24),
                          _buildLifestyleRow(healthStats.sleepHours, healthStats.waterLiters, healthStats.activityPercentage),
                          const SizedBox(height: 24),
                          _buildAiInsightCard(tir),
                          const SizedBox(height: 100), // Padding for bottom nav
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateAverage(List<GlucoseRecord> records) {
    if (records.isEmpty) return 0;
    return records.fold(0.0, (sum, item) => sum + item.value) / records.length;
  }

  double _calculateHbA1c(double avgGlucose) {
    if (avgGlucose == 0) return 0;
    return (avgGlucose + 46.7) / 28.7;
  }

  int _calculateTimeInRange(List<GlucoseRecord> records) {
    if (records.isEmpty) return 0;
    int normalCount = 0;

    for (var r in records) {
      if (r.type == 'صائم' || r.type == 'صيام') {
        if (r.value >= 70 && r.value <= 99) normalCount++;
      } else {
        // After meal or random
        if (r.value > 70 && r.value < 140) normalCount++;
      }
    }
    return ((normalCount / records.length) * 100).round();
  }

  Widget _buildMainScoreCard(int tir, double hba1c) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.glassColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'الوقت في النطاق (TIR)',
            style: TextStyle(fontSize: 14, color: AppTheme.secondaryTextColor, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: tir / 100),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      color: tir >= 70 ? AppTheme.accentColor : Colors.orange,
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$tir%',
                    style: GoogleFonts.outfit(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryColor,
                      height: 1,
                    ),
                  ),
                  Text(
                    'طبيعي',
                    style: TextStyle(
                      color: tir >= 70 ? AppTheme.accentColor : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('التراكمي المقدر', '${hba1c > 0 ? hba1c.toStringAsFixed(1) : '--'}%'),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              _buildMiniStat('الهدف', '70-140'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.secondaryTextColor)),
      ],
    );
  }

  Widget _buildChartCard(List<GlucoseRecord> records) {
    if (records.isEmpty) return const SizedBox();

    // Prepare chart data. We take up to 7 most recent records and reverse to show chronologically
    final chartRecords = records.take(7).toList().reversed.toList();
    final spots = chartRecords.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.glassColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'منحنى السكر (آخر القياسات)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(), style: TextStyle(color: Colors.grey.shade500, fontSize: 10));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < chartRecords.length) {
                          final date = chartRecords[index].timestamp;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('${date.day}/${date.month}', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 40,
                maxY: 300,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: AppTheme.primaryColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.2),
                          AppTheme.primaryColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleRow(double sleep, double water, int activity) {
    return Row(
      children: [
        Expanded(child: _buildInfoBox('خطوات', '$activity%', Icons.directions_walk_rounded, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildInfoBox('ماء', '${water.toStringAsFixed(1)}L', Icons.water_drop_rounded, Colors.lightBlue)),
        const SizedBox(width: 12),
        Expanded(child: _buildInfoBox('نوم', '${sleep.toStringAsFixed(1)}h', Icons.bedtime_rounded, Colors.indigo)),
      ],
    );
  }

  Widget _buildInfoBox(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.glassColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.secondaryTextColor)),
        ],
      ),
    );
  }

  Widget _buildAiInsightCard(int tir) {
    String message = "لا توجد بيانات كافية لتحليل أداءك. قم بتسجيل قراءات السكر.";
    IconData icon = Icons.info_outline_rounded;
    Color color = Colors.grey;

    if (tir >= 80) {
      message = "رائع! مستويات السكر لديك في النطاق المثالي. التزامك بالحمية والرياضة يعطي ثماراً ممتازة.";
      icon = Icons.auto_awesome_rounded;
      color = AppTheme.accentColor;
    } else if (tir >= 50) {
      message = "أداء جيد، لكن هناك تقلبات في السكر مؤخراً. حاول مراجعة كمية الكربوهيدرات في وجباتك.";
      icon = Icons.insights_rounded;
      color = Colors.orange;
    } else if (tir > 0) {
      message = "انتباه: معظم قراءاتك خارج النطاق الطبيعي. يُرجى استشارة طبيبك لضبط الجرعات.";
      icon = Icons.warning_rounded;
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10)],
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تحليل رفيق AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(fontSize: 12, color: Colors.grey.shade800, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
