import 'package:flutter/material.dart';

class EditPatientDialog extends StatefulWidget {
  const EditPatientDialog({super.key, required this.patient});

  final Map<String, dynamic> patient;

  @override
  State<EditPatientDialog> createState() => _EditPatientDialogState();
}

class _EditPatientDialogState extends State<EditPatientDialog> {
  late final Map<String, TextEditingController> _controllers;
  final _formKey = GlobalKey<FormState>();

  static const _fields = <String, String>{
    'name': 'Full name *',
    'relationship': 'Relationship *',
    'age': 'Age',
    'gender': 'Gender',
    'phone': 'Phone number',
    'email': 'Email address',
    'address': 'Address',
    'medicalConditions': 'Medical conditions',
    'allergies': 'Allergies',
    'emergencyContactName': 'Emergency contact name',
    'emergencyContactPhone': 'Emergency contact phone',
  };

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final entry in _fields.entries)
        entry.key: TextEditingController(
          text: widget.patient[entry.key]?.toString() ?? '',
        ),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit patient details'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _fields.entries.map((entry) {
                final isRequired =
                    entry.key == 'name' || entry.key == 'relationship';
                return TextFormField(
                  controller: _controllers[entry.key],
                  decoration: InputDecoration(labelText: entry.value),
                  maxLines:
                      entry.key == 'address' || entry.key == 'medicalConditions'
                          ? 2
                          : 1,
                  validator: isRequired
                      ? (value) => value == null || value.trim().isEmpty
                          ? '${entry.value.replaceAll(' *', '')} is required'
                          : null
                      : null,
                );
              }).toList(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              <String, String>{
                for (final entry in _controllers.entries)
                  entry.key: entry.value.text.trim(),
              },
            );
          },
          child: const Text('Save changes'),
        ),
      ],
    );
  }
}
