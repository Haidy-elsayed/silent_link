import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/colors.dart';
import '../../core/storage/app_statement_manager.dart';
import '../auth/sign_in_page.dart';
import 'widgets/permission_card.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  // مؤقت للتطوير: اعتبر كل الصلاحيات granted
  bool _locationGranted = true;
  bool _bluetoothGranted = true;
  //******************************
  bool _internetGranted = false;
  //bool _bluetoothGranted = false;
  //bool _locationGranted = false;

  /// ===== Internet (UX فقط) =====
  void _grantInternet() {
    setState(() {
      _internetGranted = true;
    });
  }

  /// ===== Location Permission =====
  Future<void> _requestLocation() async {
    final status = await Permission.location.request();

    setState(() {
      _locationGranted = status.isGranted;
    });
  }

  /// ===== Bluetooth Permission (Android 12+) =====
  Future<void> _requestBluetooth() async {
    final bluetooth = await Permission.bluetooth.request();
    final scan = await Permission.bluetoothScan.request();
    final connect = await Permission.bluetoothConnect.request();

    setState(() {
      _bluetoothGranted =
          bluetooth.isGranted && scan.isGranted && connect.isGranted;
    });
  }

  /// ===== Continue Button =====
  Future<void> _continue() async {
    if (!_bluetoothGranted || !_locationGranted) {
      _showError();
      return;
    }

    await AppStateManager.setPermissionsGranted();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInPage()),
    );
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please allow all required permissions to continue',
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 50),

              const Text(
                "Grant Permissions",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Emergency features access",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),

              const SizedBox(height: 70),

              /// ===== Internet =====
              PermissionCard(
                icon: Icons.wifi,
                title: "Internet Access",
                subtitle: "Connect to online services",
                isGranted: _internetGranted,
                onAllow: _internetGranted ? null : _grantInternet,
              ),

              const SizedBox(height: 30),

              /// ===== Bluetooth =====
              PermissionCard(
                icon: Icons.bluetooth,
                title: "Bluetooth",
                subtitle: "Scans for nearby devices",
                isGranted: _bluetoothGranted,
                onAllow: _bluetoothGranted ? null : _requestBluetooth,
              ),

              const SizedBox(height: 30),

              /// ===== Location =====
              PermissionCard(
                icon: Icons.location_on,
                title: "Location Services",
                subtitle: "Finds nearby connections",
                isGranted: _locationGranted,
                onAllow: _locationGranted ? null : _requestLocation,
              ),

              const Spacer(flex: 2),

              /// ===== Continue Button =====
              SizedBox(
                width: 180,
                height: 50,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}