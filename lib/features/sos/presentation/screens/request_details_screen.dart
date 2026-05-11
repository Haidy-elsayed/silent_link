import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/sos_request_model.dart';
import '../../services/network_service.dart';
import '../../controllers/sos_controller.dart';
import 'bluetooth_search_screen.dart';

class RequestDetailsScreen extends StatelessWidget {
  final SosRequestModel request;

  const RequestDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title ──
                    const Text(
                      'Help requests',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Profile Card ──
                    _buildProfileCard(),

                    const SizedBox(height: 16),

                    // ── Info Fields ──
                    _buildInfoField(
                      icon: Icons.person_rounded,
                      value: request.name.isEmpty ? 'Unknown' : request.name,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoField(
                      icon: Icons.phone_rounded,
                      value: request.phone.isEmpty ? 'N/A' : request.phone,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoField(
                      icon: Icons.location_on_rounded,
                      value: request.locationName.isEmpty
                          ? '${request.latitude.toStringAsFixed(4)}, ${request.longitude.toStringAsFixed(4)}'
                          : request.locationName,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoField(
                      icon: null,
                      value: request.injuryType.isEmpty
                          ? 'Unknown injury'
                          : request.injuryType,
                      isStatus: true,
                    ),

                    const SizedBox(height: 24),

                    // ── Extra Details ──
                    _buildDetailRow('Emergency Type', request.emergencyType),
                    _buildDetailRow('Severity', request.severity),
                    _buildDetailRow('Delivery', request.deliveryMethod),
                    _buildDetailRow(
                      'Time',
                      _formatDate(request.createdAt),
                    ),
                    if (request.sosId != null)
                      _buildDetailRow('SOS ID', request.sosId!),

                    const SizedBox(height: 32),

                    // ── Buttons ──
                    _buildAssistButton(context),
                    const SizedBox(height: 12),
                    _buildForwardButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ───
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'SOS',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ─── Profile Card ───
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: Icon(Icons.person_rounded,
                size: 32, color: Colors.grey.shade400),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.name.isEmpty ? 'Unknown' : request.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.sosRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  request.injuryType.isEmpty ? 'Injured' : request.injuryType,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.sosRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Info Field ───
  Widget _buildInfoField({
    required IconData? icon,
    required String value,
    bool isStatus = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey.shade500),
            const SizedBox(width: 12),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isStatus ? FontWeight.w600 : FontWeight.w500,
              color: isStatus ? AppColors.black : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Detail Row ───
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            '$label:  ',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Assist Button ───
  Widget _buildAssistButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sosRed,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Assist Now',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ─── Forward Button ───
  Widget _buildForwardButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () async {
          final hasInternet = await NetworkService().isConnected();
          if (hasInternet) {
            await SosController().retryPendingRequests();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('SOS forwarded to server ✅')),
              );
            }
          } else {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BluetoothSearchScreen(requestId: request.sosId),
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Forward Request',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $hour:$min $ampm';
  }
}