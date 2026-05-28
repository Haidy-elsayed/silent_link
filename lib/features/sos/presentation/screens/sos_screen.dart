import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/sos_request_model.dart';
import '../../services/bluetooth_service.dart';
import '../../services/local_db_service.dart';
import '../../services/notification_service.dart';
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

class _SosScreenState extends State<SosScreen> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final LocalDbService _localDb = LocalDbService();
  final BluetoothService _bluetoothService = BluetoothService();

  // FIX: static عشان تفضل في الـ memory حتى لو الـ SosScreen اتعمل dispose
  static List<SosRequestModel> _cachedRequests = [];
  List<SosRequestModel> get _pendingRequests => _cachedRequests;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPendingRequests();
    // FIX: بيعمل refresh كل ثانيتين عشان يلاقي الـ requests الجديدة
    _startPeriodicRefresh();

    // لما يجي SOS عبر Bluetooth → اعرضه فوراً
    _bluetoothService.onSosReceived = (request) {
      if (mounted) _loadPendingRequests();
    };

    // FIX: لما اليوزر يدوس على الـ notification
    // بيجيلنا الـ createdAt → نجيب الـ request من الـ DB ونفتح الـ details
    onNotificationOpenRequest = (createdAt) async {
      await _loadPendingRequests();
      if (!mounted) return;

      SosRequestModel? request;

      if (createdAt.isNotEmpty) {
        // جيب الـ request بالـ createdAt
        request = await _localDb.getRequestByCreatedAt(createdAt);
      }

      // fallback: أحدث request
      request ??= _pendingRequests.isNotEmpty ? _pendingRequests.first : null;

      if (request != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RequestDetailsScreen(request: request!),
          ),
        ).then((_) => _loadPendingRequests());
      }
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    onNotificationOpenRequest = null;
    _refreshTimer?.cancel();
    super.dispose();
  }

  // FIX: لما الأبلكيشن يرجع من الـ background → refresh
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPendingRequests();
    }
  }

  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) _loadPendingRequests();
    });
  }

  Future<void> _loadPendingRequests() async {
    final requests = await _localDb.getPendingRequests();
    // FIX: بنحدث الـ static cache دايماً
    _cachedRequests = requests;
    if (mounted) setState(() {});
  }

  Future<void> _handleForward(SosRequestModel request) async {
    final hasInternet = await NetworkService().isConnected();
    if (hasInternet) {
      await SosController().retryPendingRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SOS forwarded to server ✅')),
        );
        _loadPendingRequests();
      }
    } else {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BluetoothSearchScreen(
              requestId: request.sosId,
              request: request,
            ),
          ),
        ).then((_) => _loadPendingRequests());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "SOS",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),

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
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RequestDetailsScreen(
                          request: _pendingRequests.first),
                    ),
                  ).then((_) => _loadPendingRequests()),
                ),
              ),
              const SizedBox(height: 12),
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
                      Text("View all requests",
                          style:
                              TextStyle(fontSize: 14, color: AppColors.grey)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward,
                          size: 16, color: AppColors.grey),
                    ],
                  ),
                ),
              ),
            ],

            const Spacer(),

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
                              builder: (_) => const CreateSosScreen()),
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
                  Text("Tap in emergency",
                      style: TextStyle(fontSize: 13, color: AppColors.grey)),
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
// Pending Request Card
// ═══════════════════════════════════════
class _PendingRequestCard extends StatelessWidget {
  final SosRequestModel request;
  final VoidCallback onTap;

  const _PendingRequestCard({
    required this.request,
    required this.onTap,
  });

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.sosRed.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.sosRed,
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text('URGENT',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Text(_timeAgo(request.createdAt),
                    style: TextStyle(fontSize: 12, color: AppColors.grey)),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.grey),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.notifications_active_rounded,
                    color: AppColors.sosRed, size: 28),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name.isEmpty ? 'Unknown' : request.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(request.injuryType,
                        style:
                            TextStyle(fontSize: 13, color: AppColors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on_rounded,
                    color: AppColors.grey, size: 16),
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

          ],
        ),
      ),
    );
  }
}