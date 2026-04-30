import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/health_stats_provider.dart';

class HealthSummaryCard extends ConsumerWidget {
  final double averageGlucose;
  final double? lastReading;

  const HealthSummaryCard({
    required this.averageGlucose,
    this.lastReading,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(healthStatsProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.glassColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'مستقر',
                              style: TextStyle(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'معدل السكر اليومي',
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: averageGlucose),
                                duration: const Duration(seconds: 2),
                                curve: Curves.easeOutCirc,
                                builder: (context, value, child) {
                                  return Text(
                                    value.toStringAsFixed(1),
                                    style: GoogleFonts.outfit(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.accentColor, // Changed to Mint Green
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'mg/dL',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildAnimatedGauge(),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAnimatedStat(
                        'النشاط', 
                        '${stats.activityPercentage}%', 
                        Icons.bolt_rounded,
                        isGlowing: stats.isChallengeActive,
                      ),
                      _buildAnimatedStat(
                        'الماء', 
                        '${stats.waterLiters.toStringAsFixed(1)} لتر', 
                        Icons.water_drop_rounded,
                      ),
                      _buildAnimatedStat(
                        'النوم', 
                        '${stats.sleepHours} س', 
                        Icons.bedtime_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedGauge() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 0.75),
            duration: const Duration(seconds: 2),
            curve: Curves.easeOutCirc,
            builder: (context, value, child) {
              return CustomPaint(
                painter: _GaugePainter(value: value),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.shield_rounded, color: Colors.white, size: 28),
        ),
      ],
    );
  }

  Widget _buildAnimatedStat(String label, String value, IconData icon, {bool isGlowing = false}) {
    return Column(
      children: [
        _GlowingIcon(icon: icon, isGlowing: isGlowing),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.secondaryTextColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _GlowingIcon extends StatefulWidget {
  final IconData icon;
  final bool isGlowing;

  const _GlowingIcon({required this.icon, required this.isGlowing});

  @override
  State<_GlowingIcon> createState() => _GlowingIconState();
}

class _GlowingIconState extends State<_GlowingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isGlowing) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_GlowingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGlowing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isGlowing) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Icon(
          widget.icon,
          color: widget.isGlowing 
            ? Color.lerp(AppTheme.accentColor, Colors.orange, _controller.value)
            : AppTheme.accentColor,
          size: 24,
          shadows: widget.isGlowing ? [
            Shadow(
              color: AppTheme.accentColor.withValues(alpha: 0.5 * _controller.value),
              blurRadius: 10,
            )
          ] : null,
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  _GaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 12.0;

    // Background track
    final trackPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, trackPaint);

    // Progress arc with gradient
    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [AppTheme.accentColor, Color(0xFF00E1D9)],
        startAngle: -1.5,
        endAngle: 4.5,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -1.5,
      value * 6.28,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


