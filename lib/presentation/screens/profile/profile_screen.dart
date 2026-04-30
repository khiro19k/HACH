import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/safety_provider.dart';
import '../../providers/patient_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safety = ref.watch(safetyProvider);
    final patient = ref.watch(patientProvider).profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              patient?['full_name'] ?? 'مريض رفيق',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              patient?['phone_number'] ?? 'لا يوجد رقم هاتف',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildProfileOption(
              context, 
              Icons.bloodtype_rounded, 
              'فصيلة الدم',
              subtitle: patient?['blood_type'] ?? 'غير محدد',
              onTap: () {}
            ),
            _buildProfileOption(
              context, 
              Icons.monitor_heart_rounded, 
              'نوع السكري',
              subtitle: patient?['diabetes_type'] ?? 'غير محدد',
              onTap: () {}
            ),
            _buildProfileOption(
              context, 
              Icons.family_restroom_rounded, 
              'أفراد العائلة',
              subtitle: '${safety.familyContacts.length} جهات اتصال',
              onTap: () => _showFamilyManager(context, ref),
            ),
            _buildProfileOption(
              context, 
              Icons.notifications_active_rounded, 
              'الإشعارات والمواعيد', 
              onTap: () {}
            ),
            _buildProfileOption(
              context, 
              Icons.picture_as_pdf_rounded, 
              'تحميل تقرير الطبيب', 
              onTap: () {}
            ),
            _buildProfileOption(
              context, 
              Icons.security_rounded, 
              'الأمان والخصوصية', 
              onTap: () {}
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => ref.read(patientProvider.notifier).logout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50, 
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, IconData icon, String title, {String? subtitle, VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)) : null,
        trailing: const Icon(Icons.chevron_left_rounded, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showFamilyManager(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FamilyManagerSheet(),
    );
  }
}

class _FamilyManagerSheet extends ConsumerStatefulWidget {
  const _FamilyManagerSheet();

  @override
  ConsumerState<_FamilyManagerSheet> createState() => _FamilyManagerSheetState();
}

class _FamilyManagerSheetState extends ConsumerState<_FamilyManagerSheet> {
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final safety = ref.watch(safetyProvider);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'أفراد العائلة 👨‍👩‍👧‍👦',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const Text(
            'هؤلاء الأشخاص سيستلمون رسائل الاستغاثة في حالة الطوارئ.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          if (safety.familyContacts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text('لا توجد جهات اتصال مضافة', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: safety.familyContacts.length,
              itemBuilder: (context, index) {
                final contact = safety.familyContacts[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.person_outline_rounded)),
                  title: Text(contact, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    onPressed: () {
                      // Logic to remove contact
                      final newList = List<String>.from(safety.familyContacts)..removeAt(index);
                      _updateContacts(ref, newList);
                    },
                  ),
                );
              },
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: 'أدخل رقم الهاتف',
                    prefixIcon: const Icon(Icons.phone_rounded),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _addContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addContact() {
    if (_phoneController.text.isNotEmpty) {
      final safety = ref.read(safetyProvider);
      final newList = [...safety.familyContacts, _phoneController.text];
      _updateContacts(ref, newList);
      _phoneController.clear();
    }
  }

  Future<void> _updateContacts(WidgetRef ref, List<String> newList) async {
    // We need to add a method to safety_notifier to update contacts
    // For now, I'll update it via a new method in the notifier
    ref.read(safetyProvider.notifier).updateFamilyContacts(newList);
  }
}
