
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/user_provider.dart';
import '../../../models/emergency_model.dart';

class EmergencyNumbersCard extends StatelessWidget {
  const EmergencyNumbersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProv, child) {
        final numbers = EmergencyNumbers.countryData[userProv.country] ?? EmergencyNumbers.countryData["Egypt"]!;

        return Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
           boxShadow: [
  BoxShadow(
    color: Colors.black.withOpacity(0.1), 
    blurRadius: 15,
    offset: const Offset(0, 5), 
  ),
],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text(
                    "${numbers.countryName} Emergency", 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildEmergencyItem(context, "Police", numbers.police),
              const SizedBox(height: 10),
              _buildEmergencyItem(context, "Fire Department", numbers.fire),
              const SizedBox(height: 10),
              _buildEmergencyItem(context, "Ambulance", numbers.ambulance),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmergencyItem(BuildContext context, String title, String number) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            Text(
              number,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(width: 5),
            IconButton(
              icon: const Icon(Icons.copy_all_outlined, size: 20, color: Colors.grey),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: number)).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$title number copied!"), backgroundColor: AppColors.primary, duration: const Duration(seconds: 1)),
                  );
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}