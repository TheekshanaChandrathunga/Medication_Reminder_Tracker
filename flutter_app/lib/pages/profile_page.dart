import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import '../widgets/bottom_nav.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                      const Icon(Icons.settings, color: AppColors.blue),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: userId == null
                      ? const Center(child: Text("Please login to see profile"))
                      : StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            
                            final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                            final name = userData['name'] ?? 'User';
                            final email = userData['email'] ?? 'No email';
                            final role = userData['role'] ?? 'Patient';

                            return ListView(
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
                                            decoration: BoxDecoration(
                                              color: AppColors.blue.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.blue),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 12,
                                            child: Container(
                                              width: 100,
                                              padding: const EdgeInsets.symmetric(vertical: 3),
                                              decoration: const BoxDecoration(
                                                color: Color.fromRGBO(2, 103, 154, 0.85),
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
                                      Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
                                      const SizedBox(height: 4),
                                      Text(email, style: const TextStyle(fontSize: 13, color: AppColors.subText)),
                                      const SizedBox(height: 4),
                                      Text('Role: $role', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.blue)),
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
                                        onTap: () async {
                                          await authService.signOut();
                                          Navigator.pushReplacementNamed(context, '/login');
                                        }
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
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
