import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/glucose_levels_info.dart';
import '../../providers/glucose_provider.dart';

class AddReadingDialog extends ConsumerStatefulWidget {
  const AddReadingDialog({super.key});

  @override
  ConsumerState<AddReadingDialog> createState() => _AddReadingDialogState();
}

class _AddReadingDialogState extends ConsumerState<AddReadingDialog> {
  final _controller = TextEditingController();
  GlucoseLevelInfo? _currentInfo;
  String _selectedType = 'صائم';

  void _updateInfo(String value) {
    final doubleValue = double.tryParse(value);
    if (doubleValue != null) {
      setState(() {
        _currentInfo = GlucoseLevelInfo.getInfo(doubleValue);
      });
    } else {
      setState(() {
        _currentInfo = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'إضافة قراءة جديدة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '0.00',
                  suffixText: 'mg/dL',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onChanged: _updateInfo,
              ),
              const SizedBox(height: 20),
              _buildTypeSelector(),
              const SizedBox(height: 24),
              if (_currentInfo != null) _buildFeedbackCard(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentInfo == null ? null : _saveReading,
                      child: const Text('حفظ القراءة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final types = ['صائم', 'بعد الأكل', 'قبل النوم', 'أخرى'];
    return Wrap(
      spacing: 8,
      children: types.map((type) {
        final isSelected = _selectedType == type;
        return ChoiceChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (val) => setState(() => _selectedType = type),
          selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryColor : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _currentInfo!.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _currentInfo!.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_currentInfo!.color == Colors.green ? Icons.check_circle : Icons.warning, color: _currentInfo!.color),
              const SizedBox(width: 8),
              Text(
                _currentInfo!.status,
                style: TextStyle(fontWeight: FontWeight.bold, color: _currentInfo!.color, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentInfo!.treatment,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  void _saveReading() {
    final value = double.parse(_controller.text);
    ref.read(glucoseProvider.notifier).addRecord(value, _selectedType, null);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ القراءة بنجاح', textAlign: TextAlign.center)),
    );
  }
}
