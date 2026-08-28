import 'package:flutter/material.dart';
import '../constants.dart';

class BottomNav extends StatelessWidget {
  final String activeTab;
  
  const BottomNav({Key? key, required this.activeTab}) : super(key: key);

  void navigate(BuildContext context, String tab) {
    if (tab == activeTab) return;
    
    switch (tab) {
      case 'Home':
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 'Meds':
        Navigator.pushReplacementNamed(context, '/meds');
        break;
      case 'History':
        Navigator.pushReplacementNamed(context, '/history');
        break;
      case 'Reports':
        // Not implemented yet
        break;
      case 'Profile':
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildNavItem(context, 'Home', '🏠', 'Home'),
          _buildNavItem(context, 'Meds', '💊', 'Meds'),
          _buildNavItem(context, 'History', '📅', 'History'),
          _buildNavItem(context, 'Reports', '📈', 'Reports'),
          _buildNavItem(context, 'Profile', '👤', 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String id, String icon, String label) {
    bool isActive = activeTab == id;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => navigate(context, id),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: 18,
                color: isActive ? AppColors.blue : const Color(0xFFA0AEC0),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.blue : const Color(0xFFA0AEC0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
