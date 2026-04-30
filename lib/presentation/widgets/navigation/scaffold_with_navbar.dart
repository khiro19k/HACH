import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../glass_bottom_nav.dart';
import '../home/add_reading_dialog.dart';
import '../../providers/safety_provider.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          // The main page content
          child,
          
          // The custom Glassmorphism bottom navigation
          GlassBottomNav(
            currentIndex: _calculateSelectedIndex(context),
            onTap: (index) => _onItemTapped(index, context),
            onFabTap: () => _showActionSheet(context),
            onFabLongPress: () {
              // Trigger SOS
              ref.read(safetyProvider.notifier).triggerPanicSOS();
              // Show feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🚨 تم إرسال نداء استغاثة للطبيب والعائلة', textAlign: TextAlign.center),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ماذا تريد أن تفعل؟',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildActionItem(
              context,
              icon: Icons.chat_bubble_rounded,
              title: 'استعن بالذكاء الاصطناعي',
              subtitle: 'اسأل رفيق عن أي شيء يخص صحتك',
              color: const Color(0xFF6B48FF),
              onTap: () {
                Navigator.pop(context);
                context.push('/ai-chat');
              },
            ),
            const SizedBox(height: 16),
            _buildActionItem(
              context,
              icon: Icons.add_chart_rounded,
              title: 'إضافة قياس يدوي',
              subtitle: 'سجل مستوى السكر في دمك',
              color: const Color(0xFF00CFA5),
              onTap: () {
                Navigator.pop(context);
                _showAddReadingDialog(context);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showAddReadingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddReadingDialog(),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location == '/') return 0;
    if (location == '/health-score') return 1;
    if (location == '/reminders') return 2;
    if (location == '/profile') return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/');
        break;
      case 1:
        GoRouter.of(context).go('/health-score');
        break;
      case 2:
        GoRouter.of(context).go('/reminders');
        break;
      case 3:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}

