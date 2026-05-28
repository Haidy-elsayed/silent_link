import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/sos_request_model.dart';
import '../../services/network_service.dart';
import '../../services/notification_service.dart';
import '../../services/local_db_service.dart';
import '../../controllers/sos_controller.dart';
import 'sos_success_screen.dart';
import 'bluetooth_search_screen.dart';

class RequestDetailsScreen extends StatelessWidget {
  final SosRequestModel request;
  const RequestDetailsScreen({super.key, required this.request});

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
        ? 12
        : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $hour:$min $ampm';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  Future<void> _openMaps(BuildContext context) async {
    final lat = request.latitude;
    final lng = request.longitude;
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri);
    } else if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open maps')));
    }
  }

  Future<void> _callPhone(BuildContext context) async {
    if (request.phone.isEmpty) return;
    final uri = Uri.parse('tel:${request.phone}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _copyPhone(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: request.phone));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number copied ✅'),
          duration: Duration(milliseconds: 1200),
        ),
      );
    }
  }

  // ─── Assist Now ───
  Future<void> _handleAssist(BuildContext context) async {
    // بعت notification (للـ backend لما يخلص)
    await NotificationService().sendAssistNotification(
      helperName: 'Someone nearby',
      requestId: request.sosId ?? request.createdAt.toIso8601String(),
    );

    // FIX: غير الـ state لـ assisted عشان يختفي من الـ SosScreen
    await LocalDbService().updateStateBySosIdOrCreatedAt(
      sosId: request.sosId,
      createdAt: request.createdAt.toIso8601String(),
      newState: 'assisted',
    );

    if (context.mounted) {
      // ارجع للـ SosScreen وافتح Maps
      Navigator.pop(context);
      await _openMaps(context);
    }
  }

  // ─── Forward Request ───
  Future<void> _handleForward(BuildContext context) async {
    final hasInternet = await NetworkService().isConnected();

    if (hasInternet) {
      // بعت للـ backend
      await SosController().retryPendingRequests();

      // FIX: غير الـ state لـ delivered عشان يختفي
      await LocalDbService().updateStateBySosIdOrCreatedAt(
        sosId: request.sosId,
        createdAt: request.createdAt.toIso8601String(),
        newState: 'delivered',
      );

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SosSuccessScreen(
              requestId: request.sosId ?? 'Forwarded',
              status: 'delivered',
              request: request,
            ),
          ),
        );
      }
    } else {
      // مفيش نت → روح للـ BluetoothSearchScreen
      if (context.mounted) {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => BluetoothSearchScreen(
              requestId: request.sosId,
              request: request,
            ),
          ),
        );

        // FIX: لو اتبعت عبر Bluetooth → غير الـ state وروح SosSuccessScreen
        if (result == true && context.mounted) {
          await LocalDbService().updateStateBySosIdOrCreatedAt(
            sosId: request.sosId,
            createdAt: request.createdAt.toIso8601String(),
            newState: 'forwarded_bluetooth',
          );
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SosSuccessScreen(
                  requestId:
                      request.sosId ?? request.createdAt.toIso8601String(),
                  status: 'delivered',
                  request: request,
                ),
              ),
            );
          }
        }
        // لو مش اتبعت (result = null أو false) → يفضل في الـ RequestDetailsScreen
        // والـ request يفضل ظاهر في الـ SosScreen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Help Request',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _timeAgo(request.createdAt),
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                    const SizedBox(height: 16),
                    _buildProfileCard(),
                    const SizedBox(height: 12),
                    _buildPhoneField(context),
                    const SizedBox(height: 10),
                    _buildLocationField(context),
                    const SizedBox(height: 10),
                    _buildInfoField(
                      icon: Icons.medical_services_rounded,
                      label: 'Injury',
                      value: request.injuryType.isEmpty
                          ? 'Unknown'
                          : request.injuryType,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoField(
                      icon: Icons.warning_amber_rounded,
                      label: 'Emergency',
                      value: request.emergencyType.isEmpty
                          ? 'Unknown'
                          : request.emergencyType,
                    ),
                    const SizedBox(height: 10),
                    _buildSeverityField(),
                    const SizedBox(height: 16),
                    _buildDetailsCard(),
                    const SizedBox(height: 24),
                    _buildAssistButton(context),
                    const SizedBox(height: 12),
                    _buildForwardButton(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: AppColors.primary,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'SOS Details',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'URGENT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sosRed.withOpacity(0.1),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 30,
              color: AppColors.sosRed,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.name.isEmpty ? 'Unknown' : request.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sosRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        request.injuryType.isEmpty
                            ? 'Injured'
                            : request.injuryType,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.sosRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(request.createdAt),
                      style: TextStyle(fontSize: 11, color: AppColors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    final phone = request.phone.isEmpty ? 'N/A' : request.phone;
    final hasPhone = request.phone.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.phone_rounded, size: 20, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              phone,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          if (hasPhone) ...[
            GestureDetector(
              onTap: () => _copyPhone(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _callPhone(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.call_rounded,
                  size: 16,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationField(BuildContext context) {
    final locationText = request.locationName.isEmpty
        ? '${request.latitude.toStringAsFixed(5)}, ${request.longitude.toStringAsFixed(5)}'
        : request.locationName;
    return GestureDetector(
      onTap: () => _openMaps(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_rounded, size: 20, color: AppColors.sosRed),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locationText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to open in Maps',
                    style: TextStyle(fontSize: 11, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 13, color: AppColors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityField() {
    Color severityColor;
    switch (request.severity.toLowerCase()) {
      case 'critical':
        severityColor = Colors.red;
        break;
      case 'high':
        severityColor = Colors.orange;
        break;
      case 'medium':
        severityColor = Colors.amber;
        break;
      default:
        severityColor = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.priority_high_rounded, size: 20, color: severityColor),
          const SizedBox(width: 12),
          Text(
            'Severity: ',
            style: TextStyle(fontSize: 13, color: AppColors.grey),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              request.severity.isEmpty ? 'Unknown' : request.severity,
              style: TextStyle(
                fontSize: 12,
                color: severityColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REQUEST INFO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Delivery', request.deliveryMethod),
          _buildDetailRow('Time', _formatDate(request.createdAt)),
          if (request.sosId != null && request.sosId!.isNotEmpty)
            _buildDetailRow('SOS ID', request.sosId!),
          _buildDetailRow(
            'Coordinates',
            '${request.latitude.toStringAsFixed(5)}, ${request.longitude.toStringAsFixed(5)}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => _handleAssist(context),
        icon: const Icon(
          Icons.directions_run_rounded,
          color: Colors.white,
          size: 20,
        ),
        label: const Text(
          'Assist Now',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sosRed,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildForwardButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => _handleForward(context),
        icon: const Icon(Icons.forward_rounded, color: Colors.white, size: 20),
        label: const Text(
          'Forward Request',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
