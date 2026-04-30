import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/glucose_record.dart';

class RecentReadingsList extends StatelessWidget {
  final List<GlucoseRecord> records;

  const RecentReadingsList({required this.records, super.key});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('لا توجد قياسات بعد. اضغط على + للإضافة.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length > 5 ? 5 : records.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: const Icon(Icons.water_drop, color: Colors.blue, size: 20),
            ),
            title: Text(
              '${record.value} mg/dL',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${record.type} • ${DateFormat('hh:mm a').format(record.timestamp)}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () {},
          ),
        );
      },
    );
  }
}
