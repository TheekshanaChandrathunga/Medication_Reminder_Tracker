import 'package:flutter/material.dart';
import '../constants.dart';

class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({Key? key}) : super(key: key);

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  String _frequency = 'Daily';
  String _takeWith = 'Before Meal';

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
                  _buildInput(hint: 'e.g. Amoxicillin'),
                  
                  _buildLabel('Dosage'),
                  _buildInput(hint: 'e.g. 500mg, 10ml'),

                  _buildLabel('Form / Category'),
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: const Color(0xFFCBD5E0)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Select form', style: TextStyle(color: Color(0xFF718096), fontSize: 13)),
                        Text('▼', style: TextStyle(color: Color(0xFF718096), fontSize: 10)),
                      ],
                    ),
                  ),

                  // Section 2
                  const SizedBox(height: 12),
                  _buildSectionHeader('⏰', 'Schedule & Frequency'),
                  
                  _buildLabel('How often?'),
                  _buildGrid(['Daily', 'Weekly', 'Monthly', 'As Needed'], _frequency, (val) => setState(() => _frequency = val), false),

                  _buildLabel('Dose Times'),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border.all(color: const Color(0xFFCBD5E0)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('08:00 AM', style: TextStyle(fontSize: 13, color: AppColors.primaryText)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFED7D7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('🗑️', style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: GestureDetector(
                      onTap: () {},
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
                            _buildInput(hint: 'mm/dd/yyyy'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('End Date (Optional)'),
                            _buildInput(hint: 'mm/dd/yyyy'),
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
                    child: const TextField(
                      maxLines: 3,
                      style: TextStyle(fontSize: 13, color: AppColors.primaryText),
                      decoration: InputDecoration(
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
                            _buildInput(hint: 'e.g. 30', keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Remind to refill at'),
                            _buildInput(hint: 'e.g. 5', keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Submit Button
                  Container(
                    margin: const EdgeInsets.only(top: 24, bottom: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: const Text('Save Medication', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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

  Widget _buildInput({required String hint, TextInputType? keyboardType}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFCBD5E0)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
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
