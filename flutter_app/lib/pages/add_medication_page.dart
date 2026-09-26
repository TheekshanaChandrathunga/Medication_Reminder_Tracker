import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import '../constants.dart';
import '../models/medication_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AddMedicationPage extends StatefulWidget {
  final Medication? medication;
  const AddMedicationPage({super.key, this.medication});

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
  String? _localImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      final med = widget.medication!;
      _nameController.text = med.name;
      _dosageController.text = med.dosage;
      _startDateController.text = med.startDate;
      _endDateController.text = med.endDate ?? '';
      _instructionsController.text = med.instructions ?? '';
      _quantityController.text = med.totalQuantity.toString();
      _refillController.text = med.refillAlertAt.toString();
      _frequency = med.frequency;
      _takeWith = med.takeWith;
      _category = med.category;
      _doseTimes = List.from(med.doseTimes);
      _localImagePath = med.localImagePath;
    }
  }

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

  Future<void> _pickImage() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image picking is only supported on mobile devices.')),
      );
      return;
    }
    
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery, 
        maxWidth: 600,
      );

      if (pickedFile != null) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = path.basename(pickedFile.path);
        final String localPath = path.join(appDir.path, fileName);
        
        // Copy image to app's internal storage
        await File(pickedFile.path).copy(localPath);
        
        setState(() {
          _localImagePath = localPath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
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
        id: widget.medication?.id,
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
        lastTaken: widget.medication?.lastTaken,
        localImagePath: _localImagePath,
      );

      if (widget.medication == null) {
        await dbService.addMedication(medication);
      } else {
        await dbService.updateMedication(medication);
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.medication == null ? 'Medication added' : 'Medication updated')),
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
    bool isEditing = widget.medication != null;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
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
                    child: const Icon(Icons.arrow_back, color: AppColors.blue),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'Edit Medication' : 'Add Medication', 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.blue),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionHeader('📸', 'Medication Photo'),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: _localImagePath != null && !kIsWeb && File(_localImagePath!).existsSync()
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16), 
                                child: Image.file(File(_localImagePath!), fit: BoxFit.cover),
                              )
                            : const Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildSectionHeader('ℹ️', 'Basic Information'),
                  _buildLabel('Medication Name'),
                  _buildInput(controller: _nameController, hint: 'e.g. Aspirin'),
                  
                  _buildLabel('Dosage'),
                  _buildInput(controller: _dosageController, hint: 'e.g. 10mg'),

                  _buildLabel('Form / Category'),
                  _buildCategoryDropdown(),

                  const SizedBox(height: 12),
                  _buildSectionHeader('⏰', 'Schedule & Frequency'),
                  
                  _buildLabel('How often?'),
                  _buildGrid(['Daily', 'Weekly', 'Monthly', 'As Needed'], _frequency, (val) => setState(() => _frequency = val)),

                  _buildLabel('Dose Times'),
                  ..._doseTimes.asMap().entries.map((entry) => _buildDoseTimeRow(entry.key, entry.value)),
                  
                  _buildAddAnotherTime(),

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

                  const SizedBox(height: 12),
                  _buildSectionHeader('📋', 'Instructions & Inventory'),
                  
                  _buildLabel('Take With'),
                  _buildGrid(['Before Meal', 'With Meal', 'After Meal', 'Empty Stomach'], _takeWith, (val) => setState(() => _takeWith = val)),

                  _buildLabel('Special Instructions'),
                  _buildInput(controller: _instructionsController, hint: 'e.g. Take with plenty of water', maxLines: 3),

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

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveMedication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : Text(isEditing ? 'Update Medication' : 'Save Medication', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _category,
          isExpanded: true,
          onChanged: (val) => setState(() => _category = val!),
          items: ['Pill', 'Capsule', 'Liquid', 'Injection', 'Other'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDoseTimeRow(int idx, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (picked != null && mounted) {
                  final now = DateTime.now();
                  final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
                  final formattedTime = DateFormat('hh:mm a').format(dt);
                  setState(() => _doseTimes[idx] = formattedTime);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Text(time, style: const TextStyle(fontSize: 15)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () { if (_doseTimes.length > 1) setState(() => _doseTimes.removeAt(idx)); },
          ),
        ],
      ),
    );
  }

  Widget _buildAddAnotherTime() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => setState(() => _doseTimes.add('08:00 AM')),
        child: const Text('+ Add another time', style: TextStyle(fontSize: 14, color: Color(0xFF006A60), fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSectionHeader(String icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.blue)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.secondaryText)),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String hint, TextInputType? keyboardType, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildGrid(List<String> items, String selected, Function(String) onSelect) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((i) {
        bool isSelected = i == selected;
        return ChoiceChip(
          label: Text(i),
          selected: isSelected,
          onSelected: (s) => onSelect(i),
          selectedColor: AppColors.blue,
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );
      }).toList(),
    );
  }
}
