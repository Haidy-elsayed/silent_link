import 'package:flutter/material.dart';
import 'package:silent_link/core/constants/app_colors.dart';


class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("About Silent Link", style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.wifi_tethering, size: 80, color: AppColors.primary),
            const SizedBox(height: 20),
            const Text(
              "Silent Link",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            const Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            _buildInfoCard(
              "Our Mission",
              "Providing a reliable emergency communication network using Bluetooth Mesh technology when cellular networks are unavailable.",
            ),
            const SizedBox(height: 15),
            _buildInfoCard(
              "Key Features",
              "• Offline Emergency SOS\n• Real-time Location Sharing\n• Bluetooth Mesh Networking\n• AI-Powered First Aid Guidance",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5)),
        ],
      ),
    );
  }
}