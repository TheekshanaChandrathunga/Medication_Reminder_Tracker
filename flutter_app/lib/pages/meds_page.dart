import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../widgets/bottom_nav.dart';
import '../models/medication_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class MedsPage extends StatefulWidget {
  const MedsPage({Key? key}) : super(key: key);

  @override
  State<MedsPage> createState() => _MedsPageState();
}

class _MedsPageState extends State<MedsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

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
                // Top App Header
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 10),
                  color: AppColors.white,
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE2E8F0),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 8),
                        child: const Text('💊', style: TextStyle(fontSize: 16)),
                      ),
                      const Text(
                        'MediTrack',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.blue),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: userId == null
                  ? const Center(child: Text("Please login to see your medications"))
                  : StreamBuilder<List<Medication>>(
                    stream: dbService.getMedications(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final medications = (snapshot.data ?? []).where((med) {
                        return med.name.toLowerCase().contains(_searchQuery.toLowerCase());
                      }).toList();

                      return ListView(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 100),
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text('Medications', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
                          ),
                          
                          // Search Row
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 42,
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEBF3FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.search, size: 18, color: Color(0xFFA0AEC0)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            controller: _searchCtrl,
                                            onChanged: (value) {
                                              setState(() {
                                                _searchQuery = value;
                                              });
                                            },
                                            style: const TextStyle(fontSize: 14, color: AppColors.primaryText),
                                            decoration: const InputDecoration(
                                              hintText: 'Search medications...',
                                              hintStyle: TextStyle(color: Color(0xFFA0AEC0)),
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          if (medications.isEmpty)
                            const Center(child: Text("No medications found."))
                          else
                            ...medications.map((m) => _buildCard(m)).toList(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            
            // FAB
            Positioned(
              bottom: 75,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/addMed');
                },
                child: Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), offset: const Offset(0, 3), blurRadius: 5),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ),
            
            // Bottom Nav
            const Positioned(
              bottom: 0, left: 0, right: 0,
              child: BottomNav(activeTab: 'Meds'),
            ),
          ],
        ),
      ),
    );
  }

  String _getIconForCategory(String category) {
    switch (category) {
      case 'Pill': return '💊';
      case 'Capsule': return '💊';
      case 'Liquid': return '🧪';
      case 'Injection': return '💉';
      default: return '💊';
    }
  }

  Widget _buildCard(Medication med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), offset: const Offset(0, 2), blurRadius: 6)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: AppColors.iconBg, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 14),
            child: Text(_getIconForCategory(med.category), style: const TextStyle(fontSize: 20)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(med.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6FFFA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: Color(0xFF38A169),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 8),
                  child: Text(med.dosage, style: const TextStyle(fontSize: 13, color: AppColors.subText)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${med.frequency} • ${med.doseTimes.join(", ")}',
                    style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500,
                      color: Color(0xFF4A5568),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
