import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../models/medication_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/bottom_nav.dart';
import 'add_medication_page.dart';

class CaregiverHomePage extends StatefulWidget {
  const CaregiverHomePage({super.key});

  @override
  State<CaregiverHomePage> createState() => _CaregiverHomePageState();
}

class _CaregiverHomePageState extends State<CaregiverHomePage> {
  String? _selectedPatientId;
  final Set<String> _acknowledgedDemoAlerts = {};

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final db = Provider.of<DatabaseService>(context);
    final caregiverId = auth.currentUserId;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
              color: AppColors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('MediTrack', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.blue)),
                  IconButton(
                    tooltip: 'Sign out',
                    onPressed: () async {
                      await auth.signOut();
                      if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout_rounded, color: AppColors.blue, size: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: caregiverId == null
                  ? const Center(child: Text('Please log in to view your patients.'))
                  : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: db.getCaregiverPatients(caregiverId),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) return Center(child: Text('Unable to load patients: ${snapshot.error}'));
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: Text('Loading patients...', style: TextStyle(color: AppColors.subText)));
                        }
                        final patients = snapshot.data ?? [];
                        if (patients.isEmpty) return _buildNoPatients(context, db, caregiverId);
                        final patient = patients.firstWhere(
                          (item) => item['id'] == _selectedPatientId,
                          orElse: () => patients.first,
                        );
                        if (_selectedPatientId != patient['id']) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) setState(() => _selectedPatientId = patient['id'] as String);
                          });
                        }
                        return _buildPatientDashboard(context, db, patient, patients, caregiverId);
                      },
                    ),
            ),
            const BottomNav(activeTab: 'Home', caregiverMode: true),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPatients(BuildContext context, DatabaseService db, String caregiverId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 48, color: AppColors.blue),
            const SizedBox(height: 12),
            const Text('No patients linked yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primaryText)),
            const SizedBox(height: 6),
            const Text('Add a patient using their account ID to view their care dashboard.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.subText)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _addPatient(context, db, caregiverId),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add patient'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientDashboard(
    BuildContext context,
    DatabaseService db,
    Map<String, dynamic> patient,
    List<Map<String, dynamic>> patients,
    String caregiverId,
  ) {
    final patientId = patient['id'] as String;
    final name = (patient['name'] ?? 'Patient').toString();
    final logsStream = db.getAdherenceLogs(patientId);
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      children: [
        _profileCard(context, patient, name),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(child: Text('My Patients', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryText))),
            Text('${patients.length} linked', style: const TextStyle(fontSize: 10, color: AppColors.subText)),
            const SizedBox(width: 6),
            _roundAction(Icons.person_add_alt_1, 'Add patient', () => _addPatient(context, db, caregiverId)),
          ],
        ),
        const SizedBox(height: 7),
        ...patients.map((item) => _patientTile(item, patientId)),
        const SizedBox(height: 8),
        StreamBuilder<List<Medication>>(
          stream: db.getMedications(patientId),
          builder: (context, medSnapshot) {
            final medications = medSnapshot.data ?? [];
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: logsStream,
              builder: (context, logSnapshot) {
                final logs = logSnapshot.data ?? [];
                final missed = logs.where((log) => log['status'] == 'missed' && log['acknowledged'] != true).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (missed.isNotEmpty || (DatabaseService.isSimulation && !_acknowledgedDemoAlerts.contains(patientId)))
                      _missedAlert(context, db, patientId, name, missed.isEmpty ? null : missed.first),
                    _sectionTitle('Today\'s Schedule', trailing: DateFormat('MMM d').format(DateTime.now())),
                    if (medSnapshot.connectionState == ConnectionState.waiting)
                      const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('Loading schedule...', style: TextStyle(fontSize: 9, color: AppColors.subText))))
                    else if (medications.isEmpty)
                      _emptySection('No medications scheduled.')
                    else
                      ...medications.map((med) => _medicationRow(med)),
                    const SizedBox(height: 7),
                    _sectionTitle('Weekly Adherence'),
                    _adherenceCard(logs, name),
                    const SizedBox(height: 7),
                    _sectionTitle('Recent Notes'),
                    _notesCard(context, db, patientId, caregiverId),
                    const SizedBox(height: 4),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _patientTile(Map<String, dynamic> patient, String selectedId) {
    final id = patient['id'] as String;
    final selected = id == selectedId;
    final name = (patient['name'] ?? 'Patient').toString();
    return InkWell(
      onTap: () => setState(() => _selectedPatientId = id),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(color: AppColors.white, border: Border.all(color: selected ? AppColors.blue : AppColors.border), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            CircleAvatar(radius: 12, backgroundColor: const Color(0xFFE7E8EA), child: Icon(Icons.person, size: 13, color: Colors.grey.shade600)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryText)),
                Text('${patient['age'] ?? 'Age not set'} • ${patient['relationship'] ?? 'Patient'}', style: const TextStyle(fontSize: 11, color: AppColors.subText)),
              ]),
            ),
            if (patient['adherence'] != null) _statusPill('${patient['adherence']}%', const Color(0xFFEAF6EF), const Color(0xFF389A64)),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(BuildContext context, Map<String, dynamic> patient, String name) {
    final since = patient['monitoringSince']?.toString() ?? 'Monitoring since today';
    final age = patient['age']?.toString();
    final relationship = patient['relationship']?.toString();
    final phone = patient['phone']?.toString();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 14, backgroundColor: const Color(0xFFE8E8E8), child: Icon(Icons.person, size: 17, color: Colors.grey.shade700)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
                  Text(since, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                ]),
              ),
            ],
          ),
          if ((age != null && age.isNotEmpty) || (relationship != null && relationship.isNotEmpty) || (phone != null && phone.isNotEmpty)) ...[
            const SizedBox(height: 7),
            if (age != null && age.isNotEmpty)
              _patientDetail(Icons.cake_outlined, age),
            if (relationship != null && relationship.isNotEmpty)
              _patientDetail(Icons.people_outline, relationship),
            if (phone != null && phone.isNotEmpty)
              _patientDetail(Icons.call_outlined, phone),
          ],
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(child: _smallButton('Call', Icons.call_outlined, const Color(0xFFF7F9FB), AppColors.primaryText, () => _callPatient(patient))),
              const SizedBox(width: 6),
              Expanded(child: _smallButton('Edit Meds', Icons.edit_outlined, const Color(0xFF454545), Colors.white, () => _chooseMedication(context, patient))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _patientDetail(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppColors.secondaryText),
          const SizedBox(width: 5),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText))),
        ],
      ),
    );
  }

  Widget _missedAlert(BuildContext context, DatabaseService db, String patientId, String name, Map<String, dynamic>? log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(color: const Color(0xFFF1F1F1), border: Border.all(color: const Color(0xFFE0E0E0)), borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 13, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Missed Dose Alert', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFB64747))),
              Text(name, style: const TextStyle(fontSize: 12, color: Color(0xFFB64747))),
              Text('${log?['medicationName'] ?? 'Metformin'} missed her morning dose of ${log?['medicationName'] ?? 'Metformin'}', style: const TextStyle(fontSize: 12, height: 1.3, color: Color(0xFFB64747))),
              const Text('(8:00 AM)', style: TextStyle(fontSize: 12, color: Color(0xFFB64747))),
            ]),
          ),
          TextButton(
            onPressed: () async {
              final logId = log?['id']?.toString();
              if (logId != null && !logId.startsWith('sim_')) await db.acknowledgeMissedDose(logId);
              if (mounted) setState(() => _acknowledgedDemoAlerts.add(patientId));
            },
            style: TextButton.styleFrom(backgroundColor: const Color(0xFF737373), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: const Text('Acknowledge', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _medicationRow(Medication medication) {
    final time = medication.doseTimes.isEmpty ? 'Any time' : medication.doseTimes.first;
    final color = medication.name.toLowerCase().contains('lisinopril') ? const Color(0xFFECECEC) : const Color(0xFFF7F7F7);
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 48, child: Align(alignment: Alignment.topCenter, child: Text(time, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)))),
          Container(width: 1, height: 36, color: AppColors.border, margin: const EdgeInsets.only(right: 6)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
              decoration: BoxDecoration(color: color, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(6)),
              child: Row(
                children: [
                  const Icon(Icons.medication_outlined, size: 14, color: Color(0xFF666666)),
                  const SizedBox(width: 6),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(medication.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
                    Text('${medication.dosage} • ${medication.takeWith}', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                  ])),
                  _statusPill(medication.lastTaken == null ? 'Upcoming' : 'Taken', medication.lastTaken == null ? const Color(0xFFE9F4EC) : const Color(0xFFE7F2EB), const Color(0xFF43845A)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _adherenceCard(List<Map<String, dynamic>> logs, String patientName) {
    final taken = logs.where((log) => log['status'] == 'taken').length;
    final missed = logs.where((log) => log['status'] == 'missed').length;
    final percent = DatabaseService.isSimulation
      ? 92
      : taken + missed == 0
        ? 0
        : (taken * 100 / (taken + missed)).round();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          SizedBox(
            width: 43,
            height: 43,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(width: 40, height: 40, child: CircularProgressIndicator(value: percent / 100, strokeWidth: 4, backgroundColor: const Color(0xFFE4E4E4), color: const Color(0xFF424242))),
              Text('$percent%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Doing Great!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
            Text('$patientName has taken $taken of ${DatabaseService.isSimulation ? 11 : taken + missed} scheduled doses this week.', style: const TextStyle(fontSize: 12, height: 1.3, color: AppColors.secondaryText)),
          ])),
        ],
      ),
    );
  }

  Widget _notesCard(BuildContext context, DatabaseService db, String patientId, String caregiverId) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(color: AppColors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: db.getCaregiverNotes(patientId),
        builder: (context, snapshot) {
          final notes = snapshot.data ?? [];
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (notes.isEmpty)
              const Text('No recent notes.', style: TextStyle(fontSize: 12, color: AppColors.subText))
            else
              ...notes.take(2).map((note) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(note['text']?.toString() ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, height: 1.3, color: AppColors.secondaryText, fontStyle: FontStyle.italic)),
                  )),
            TextButton.icon(
              onPressed: () => _addNote(context, db, patientId, caregiverId),
              icon: const Icon(Icons.edit_note, size: 12),
              label: const Text('Add Note', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(foregroundColor: AppColors.blue, padding: EdgeInsets.zero, minimumSize: const Size(0, 22), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            ),
          ]);
        },
      ),
    );
  }

  Widget _sectionTitle(String title, {String? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
        if (trailing != null) _statusPill(trailing, const Color(0xFFF0F0F0), AppColors.secondaryText),
      ]),
    );
  }

  Widget _smallButton(String label, IconData icon, Color background, Color foreground, VoidCallback onPressed) {
    return SizedBox(
      height: 24,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 12),
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(backgroundColor: background, foregroundColor: foreground, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 8), shape: const StadiumBorder()),
      ),
    );
  }

  Widget _roundAction(IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(tooltip: tooltip, onPressed: onTap, icon: Icon(icon, size: 16, color: AppColors.blue), constraints: const BoxConstraints.tightFor(width: 30, height: 30), padding: EdgeInsets.zero);
  }

  Widget _statusPill(String label, Color background, Color foreground) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(10)), child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: foreground)));
  }

  Widget _emptySection(String label) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)), child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.subText)));
  }

  Future<void> _addPatient(BuildContext context, DatabaseService db, String caregiverId) async {
    final idController = TextEditingController();
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    final genderController = TextEditingController();
    final conditionsController = TextEditingController();
    final allergiesController = TextEditingController();
    final emergencyNameController = TextEditingController();
    final emergencyPhoneController = TextEditingController();
    final relationshipController = TextEditingController(text: 'Patient');
    final formKey = GlobalKey<FormState>();

    final patientDetails = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add patient'),
        content: SizedBox(
          width: 440,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.65),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: idController,
                      decoration: const InputDecoration(labelText: 'Patient account ID *'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Account ID is required' : null,
                    ),
                    TextFormField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Full name *'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Full name is required' : null,
                    ),
                    TextFormField(
                      controller: relationshipController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Relationship *'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Relationship is required' : null,
                    ),
                    TextFormField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Age'),
                    ),
                    TextFormField(
                      controller: genderController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Gender'),
                    ),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone number'),
                    ),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email address'),
                    ),
                    TextFormField(
                      controller: addressController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Address'),
                      maxLines: 2,
                    ),
                    TextFormField(
                      controller: conditionsController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Medical conditions'),
                      maxLines: 2,
                    ),
                    TextFormField(
                      controller: allergiesController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Allergies'),
                    ),
                    TextFormField(
                      controller: emergencyNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Emergency contact name'),
                    ),
                    TextFormField(
                      controller: emergencyPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Emergency contact phone'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(dialogContext, {
                'id': idController.text.trim(),
                'name': nameController.text.trim(),
                'relationship': relationshipController.text.trim(),
                'age': ageController.text.trim(),
                'gender': genderController.text.trim(),
                'phone': phoneController.text.trim(),
                'email': emailController.text.trim(),
                'address': addressController.text.trim(),
                'medicalConditions': conditionsController.text.trim(),
                'allergies': allergiesController.text.trim(),
                'emergencyContactName': emergencyNameController.text.trim(),
                'emergencyContactPhone': emergencyPhoneController.text.trim(),
              });
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    final controllers = [
      idController,
      nameController,
      ageController,
      phoneController,
      emailController,
      addressController,
      genderController,
      conditionsController,
      allergiesController,
      emergencyNameController,
      emergencyPhoneController,
      relationshipController,
    ];
    for (final controller in controllers) {
      controller.dispose();
    }

    if (patientDetails == null) return;
    final patientId = patientDetails['id'];
    final relationship = patientDetails['relationship'];
    if (patientId == null || patientId.isEmpty || relationship == null || relationship.isEmpty) return;

    try {
      final details = Map<String, dynamic>.from(patientDetails)..remove('id')..remove('relationship');
      details.removeWhere((key, value) => value.toString().trim().isEmpty);
      await db.linkCaregiverPatient(caregiverId, patientId, relationship, patientDetails: details);
      if (mounted) setState(() => _selectedPatientId = patientId);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Patient linked.')));
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to link patient: $error')));
    }
  }

  Future<void> _callPatient(Map<String, dynamic> patient) async {
    final phone = patient['phone']?.toString();
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No phone number is saved for this patient.')));
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling is not available on this device.')));
    }
  }

  Future<void> _chooseMedication(BuildContext context, Map<String, dynamic> patient) async {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final patientId = patient['id'] as String;
    final medications = await db.getMedications(patientId).first;
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Edit patient medication', style: TextStyle(fontWeight: FontWeight.w700))),
            if (medications.isEmpty) const ListTile(title: Text('No medications to edit.')),
            ...medications.map((medication) => ListTile(
                  leading: const Icon(Icons.medication_outlined, color: AppColors.blue),
                  title: Text(medication.name),
                  subtitle: Text(medication.dosage),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    if (!mounted) return;
                    await Navigator.push(this.context, MaterialPageRoute(builder: (_) => AddMedicationPage(medication: medication, ownerUserId: patientId)));
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _addNote(BuildContext context, DatabaseService db, String patientId, String caregiverId) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add note'),
        content: TextField(controller: controller, maxLines: 4, decoration: const InputDecoration(hintText: 'Write a care note', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (note == null || note.isEmpty) return;
    try {
      await db.addCaregiverNote(patientId, caregiverId, note);
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to save note: $error')));
    }
    controller.dispose();
  }
}