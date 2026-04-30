class Medication {
  final String id;
  final String? patientId;
  final String name;
  final String dosage;
  final String frequency; // Maps to times in UI
  final bool isTaken;
  final bool isDoctorPrescribed;

  Medication({
    required this.id,
    this.patientId,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.isTaken = false,
    this.isDoctorPrescribed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'med_name': name,
      'dosage': dosage,
      'frequency': frequency,
      'is_taken': isTaken,
      'is_doctor_prescribed': isDoctorPrescribed,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'].toString(),
      patientId: map['patient_id'],
      name: map['med_name'] ?? map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? map['times'] ?? '',
      isTaken: map['is_taken'] ?? map['isTaken'] == 1,
      isDoctorPrescribed: map['is_doctor_prescribed'] ?? map['isDoctorPrescribed'] == 1,
    );
  }
}

