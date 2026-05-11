import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/sos_request_model.dart';
import '../../services/local_db_service.dart';
import 'request_details_screen.dart';
import 'bluetooth_search_screen.dart';
import '../../services/network_service.dart';
import '../../controllers/sos_controller.dart';

class AllRequestsScreen extends StatefulWidget {
  const AllRequestsScreen({super.key});

  @override
  State<AllRequestsScreen> createState() => _AllRequestsScreenState();
}

class _AllRequestsScreenState extends State<AllRequestsScreen>
    with SingleTickerProviderStateMixin {
  final LocalDbService _localDb = LocalDbService();
  late TabController _tabController;

  List<SosRequestModel> _allRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    final requests = await _localDb.getAllRequests();
    if (mounted) {
      setState(() {
        _allRequests = requests;
        _isLoading = false;
      });
    }
  }

  List<SosRequestModel> get _pendingRequests => _allRequests
      .where((r) =>
          r.state == 'pending' ||
          r.state == 'pending_connection' ||
          r.state == 'received_bluetooth' ||
          r.state == 'forwarded_bluetooth')
      .toList();

  List<SosRequestModel> get _historyRequests => _allRequests
      .where((r) => r.state == 'delivered' || r.state == 'resolved')
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(context),

            // ── Tabs ──
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.grey,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2.5,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'All Requests'),
                  Tab(text: 'SOS History'),
                ],
              ),
            ),

            // ── Content ──
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAllRequestsTab(),
                        _buildHistoryTab(),
                      ],
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

  // ─── All Requests Tab ───
  Widget _buildAllRequestsTab() {
    if (_pendingRequests.isEmpty) {
      return _buildEmptyState('No active requests');
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) {
          return _RequestCard(
            request: _pendingRequests[index],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RequestDetailsScreen(
                  request: _pendingRequests[index],
                ),
              ),
            ).then((_) => _loadRequests()),
          );
        },
      ),
    );
  }

  // ─── History Tab ───
  Widget _buildHistoryTab() {
    if (_historyRequests.isEmpty) {
      // لو مفيش delivered → اعرض كل الطلبات كـ history
      final history = _allRequests;
      if (history.isEmpty) return _buildEmptyState('No history yet');

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          return _HistoryCard(request: history[index]);
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _historyRequests.length,
      itemBuilder: (context, index) {
        return _HistoryCard(request: _historyRequests[index]);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: AppColors.grey.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 15, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
// Request Card (All Requests tab)
// ═══════════════════════════════════════
Future<void> _handleForward(BuildContext context, SosRequestModel request) async {
  final hasInternet = await NetworkService().isConnected();
  if (hasInternet) {
    await SosController().retryPendingRequests();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('SOS forwarded to server ✅')),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BluetoothSearchScreen(requestId: request.sosId),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final SosRequestModel request;
  final VoidCallback onTap;

  const _RequestCard({required this.request, required this.onTap});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sosRed.withOpacity(0.3)),
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
          // Badge + Time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sosRed,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'URGENT',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
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

          // Name + Injury
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
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    request.injuryType,
                    style: TextStyle(fontSize: 13, color: AppColors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Location
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

          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sosRed,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Assist Now',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleForward(context, request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Forward Request',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
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

// ═══════════════════════════════════════
// History Card (SOS History tab)
// ═══════════════════════════════════════
class _HistoryCard extends StatelessWidget {
  final SosRequestModel request;

  const _HistoryCard({required this.request});

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}\n$hour:$min$ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SOS Id: ${request.sosId ?? 'N/A'}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Injury: ${request.injuryType}',
                  style: TextStyle(fontSize: 13, color: AppColors.grey),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(request.createdAt),
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12, color: AppColors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }
}