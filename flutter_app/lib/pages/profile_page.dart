import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/bottom_nav.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                      const Text('⚙️', style: TextStyle(fontSize: 22, color: AppColors.blue)),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                    children: [
                      // Profile Header
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 12,
                                  child: Container(
                                    width: 100,
                                    padding: const EdgeInsets.symmetric(vertical: 3),
                                    decoration: const BoxDecoration(
                                      color: Color.fromRGBO(2, 103, 154, 0.85), // rgba(2, 103, 154, 0.85)
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(50),
                                        bottomRight: Radius.circular(50),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text('Edit', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                            const Text('Eleanor Rigby', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
                            const SizedBox(height: 4),
                            const Text('eleanor.r@example.com', style: TextStyle(fontSize: 13, color: AppColors.subText)),
                          ],
                        ),
                      ),

                      // Section 1: Account
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildMenuItem('✏️', 'Edit Profile'),
                            const Divider(height: 1, color: Color(0xFFEDF2F7)),
                            _buildMenuItem('👤', 'Account Information'),
                            const Divider(height: 1, color: Color(0xFFEDF2F7)),
                            _buildMenuItem('👥', 'Caregiver Access'),
                          ],
                        ),
                      ),

                      // Section 2: Support
                      const Padding(
                        padding: EdgeInsets.only(top: 24, bottom: 10),
                        child: Text('Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildMenuItem('❓', 'Help Center'),
                            const Divider(height: 1, color: Color(0xFFEDF2F7)),
                            _buildMenuItem(
                              '🚪', 
                              'Logout', 
                              textColor: const Color(0xFFE53E3E),
                              onTap: () => Navigator.pushReplacementNamed(context, '/login')
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Bottom Nav
            const Positioned(
              bottom: 0, left: 0, right: 0,
              child: BottomNav(activeTab: 'Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String icon, String label, {Color? textColor, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? const Color(0xFF2D3748),
                ),
              ),
            ),
            Text(
              '›',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor ?? const Color(0xFFCBD5E0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
