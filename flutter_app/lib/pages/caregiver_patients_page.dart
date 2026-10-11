import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/medication_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'add_medication_page.dart';
import '../widgets/add_patient_dialog.dart';
import '../widgets/edit_patient_dialog.dart';
import 'reports_page.dart';

class CaregiverPatientsPage extends StatefulWidget {
  const CaregiverPatientsPage({super.key});

  @override
  State<CaregiverPatientsPage> createState() => _CaregiverPatientsPageState();
}

class _CaregiverPatientsPageState extends State<CaregiverPatientsPage> {
  Future<void> _addPatient(
    BuildContext context,
    DatabaseService db,
    String caregiverId,
  ) async {
    final details = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const AddPatientDialog(),
    );

    if (details == null) return;

    try {
      await db.createCaregiverPatient(
        caregiverId,
        details['relationship']!,
        patientDetails: {'name': details['name']!},
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient added to your care list.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to add patient: $error')),
        );
      }
    }
  }

  Future<void> _addMedication(String patientId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicationPage(ownerUserId: patientId),
      ),
    );
  }

  Future<void> _editMedication(String patientId, Medication medication) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicationPage(
          medication: medication,
          ownerUserId: patientId,
        ),
      ),
    );
  }

  Future<void> _editPatient(
    String caregiverId,
    Map<String, dynamic> patient,
    DatabaseService db,
  ) async {
    final details = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => EditPatientDialog(patient: patient),
    );
    if (details == null) return;

    final relationship = details.remove('relationship') ?? 'Patient';
    details.removeWhere((key, value) => value.trim().isEmpty);
    try {
      await db.updateCaregiverPatient(
        caregiverId,
        patient['id'] as String,
        relationship,
        patientDetails: details,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient details updated.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to update patient: $error')),
        );
      }
    }
  }

  Future<void> _removePatient(
    String caregiverId,
    Map<String, dynamic> patient,
    DatabaseService db,
  ) async {
    final name = (patient['name'] ?? 'this patient').toString();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove patient?'),
        content: Text(
          'Remove $name from your patient list? Their medication and report history will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await db.removeCaregiverPatient(caregiverId, patient['id'] as String);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name was removed from your patient list.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to remove patient: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final db = context.read<DatabaseService>();
    final caregiverId = auth.currentUserId;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to caregiver home',
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/caregiver'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('My Patients'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.blue,
        actions: [
          if (caregiverId != null)
            IconButton(
              tooltip: 'Add patient',
              onPressed: () => _addPatient(context, db, caregiverId),
              icon: const Icon(Icons.person_add_alt_1),
            ),
        ],
      ),
      body: caregiverId == null
          ? const Center(child: Text('Please log in to view your patients.'))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: db.getCaregiverPatients(caregiverId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child:
                          Text('Unable to load patients: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final patients = snapshot.data ?? [];
                if (patients.isEmpty) {
                  return _emptyState(context, db, caregiverId);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return _patientCard(patient, db, caregiverId);
                  },
                );
              },
            ),
      floatingActionButton: caregiverId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _addPatient(context, db, caregiverId),
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add patient'),
            ),
    );
  }

  Widget _emptyState(
    BuildContext context,
    DatabaseService db,
    String caregiverId,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 52, color: AppColors.blue),
            const SizedBox(height: 12),
            const Text(
              'No patients added yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add as many patients as you care for, then create a medication plan for each one.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.subText),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _addPatient(context, db, caregiverId),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add patient'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _patientCard(
    Map<String, dynamic> patient,
    DatabaseService db,
    String caregiverId,
  ) {
    final patientId = patient['id'] as String;
    final name = (patient['name'] ?? 'Patient').toString();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F0FF),
                child: Icon(Icons.person, color: AppColors.blue),
              ),
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                patient['relationship']?.toString() ?? 'Patient',
              ),
              trailing: Text(
                patientId,
                style: const TextStyle(fontSize: 10, color: AppColors.subText),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _editPatient(caregiverId, patient, db),
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: const Text('Edit patient'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportsPage(
                        caregiverMode: true,
                        initialPatientId: patientId,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 17),
                  label: const Text('Patient report'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _removePatient(caregiverId, patient, db),
                  icon: const Icon(Icons.person_remove_outlined, size: 17),
                  label: const Text('Remove patient'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Medication plan',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _addMedication(patientId),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add medication'),
                ),
              ],
            ),
            StreamBuilder<List<Medication>>(
              stream: db.getMedications(patientId),
              builder: (context, snapshot) {
                final medications = snapshot.data ?? [];
                if (medications.isEmpty) {
                  return const Text(
                    'No medication plan added yet.',
                    style: TextStyle(color: AppColors.subText),
                  );
                }
                return Column(
                  children: medications
                      .map(
                        (medication) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.medication_outlined,
                            color: AppColors.blue,
                          ),
                          title: Text(medication.name),
                          subtitle: Text(
                            '${medication.dosage} • ${medication.frequency} • ${medication.doseTimes.join(', ')}',
                          ),
                          trailing: IconButton(
                            tooltip: 'Edit medication',
                            onPressed: () =>
                                _editMedication(patientId, medication),
                            icon: const Icon(Icons.edit_outlined, size: 19),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
