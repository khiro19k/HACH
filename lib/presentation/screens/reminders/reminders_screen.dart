import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/medication.dart';
import '../../providers/medication_provider.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  @override
  Widget build(BuildContext context) {
    final medicationState = ref.watch(medicationProvider);
    final medications = medicationState.medications;
    final takenCount = medications.where((m) => m.isTaken).length;

    return Scaffold(
      body: Stack(
        children: [
          // Vibrant Background with Animated-like Orbs
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.bgGradientStart, AppTheme.bgGradientEnd],
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentColor.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  floating: true,
                  title: Text(
                    'تنبيهاتي',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 10),
                      _buildHeaderCard(medications.length, takenCount),
                      const SizedBox(height: 30),
                      
                      // Doctor's Prescription Section (New)
                      _buildDoctorSection(medications),
                      
                      const SizedBox(height: 24),
                      if (medications.where((m) => !m.isDoctorPrescribed).isEmpty)
                        _buildVibrantEmptyState()
                      else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'جدولي الخاص',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            Text(
                              'يدوي',
                              style: TextStyle(
                                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...medications.where((m) => !m.isDoctorPrescribed).map((med) => _buildModernMedCard(med, ref)).toList(),
                      ],
                      const SizedBox(height: 120), // Padding for bottom nav & FAB
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 90, right: 10),
        child: FloatingActionButton(
          backgroundColor: AppTheme.accentColor,
          elevation: 8,
          onPressed: () => _showAddMedicationDialog(context, ref),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildDoctorSection(List<Medication> allMeds) {
    final doctorMeds = allMeds.where((m) => m.isDoctorPrescribed).toList();
    
    // If no doctor meds, we show a sample one for demonstration as requested
    if (doctorMeds.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.accentColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.medical_services_rounded, color: AppTheme.accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('وصفة الطبيب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor)),
                const Spacer(),
                const Badge(label: Text('تحديث'), backgroundColor: AppTheme.accentColor),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'سيظهر هنا الدواء الذي يضيفه لك طبيبك الخاص مباشرة من المنصة.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: AppTheme.accentColor, size: 20),
            const SizedBox(width: 8),
            const Text('وصفة الطبيب (معتمدة)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor)),
          ],
        ),
        const SizedBox(height: 16),
        ...doctorMeds.map((med) => _buildModernMedCard(med, ref, isDoctor: true)).toList(),
      ],
    );
  }

  Widget _buildHeaderCard(int total, int taken) {
    return Column(
      children: [
        // Horizontal Calendar Wrapper
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 7,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index - 3));
              final isToday = index == 3;
              return Container(
                width: 60,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isToday ? AppTheme.primaryColor : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isToday ? AppTheme.primaryColor : Colors.white, width: 1.5),
                  boxShadow: isToday ? [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getWeekdayName(date.weekday),
                      style: TextStyle(
                        fontSize: 12,
                        color: isToday ? Colors.white70 : AppTheme.secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isToday ? Colors.white : AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        
        // Practical Summary Card OR AI Welcome Insight
        if (total == 0)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً بك في رفيق!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ابدأ بإضافة أول دواء لك لنقوم بتنظيم جدولك الصحي بدقة.',
                        style: TextStyle(fontSize: 12, color: AppTheme.secondaryTextColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time_filled_rounded, color: Colors.white.withValues(alpha: 0.8), size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'الموعد القادم',
                              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '10:30 صباحاً',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'دواء الضغط (500mg)',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(color: Colors.white.withValues(alpha: 0.2), thickness: 1, indent: 5, endIndent: 5),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: taken / total,
                            strokeWidth: 6,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            color: AppTheme.accentColor,
                            strokeCap: StrokeCap.round,
                          ),
                          Text(
                            '${(taken / total * 100).toInt()}%',
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$taken/$total مكتمل',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _getWeekdayName(int weekday) {
    const names = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];
    return names[weekday - 1];
  }

  Widget _buildModernMedCard(Medication medication, WidgetRef ref, {bool isDoctor = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: isDoctor ? Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDoctor ? AppTheme.accentColor.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: medication.isTaken 
                        ? [AppTheme.accentColor, AppTheme.accentColor.withValues(alpha: 0.6)]
                        : (isDoctor ? [const Color(0xFF6366F1), const Color(0xFF818CF8)] : [Colors.orange, Colors.orange.withValues(alpha: 0.6)]),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(isDoctor ? Icons.auto_awesome : Icons.medication_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              medication.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                decoration: medication.isTaken ? TextDecoration.lineThrough : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isDoctor) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.verified, color: AppTheme.accentColor, size: 16),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        medication.dosage,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryColor.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        medication.frequency,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => ref.read(medicationProvider.notifier).toggleTaken(medication.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: medication.isTaken ? AppTheme.accentColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: medication.isTaken ? AppTheme.accentColor : AppTheme.primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      medication.isTaken ? 'تم' : 'أخذ الآن',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: medication.isTaken ? Colors.white : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVibrantEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.primaryColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
              Icon(
                Icons.medical_services_rounded,
                size: 80,
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'جدولك فارغ تماماً',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'أضف أدويتك اليومية لنساعدك على تذكرها في الوقت المناسب.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMedicationDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'إضافة دواء جديد',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'اسم الدواء',
                      prefixIcon: const Icon(Icons.medication_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dosageController,
                    decoration: InputDecoration(
                      labelText: 'الجرعة (مثلاً: 500 ملغ)',
                      prefixIcon: const Icon(Icons.scale_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('موعد التناول', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: selectedTime);
                      if (time != null) setModalState(() => selectedTime = time);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_filled_rounded, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            selectedTime.format(context),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          const Text('تغيير الوقت', style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty && dosageController.text.isNotEmpty) {
                          final timeStr = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                          ref.read(medicationProvider.notifier).addMedication(
                            nameController.text,
                            dosageController.text,
                            timeStr,
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('حفظ الدواء', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

