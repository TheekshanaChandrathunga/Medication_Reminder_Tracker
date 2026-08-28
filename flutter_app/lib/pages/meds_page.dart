import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added missing import
import '../constants.dart';
import '../widgets/bottom_nav.dart';
import '../models/medication_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'add_medication_page.dart';

class MedsPage extends StatefulWidget {
  const MedsPage({super.key});

  @override
  State<MedsPage> createState() => _MedsPageState();
}

class _MedsPageState extends State<MedsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  String _getIcon(String category) {
    switch (category) {
      case 'Pill': return '💊';
      case 'Capsule': return '💊';
      case 'Liquid': return '🧪';
      case 'Injection': return '💉';
      default: return '💊';
    }
  }

  void _showRefillDialog(Medication med, DatabaseService db) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Refill ${med.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter quantity to add', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              int? amount = int.tryParse(controller.text);
              if (amount != null && amount > 0) {
                await db.refillMedication(med.id!, amount);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add Stock'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final dbService = Provider.of<DatabaseService>(context);
    final userId = authService.currentUserId;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 10),
                  color: AppColors.white,
                  child: const Row(
                    children: [
                       Text('Inventory & Stock', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.blue)),
                    ],
                  ),
                ),
                
                Expanded(
                  child: userId == null
                  ? const Center(child: Text("Please login"))
                  : StreamBuilder<List<Medication>>(
                    stream: dbService.getMedications(userId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      
                      final medications = (snapshot.data ?? []).where((med) {
                        return med.name.toLowerCase().contains(_searchQuery.toLowerCase());
                      }).toList();

                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text('Medication List', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 16),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(color: const Color(0xFFEBF3FF), borderRadius: BorderRadius.circular(20)),
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: (val) => setState(() => _searchQuery = val),
                              decoration: const InputDecoration(icon: Icon(Icons.search), hintText: 'Search stock...', border: InputBorder.none),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          if (medications.isEmpty)
                            const Center(child: Text("No medications in inventory."))
                          else
                            ...medications.map((m) => _buildCard(context, m, dbService)),
                          
                          const SizedBox(height: 100),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 75, right: 20,
              child: FloatingActionButton(
                onPressed: () => Navigator.pushNamed(context, '/addMed'),
                backgroundColor: AppColors.blue,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
            const Positioned(bottom: 0, left: 0, right: 0, child: BottomNav(activeTab: 'Meds')),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Medication med, DatabaseService db) {
    bool isLow = med.totalQuantity <= med.refillAlertAt;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLow ? Colors.red.shade100 : Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), offset: const Offset(0, 2), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: isLow ? const Color(0xFFFFF5F5) : AppColors.iconBg, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Text(_getIcon(med.category), style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${med.totalQuantity} units remaining', style: TextStyle(color: isLow ? Colors.red : AppColors.subText, fontSize: 13, fontWeight: isLow ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ),
          PopupMenuButton(
            onSelected: (val) {
              if (val == 'edit') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddMedicationPage(medication: med)));
              } else if (val == 'delete') {
                db.deleteMedication(med.id!);
              } else if (val == 'refill') {
                _showRefillDialog(med, db);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'refill', child: Row(children: [Icon(Icons.add_box_outlined, size: 18), SizedBox(width: 8), Text('Refill Stock')])),
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Edit Details')])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
            ],
          )
        ],
      ),
    );
  }
}
