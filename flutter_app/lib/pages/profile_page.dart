import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import '../widgets/bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showEditProfile(BuildContext context, String userId, String currentName, String currentRole) {
    final nameController = TextEditingController(text: currentName);
    String selectedRole = currentRole;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                onChanged: (val) => setDialogState(() => selectedRole = val!),
                items: ['Patient', 'Caregiver'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final db = Provider.of<DatabaseService>(context, listen: false);
                await db.updateProfile(userId, nameController.text.trim(), selectedRole);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
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
                // Header
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 10),
                  color: AppColors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('My Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.blue)),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        onPressed: () async {
                          await authService.signOut();
                          if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: userId == null
                      ? const Center(child: Text("Please login to see profile"))
                      : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: dbService.getUserProfile(userId),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                            
                            final data = snapshot.data?.data() ?? {};
                            final name = data['name'] ?? 'User';
                            final email = data['email'] ?? '';
                            final role = data['role'] ?? 'Patient';

                            return ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                // Avatar Section
                                Center(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                                        child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', 
                                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.blue)),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                      Text(email, style: const TextStyle(color: AppColors.subText)),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(color: AppColors.iconBg, borderRadius: BorderRadius.circular(20)),
                                        child: Text(role, style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),
                                
                                const Text('Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                                const SizedBox(height: 12),
                                
                                _buildMenuTile(
                                  icon: Icons.person_outline,
                                  title: 'Edit Profile Information',
                                  onTap: () => _showEditProfile(context, userId, name, role),
                                ),
                                _buildMenuTile(
                                  icon: Icons.history,
                                  title: 'Adherence History Log',
                                  onTap: () => Navigator.pushNamed(context, '/history'),
                                ),
                                _buildMenuTile(
                                  icon: Icons.bar_chart,
                                  title: 'View Health Reports',
                                  onTap: () => Navigator.pushNamed(context, '/reports'),
                                ),
                                _buildMenuTile(
                                  icon: Icons.help_outline,
                                  title: 'Help & Support Center',
                                  onTap: () {},
                                ),
                                
                                const SizedBox(height: 100),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
            const Positioned(bottom: 0, left: 0, right: 0, child: BottomNav(activeTab: 'Profile')),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}
