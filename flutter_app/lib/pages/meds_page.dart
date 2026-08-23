import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/bottom_nav.dart';

class MedsPage extends StatefulWidget {
  const MedsPage({Key? key}) : super(key: key);

  @override
  State<MedsPage> createState() => _MedsPageState();
}

class _MedsPageState extends State<MedsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  
  // mock data
  final List<Map<String, dynamic>> _meds = [
    { 'icon': '💊', 'name': 'Atorvastatin', 'dosage': '20 mg', 'tag': '⏰ Once daily at night', 'active': true, 'bg': AppColors.iconBg },
    { 'icon': '📋', 'name': 'Metformin', 'dosage': '500 mg', 'tag': '⏰ Twice daily w/ meals', 'active': true, 'bg': AppColors.iconBg },
    { 'icon': '💉', 'name': 'Amoxicillin', 'dosage': '250 mg', 'tag': '📅 Completed Oct 12', 'active': false, 'bg': const Color(0xFFF0F0F0) },
    { 'icon': '🫙', 'name': 'Losartan', 'dosage': '50 mg', 'tag': '⏰ Once daily morning', 'active': true, 'bg': AppColors.iconBg },
  ];

  @override
  Widget build(BuildContext context) {
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
                          color: AppColors.dark,
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
                  child: ListView(
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
                                    const Text('🔍', style: TextStyle(fontSize: 14, color: Color(0xFFA0AEC0))),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchCtrl,
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
                            const SizedBox(width: 10),
                            Container(
                              width: 42, height: 42,
                              decoration: const BoxDecoration(color: Color(0xFFEBF3FF), shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: const Text('⚙️', style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                      
                      // Cards
                      ..._meds.map((m) => _buildCard(m)).toList(),
                    ],
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
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text('+', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w300)),
                  ),
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

  Widget _buildCard(Map<String, dynamic> data) {
    bool active = data['active'];
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
            decoration: BoxDecoration(color: data['bg'], borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 14),
            child: Text(data['icon'], style: const TextStyle(fontSize: 20)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFFE6FFFA) : const Color(0xFFEDF2F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        active ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: active ? const Color(0xFF38A169) : const Color(0xFFA0AEC0),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 8),
                  child: Text(data['dosage'], style: const TextStyle(fontSize: 13, color: AppColors.subText)),
                ),
                Container(
                  padding: active 
                    ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
                    : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFFF0F4FC) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data['tag'],
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500,
                      color: active ? const Color(0xFF4A5568) : const Color(0xFFA0AEC0),
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
