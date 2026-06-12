import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:silent_link/features/settings/change_password_screen.dart';
import 'package:silent_link/features/settings/widgets/about_screen.dart';
import 'package:silent_link/features/sos/presentation/screens/all_requests_screen.dart';
import 'package:silent_link/features/auth/widgets/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart'; 
import '../../../../providers/user_provider.dart'; 
import 'widgets/settings_tile.dart';
import 'edit_profile_screen.dart';
import '../auth/sign_in_screen.dart'; 

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool bluetoothMeshEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings(); 
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications') ?? true;
      bluetoothMeshEnabled = prefs.getBool('bluetoothMesh') ?? true;
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    setState(() {
      if (key == 'notifications') notificationsEnabled = value;
      if (key == 'bluetoothMesh') bluetoothMeshEnabled = value;
    });
    if (key == 'bluetoothMesh' && value == false) {
      debugPrint("Bluetooth Mesh Scanning Stopped...");
    }
  }

  List<BoxShadow> get _customShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 15,
          spreadRadius: 2,
          offset: const Offset(0, 5),
        ),
      ];

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to log out of Silent Link?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Provider.of<AuthProvider>(context, listen: false).logout();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); 

              if (!mounted) return;

              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const SignInScreen()),
                (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Settings'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25),
            _buildSettingsContainer(
              child: SettingsTile(
                icon: Icons.person_outline,
                title: "Edit Profile",
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Other Settings",
                  style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildSettingsContainer(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.notifications_none,
                    title: "Notifications",
                    trailing: Switch(
                      value: notificationsEnabled,
                      activeColor: AppColors.primary,
                      onChanged: (v) => _updateSetting('notifications', v),
                    ),
                  ),
                  const Divider(height: 1, indent: 55),
                  SettingsTile(
                    icon: Icons.bluetooth_audio,
                    title: "Bluetooth Mesh",
                    trailing: Switch(
                      value: bluetoothMeshEnabled,
                      activeColor: AppColors.primary,
                      onChanged: (v) => _updateSetting('bluetoothMesh', v),
                    ),
                  ),
                  const Divider(height: 1, indent: 55),
                  SettingsTile(
                    icon: Icons.lock_outline,
                    title: "Password and security",
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
                    },
                  ),
                  const Divider(height: 1, indent: 55),
                  
                
                  SettingsTile(
                    icon: Icons.history,
                    title: "SOS History",
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const AllRequestsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 55),
                  
                  SettingsTile(
                    icon: Icons.info_outline,
                    title: "About",
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
                    },
                  ),
                  const Divider(height: 1, indent: 55),
                  SettingsTile(
                    icon: Icons.logout,
                    title: "Logout",
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContainer({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _customShadow,
        ),
        child: child,
      ),
    );
  }
}