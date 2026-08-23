import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/medication_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({Key? key}) : super(key: key);

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _quantityController = TextEditingController();
  final _refillController = TextEditingController();

  String _frequency = 'Daily';
  String _takeWith = 'Before Meal';
  String _category = 'Pill';
  List<String> _doseTimes = ['08:00 AM'];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _instructionsController.dispose();
    _quantityController.dispose();
    _refillController.dispose();
    super.dispose();
  }

  Future<void> _saveMedication() async {
    if (_nameController.text.isEmpty || _dosageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name and dosage')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      final userId = authService.currentUserId;

      if (userId == null) throw Exception("User not logged in");

      final medication = Medication(
        userId: userId,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        category: _category,
        frequency: _frequency,
        doseTimes: _doseTimes,
        startDate: _startDateController.text.trim(),
        endDate: _endDateController.text.trim(),
        takeWith: _takeWith,
        instructions: _instructionsController.text.trim(),
        totalQuantity: int.tryParse(_quantityController.text) ?? 0,
        refillAlertAt: int.tryParse(_refillController.text) ?? 0,
      );

      await dbService.addMedication(medication);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 12),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(bottom: BorderSide(color: AppColors.inputBorder)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Text('←', style: TextStyle(fontSize: 20, color: AppColors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const Text('Add Medication', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.blue)),
                ],
              ),
            ),
            
            // Scroll Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Section 1
                  _buildSectionHeader('ℹ️', 'Basic Information'),
                  _buildLabel('Medication Name'),
                  _buildInput(controller: _nameController, hint: 'e.g. Amoxicillin'),
                  
                  _buildLabel('Dosage'),
                  _buildInput(controller: _dosageController, hint: 'e.g. 500mg, 10ml'),

                  _buildLabel('Form / Category'),
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: const Color(0xFFCBD5E0)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _category,
                        isExpanded: true,
                        isDense: true,
                        style: const TextStyle(color: AppColors.primaryText, fontSize: 13),
                        onChanged: (String? newValue) {
                          setState(() {
                            _category = newValue!;
                          });
                        },
                        items: <String>['Pill', 'Capsule', 'Liquid', 'Injection', 'Other']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Section 2
                  const SizedBox(height: 12),
                  _buildSectionHeader('⏰', 'Schedule & Frequency'),
                  
                  _buildLabel('How often?'),
                  _buildGrid(['Daily', 'Weekly', 'Monthly', 'As Needed'], _frequency, (val) => setState(() => _frequency = val), false),

                  _buildLabel('Dose Times'),
                  ..._doseTimes.asMap().entries.map((entry) {
                    int idx = entry.key;
                    String time = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border.all(color: const Color(0xFFCBD5E0)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(time, style: const TextStyle(fontSize: 13, color: AppColors.primaryText)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              if (_doseTimes.length > 1) {
                                setState(() => _doseTimes.removeAt(idx));
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFED7D7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('🗑️', style: TextStyle(fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _doseTimes.add('08:00 PM'));
                      },
                      child: const Text('+ Add another time', style: TextStyle(fontSize: 12, color: Color(0xFF006A60), fontWeight: FontWeight.w700)),
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Start Date'),
                            _buildInput(controller: _startDateController, hint: 'mm/dd/yyyy'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('End Date (Optional)'),
                            _buildInput(controller: _endDateController, hint: 'mm/dd/yyyy'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Section 3
                  const SizedBox(height: 12),
                  _buildSectionHeader('📋', 'Instructions & Inventory'),
                  
                  _buildLabel('Take With'),
                  _buildGrid(['Before Meal', 'With Meal', 'After Meal', 'Empty Stomach'], _takeWith, (val) => setState(() => _takeWith = val), true),

                  _buildLabel('Special Instructions'),
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: const Color(0xFFCBD5E0)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    height: 70,
                    child: TextField(
                      controller: _instructionsController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13, color: AppColors.primaryText),
                      decoration: const InputDecoration(
                        hintText: 'e.g. Take with plenty of water',
                        hintStyle: TextStyle(color: Color(0xFFA0AEC0)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Total Quantity'),
                            _buildInput(controller: _quantityController, hint: 'e.g. 30', keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Remind to refill at'),
                            _buildInput(controller: _refillController, hint: 'e.g. 5', keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Submit Button
                  Container(
                    margin: const EdgeInsets.only(top: 24, bottom: 30),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveMedication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Medication', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.blue)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A5568))),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String hint, TextInputType? keyboardType}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFCBD5E0)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: AppColors.primaryText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildGrid(List<String> items, String selectedValue, Function(String) onSelect, bool lightActiveBg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) {
          bool isActive = selectedValue == item;
          return GestureDetector(
            onTap: () => onSelect(item),
            child: Container(
              width: (MediaQuery.of(context).size.width - 32 - 8) / 2,
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? (lightActiveBg ? const Color(0xFFEDF4FF) : AppColors.blue) : AppColors.white,
                border: Border.all(color: isActive ? AppColors.blue : const Color(0xFFCBD5E0)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? (lightActiveBg ? AppColors.blue : Colors.white) : const Color(0xFF4A5568),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
