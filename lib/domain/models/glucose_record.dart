class GlucoseRecord {
  final String id;
  final double value;
  final DateTime timestamp;
  final String type; // e.g., 'fasting', 'after_meal'
  final String? notes;

  GlucoseRecord({
    required this.id,
    required this.value,
    required this.timestamp,
    required this.type,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'glucose_level': value,
      'created_at': timestamp.toIso8601String(),
      'reading_context': type,
      'notes': notes,
    };
  }

  factory GlucoseRecord.fromMap(Map<String, dynamic> map) {
    return GlucoseRecord(
      id: map['id'].toString(),
      value: (map['glucose_level'] ?? map['value'] ?? 0).toDouble(),
      timestamp: DateTime.parse(map['created_at'] ?? map['timestamp'] ?? DateTime.now().toIso8601String()),
      type: map['reading_context'] ?? map['type'] ?? 'unknown',
      notes: map['notes'],
    );
  }
}

