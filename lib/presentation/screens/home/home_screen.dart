import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/glucose_provider.dart';
import '../../providers/health_stats_provider.dart';
import '../../providers/safety_provider.dart';
import '../../widgets/home/health_summary_card.dart';
import '../../widgets/home/recent_readings_list.dart';
import '../../widgets/home/add_reading_dialog.dart';
import '../../widgets/safety/safety_kit_dialog.dart';
import '../../providers/patient_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late List<Animation<double>> _staggeredAnimations;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _staggeredAnimations = List.generate(4, (index) {
      return CurvedAnimation(
        parent: _entranceController,
        curve: Interval(
          index * 0.1,
          0.6 + (index * 0.1),
          curve: Curves.easeOutCubic,
        ),
      );
    });

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final glucoseState = ref.watch(glucoseProvider);
        final stats = ref.watch(healthStatsProvider);
        final safety = ref.watch(safetyProvider);
        final patient = ref.watch(patientProvider).profile;

        // Logic to trigger a challenge if glucose is high (> 180)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (glucoseState.records.isNotEmpty && 
              glucoseState.records.first.value > 180 && 
              !stats.isChallengeActive) {
            ref.read(healthStatsProvider.notifier).setChallengeActive(true);
            _showChallengeSnackbar(context, ref);
          }

          // Trigger Safety Checklist if user just went OUT
          if (safety.isOut && !safety.isSafetyKitChecked) {
            _showSafetyKitDialog(context);
          }
        });

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppTheme.bgGradientStart, AppTheme.bgGradientEnd],
            ),
          ),
          child: Scaffold(
            body: Stack(
              children: [
                // Decorative Background Blobs
                Positioned(
                  top: -100,
                  right: -100,
                  child: _AnimatedBlob(
                    color: safety.isOut ? Colors.orange.withOpacity(0.1) : AppTheme.accentColor.withOpacity(0.1),
                    size: 300,
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: -50,
                  child: _AnimatedBlob(
                    color: const Color(0xFF6B48FF).withOpacity(0.05),
                    size: 250,
                  ),
                ),
                
                // Main Content
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      floating: true,
                      pinned: false,
                      toolbarHeight: 80,
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      leading: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Hero(
                          tag: 'app_logo',
                          child: Image.asset('images/logo.png'),
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (safety.isOut) 
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.shield_rounded, color: Colors.orange, size: 10),
                                  SizedBox(width: 4),
                                  Text(
                                    'وضع الخروج الآمن مفعل',
                                    style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          Text(
                            'رفيق AI',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          if (!safety.isOut)
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AppTheme.accentColor,
                                shape: BoxShape.circle,
                              ),
                            )
                        ],
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, size: 28),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          if (safety.alertStatus != 'idle')
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: safety.alertStatus == 'active' ? Colors.red : Colors.orange,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: (safety.alertStatus == 'active' ? Colors.red : Colors.orange).withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          safety.alertStatus == 'active' ? 'تم إرسال نداء استغاثة!' : 'المساعدة في الطريق!',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        Text(
                                          safety.alertStatus == 'active' ? 'نحن نتواصل مع عائلتك وطبيبك.' : 'قام الطبيب بتأكيد استلام النداء وهو في الطريق إليك.',
                                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                                    onPressed: () => ref.read(safetyProvider.notifier).resolveAlert(),
                                  ),
                                ],
                              ),
                            ),
                          
                          FadeTransition(
                            opacity: _staggeredAnimations[0],
                            child: SlideTransition(
                              position: _staggeredAnimations[0].drive(
                                Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'صباح الخير، ${patient?['full_name']?.split(' ')[0] ?? 'صديقي'}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.primaryColor,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'حالتك الصحية تبدو مستقرة اليوم.',
                                    style: TextStyle(
                                      color: AppTheme.secondaryTextColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          FadeTransition(
                            opacity: _staggeredAnimations[1],
                            child: ScaleTransition(
                              scale: _staggeredAnimations[1],
                              child: HealthSummaryCard(
                                averageGlucose: _calculateAverage(glucoseState.records),
                                lastReading: glucoseState.records.isNotEmpty
                                    ? glucoseState.records.first.value
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          FadeTransition(
                            opacity: _staggeredAnimations[2],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'آخر القياسات',
                                  style: GoogleFonts.outfit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'عرض الكل',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.accentColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FadeTransition(
                            opacity: _staggeredAnimations[3],
                            child: glucoseState.records.isEmpty
                                ? _buildEmptyState()
                                : RecentReadingsList(records: glucoseState.records),
                          ),
                          const SizedBox(height: 120),
                        ]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSafetyKitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SafetyKitDialog(),
    );
  }

  void _showChallengeSnackbar(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt_rounded, color: AppTheme.accentColor),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تحدي النشاط! 🔥',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'سكري راه طالع شوية، واش رايك نمشو 10 دقائق؟',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(healthStatsProvider.notifier).completeActivity(10);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                child: const Text('أبدأ الآن', style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.auto_awesome_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'لا توجد قياسات بعد.',
            style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على زر رفيق AI بالأسفل\nلفحص طعامك أو إضافة قراءة.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showAddReadingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddReadingDialog(),
    );
  }

  double _calculateAverage(List<dynamic> records) {
    if (records.isEmpty) return 0;
    double sum = 0;
    for (var r in records) {
      sum += r.value;
    }
    return sum / records.length;
  }
}

class _AnimatedBlob extends StatefulWidget {
  final Color color;
  final double size;

  const _AnimatedBlob({required this.color, required this.size});

  @override
  State<_AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<_AnimatedBlob> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}
