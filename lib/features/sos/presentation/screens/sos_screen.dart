import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/sos_request_model.dart';
import '../../services/bluetooth_service.dart';
import '../../services/local_db_service.dart';
import 'all_requests_screen.dart';
import 'create_sos_screen.dart';
import 'bluetooth_search_screen.dart';
import '../../services/network_service.dart';
import '../../controllers/sos_controller.dart';
import 'request_details_screen.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final LocalDbService _localDb = LocalDbService();
  final BluetoothService _bluetoothService = BluetoothService();

  List<SosRequestModel> _pendingRequests = [];

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();

    // لما يجي SOS عبر Bluetooth → اعرضه فوراً
    _bluetoothService.onSosReceived = (request) {
      if (mounted) _loadPendingRequests();
    };
  }

  Future<void> _loadPendingRequests() async {
    final requests = await _localDb.getPendingRequests();
    if (mounted) setState(() => _pendingRequests = requests);
  }

  Future<void> _handleForward(SosRequestModel request) async {
    final hasInternet = await NetworkService().isConnected();
    if (hasInternet) {
      await SosController().retryPendingRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SOS forwarded to server ✅')),
        );
      }
    } else {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BluetoothSearchScreen(requestId: request.sosId),
          ),
        ).then((_) => _loadPendingRequests());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            /// Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "SOS",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
            ),

            const SizedBox(height: 20),

            /// Pending Requests Section
            if (_pendingRequests.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Pending SOS Requests",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _PendingRequestCard(
                  request: _pendingRequests.first,
                  onAssist: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RequestDetailsScreen(request: _pendingRequests.first),
                    ),
                  ).then((_) => _loadPendingRequests()),
                  onForward: () => _handleForward(_pendingRequests.first),
                ),
              ),

              const SizedBox(height: 12),

              /// View all requests
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllRequestsScreen()),
                ).then((_) => _loadPendingRequests()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "View all requests",
                        style: TextStyle(fontSize: 14, color: AppColors.grey),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppColors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const Spacer(),

            /// 🔴 Send SOS Button
            Padding(
              padding: const EdgeInsets.only(bottom: 65, left: 39, right: 39),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sosShadow.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.sosRed,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateSosScreen(),
                          ),
                        ).then((_) => _loadPendingRequests()),
                        child: const Text(
                          "Send SOS",
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap in emergency",
                    style: TextStyle(fontSize: 13, color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
// Pending Request Card Widget
// ═══════════════════════════════════════
class _PendingRequestCard extends StatelessWidget {
  final SosRequestModel request;
  final VoidCallback onAssist;
  final VoidCallback onForward;

  const _PendingRequestCard({
    required this.request,
    required this.onAssist,
    required this.onForward,
  });

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sosRed.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Badge + Time ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.sosRed,
                  borderRadius: BorderRadius.circular(6),
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
              const SizedBox(width: 8),
              Text(
                _timeAgo(request.createdAt),
                style: TextStyle(fontSize: 12, color: AppColors.grey),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Icon + Name + Injury ──
          Row(
            children: [
              Icon(
                Icons.notifications_active_rounded,
                color: AppColors.sosRed,
                size: 28,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.name.isEmpty ? 'Unknown' : request.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    request.injuryType,
                    style: TextStyle(fontSize: 13, color: AppColors.grey),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Location ──
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: AppColors.grey, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  request.locationName.isEmpty
                      ? '${request.latitude.toStringAsFixed(3)}, ${request.longitude.toStringAsFixed(3)}'
                      : request.locationName,
                  style: TextStyle(fontSize: 13, color: AppColors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Buttons ──
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAssist,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sosRed,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Assist Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onForward,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Forward Request',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
