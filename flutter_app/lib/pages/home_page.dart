import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/bottom_nav.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

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
                      // Welcome Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF4FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Good Morning, Sarah!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
                                    SizedBox(height: 2),
                                    Text('Today, October 24th, 2023', style: TextStyle(fontSize: 13, color: AppColors.subText)),
                                  ],
                                ),
                                const Text('👋', style: TextStyle(fontSize: 36)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Badges
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _buildBadge('⏰ Pending: 3', const Color(0xFFFEFCBF), const Color(0xFFB7791F)),
                                _buildBadge('✓ Taken: 1', const Color(0xFFC6F6D5), const Color(0xFF276749)),
                                _buildBadge('✕ Missed: 0', const Color(0xFFFED7D7), const Color(0xFFC53030)),
                              ],
                            ),
                            
                            // Progress Box
                            Container(
                              margin: const EdgeInsets.only(top: 14),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2EDFF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.blue, width: 3),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text('25%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.blue)),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text('Daily Progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryText)),
                                      Text('1 of 4 doses completed', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Section Title
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text("Today's Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
                      ),
                      
                      // Cards
                      _buildMedCard(
                        icon: '💊', iconBg: const Color(0xFFE6FFFA),
                        name: 'Aspirin 81mg', timeMeta: '☼ 7:00 AM • With Food',
                        isTaken: true, isActive: false,
                        takenMsg: '✓ Taken at 7:05 AM'
                      ),
                      _buildMedCard(
                        icon: '🏥', iconBg: AppColors.blue, iconColor: Colors.white,
                        name: 'Metformin 500mg', timeMeta: '⏰ 8:00 AM • After Breakfast',
                        isTaken: false, isActive: true, isNow: true
                      ),
                      _buildMedCard(
                        icon: '🧪', iconBg: AppColors.iconBg,
                        name: 'Lisinopril 10mg', timeMeta: '☼ 1:00 PM • With Water',
                        isTaken: false, isActive: false
                      ),
                      _buildMedCard(
                        icon: '🛏️', iconBg: AppColors.iconBg,
                        name: 'Atorvastatin 20mg', timeMeta: '🌙 9:00 PM • Before Bed',
                        isTaken: false, isActive: false
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // FAB
            Positioned(
              bottom: 70, // above nav
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/addMed');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006A60),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                ),
                child: const Text('+ Add New Medication', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
            
            // Bottom Nav
            const Positioned(
              bottom: 0, left: 0, right: 0,
              child: BottomNav(activeTab: 'Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: fg)),
    );
  }

  Widget _buildMedCard({
    required String icon, required Color iconBg, Color? iconColor,
    required String name, required String timeMeta,
    bool isTaken = false, bool isActive = false, bool isNow = false,
    String? takenMsg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? const Border(
                left: BorderSide(color: AppColors.blue, width: 4),
                top: BorderSide(color: AppColors.blue, width: 1.5),
                right: BorderSide(color: AppColors.blue, width: 1.5),
                bottom: BorderSide(color: AppColors.blue, width: 1.5),
              )
            : Border.all(color: AppColors.inputBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(icon, style: TextStyle(fontSize: 16, color: iconColor)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                            decoration: isTaken ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (isNow)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(4)),
                            child: const Text('NOW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(timeMeta, style: const TextStyle(fontSize: 12, color: AppColors.subText)),
                  ],
                ),
              ),
            ],
          ),
          if (isTaken && takenMsg != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FFF4),
                border: Border.all(color: const Color(0xFFC6F6D5)),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(takenMsg, style: const TextStyle(color: Color(0xFF276749), fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          if (!isTaken)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  _actionAction(isActive ? 'outline' : 'disabled', '⏰ Snooze'),
                  const SizedBox(width: 8),
                  _actionAction(isActive ? 'outline_danger' : 'disabled', '✕ Missed'),
                  const SizedBox(width: 8),
                  _actionAction(isActive ? 'filled' : 'disabled', '✓ Taken'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionAction(String type, String text) {
    Color bg = Colors.transparent;
    Color border = Colors.transparent;
    Color fg = Colors.transparent;
    
    if (type == 'outline') {
      bg = const Color(0xFFF7FAFC);
      border = AppColors.inputBorder;
      fg = AppColors.secondaryText;
    } else if (type == 'outline_danger') {
      bg = const Color(0xFFF7FAFC);
      border = AppColors.inputBorder;
      fg = const Color(0xFFE53E3E);
    } else if (type == 'filled') {
      bg = AppColors.blue;
      border = AppColors.blue;
      fg = Colors.white;
    } else if (type == 'disabled') {
      bg = const Color(0xFFEDF2F7);
      border = const Color(0xFFEDF2F7);
      fg = const Color(0xFFA0AEC0);
    }
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: TextStyle(fontSize: 12, fontWeight: type == 'filled' ? FontWeight.w700 : FontWeight.w600, color: fg)),
      ),
    );
  }
}
