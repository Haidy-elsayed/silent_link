import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/app_icons.dart';
import 'widgets/settings_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Column(
        children: [
          /// HEADER (APP BAR)
          Container(
            height: 100,
            width: double.infinity,

            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),

            child: SafeArea(
              child: Center(
                child: Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          /// EDIT PROFILE CARD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),

              child: SettingsTile(
                icon: AppIcons.profile,

                title: "Edit Profile",

                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          ),

          const SizedBox(height: 30),

          /// OTHER SETTINGS TITLE
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),

            child: Align(
              alignment: Alignment.centerLeft,

              child: Text(
                "Other Settings",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// SETTINGS CARD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
              ),

              child: Column(
                children: [
                  SettingsTile(
                    icon: AppIcons.notifications,

                    title: "Notifications",

                    trailing: Switch(
                      value: notificationsEnabled,

                      activeColor: AppColors.primary,

                      onChanged: (value) {
                        setState(() {
                          notificationsEnabled = value;
                        });
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  SettingsTile(icon: AppIcons.about, title: "About"),

                  const Divider(height: 1),

                  SettingsTile(
                    icon: AppIcons.password,

                    title: "Password and security",
                  ),

                  const Divider(height: 1),

                  SettingsTile(icon: AppIcons.logout, title: "Logout"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
