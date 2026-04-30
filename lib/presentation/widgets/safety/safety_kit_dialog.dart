import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/safety_provider.dart';

class SafetyKitDialog extends ConsumerStatefulWidget {
  const SafetyKitDialog({super.key});

  @override
  ConsumerState<SafetyKitDialog> createState() => _SafetyKitDialogState();
}

class _SafetyKitDialogState extends ConsumerState<SafetyKitDialog> {
  final List<Map<String, dynamic>> _items = [
    {'title': 'جهاز قياس السكر', 'icon': Icons.speed_rounded, 'checked': false},
    {'title': 'قطع سكر / عصير', 'icon': Icons.fastfood_rounded, 'checked': false},
    {'title': 'إبرة الإنسولين', 'icon': Icons.medication_rounded, 'checked': false},
    {'title': 'بطاقة تعريف المريض', 'icon': Icons.badge_rounded, 'checked': false},
  ];

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_bag_rounded, color: AppTheme.accentColor, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'خروج آمن؟ 🌍',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'تأكد من حمل حقيبة الطوارئ معك',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ...List.generate(_items.length, (index) {
                return _buildCheckItem(index);
              }),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _allChecked() ? _onConfirm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('أنا جاهز الآن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _allChecked() => _items.every((item) => item['checked'] == true);

  void _onConfirm() {
    ref.read(safetyProvider.notifier).setSafetyKitChecked(true);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('رافقتك السلامة! وضع الحماية القصوى مفعل الآن.'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  Widget _buildCheckItem(int index) {
    final item = _items[index];
    return GestureDetector(
      onTap: () {
        setState(() {
          _items[index]['checked'] = !item['checked'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: item['checked'] ? AppTheme.accentColor.withValues(alpha: 0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item['checked'] ? AppTheme.accentColor.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(item['icon'], color: item['checked'] ? AppTheme.accentColor : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item['title'],
                style: TextStyle(
                  fontWeight: item['checked'] ? FontWeight.bold : FontWeight.normal,
                  color: item['checked'] ? AppTheme.primaryColor : Colors.black87,
                ),
              ),
            ),
            Checkbox(
              value: item['checked'],
              onChanged: (val) {
                setState(() => _items[index]['checked'] = val!);
              },
              activeColor: AppTheme.accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ],
        ),
      ),
    );
  }
}
