import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/sos_request_model.dart';
import '../../services/bluetooth_service.dart';
import '../../services/local_db_service.dart';
import '../../models/sos_request_model.dart';
import 'bluetooth_result_screen.dart';
import 'bluetooth_failed_screen.dart';

class BluetoothSearchScreen extends StatefulWidget {
  final String? requestId;
  final SosRequestModel? request;

  const BluetoothSearchScreen({
    super.key,
    this.requestId,
    this.request,
  });

  @override
  State<BluetoothSearchScreen> createState() => _BluetoothSearchScreenState();
}

class _BluetoothSearchScreenState extends State<BluetoothSearchScreen>
    with SingleTickerProviderStateMixin {
  final BluetoothService _bluetoothService = BluetoothService();

  Map<String, String> _devices = {};
  bool _isSending = false;
  SosRequestModel? _request;
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startScan();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    // جيب الـ request من الـ DB
    if (widget.requestId != null) {
      _request = await LocalDbService().getRequestBySosId(widget.requestId!);
      // لو مش لاقيه بالـ sosId جرب بالـ timestamp
      _request ??= await LocalDbService().getLatestPendingRequest();
    }

    _bluetoothService.onDevicesChanged = (devices) {
      if (mounted) {
        setState(() => _devices = devices);
        // لما يلاقي جهاز → ابعت تلقائياً
        if (devices.isNotEmpty && !_isSending && _request != null) {
          _sendSos();
        }
      }
    };

    await _bluetoothService.stop();
    await _bluetoothService.start('SilentLink User');
  }

  Future<void> _sendSos() async {
    if (_request == null || _isSending) return;
    setState(() => _isSending = true);

    final result = await _bluetoothService.sendSos(_request!);
    await _bluetoothService.stop();

    if (!mounted) return;

    if (result == BluetoothSendResult.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BluetoothResultScreen(
            requestId: widget.requestId,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BluetoothFailedScreen(
            requestId: widget.requestId,
          ),
        ),
      );
    }
  }

  Future<void> _cancel() async {
    await _bluetoothService.stop();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Bar
                    _buildProgressBar(),

                    const SizedBox(height: 32),

                    // Radar
                    Center(child: _buildRadar()),

                    const SizedBox(height: 28),

                    // Search Text
                    Center(child: _buildSearchText()),

                    const SizedBox(height: 24),

                    // Nearby Devices
                    if (_devices.isNotEmpty) ...[
                      Text(
                        "NEARBY DEVICES (${_devices.length})",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey.withOpacity(0.7),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._devices.entries
                          .map((e) => _buildDeviceItem(e.key, e.value)),
                    ],

                    const SizedBox(height: 28),

                    // Send Button
                    if (_devices.isNotEmpty && widget.request != null)
                      _buildSendButton(),

                    const SizedBox(height: 12),

                    // Cancel Button
                    _buildCancelButton(),
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
  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: _cancel,
            child: Container(
              width: 32,
              height: 32,
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
            "Bluetooth Mesh",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Progress Bar ───
  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Scanning nearby devices",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey.withOpacity(0.75),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "${_devices.length} found",
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            backgroundColor: Colors.grey.shade200,
            color: AppColors.primary,
            minHeight: 5,
          ),
        ),
      ],
    );
  }

  // ─── Radar ───
  Widget _buildRadar() {
    return SizedBox(
      width: 190,
      height: 190,
      child: AnimatedBuilder(
        animation: _radarController,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer rings
              for (int i = 0; i < 3; i++)
                Opacity(
                  opacity:
                      ((1 - _radarController.value + i * 0.33) % 1.0) * 0.35,
                  child: Container(
                    width: 190 - i * 38.0,
                    height: 190 - i * 38.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

              // Device dots
              if (_devices.isNotEmpty) ...[
                Positioned(
                  top: 20,
                  right: 50,
                  child: _buildDot(),
                ),
                if (_devices.length > 1)
                  Positioned(
                    bottom: 28,
                    left: 36,
                    child: _buildDot(),
                  ),
              ],

              // Center Bluetooth icon
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bluetooth_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.5),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }

  // ─── Search Text ───
  Widget _buildSearchText() {
    return Column(
      children: [
        const Text(
          "Searching for devices",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Looking for nearby devices\nto forward your SOS request",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.grey.withOpacity(0.8),
            height: 1.55,
          ),
        ),
        const SizedBox(height: 10),
        // Scanning dots
        AnimatedBuilder(
          animation: _radarController,
          builder: (context, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final delay = i * 0.33;
                final val =
                    (_radarController.value - delay + 1) % 1.0;
                final opacity = val < 0.5 ? val * 2 : (1 - val) * 2;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(opacity),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  // ─── Device Item ───
  Widget _buildDeviceItem(String endpointId, String deviceName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bluetooth_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              deviceName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          // Signal bars
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (i) {
              return Container(
                margin: const EdgeInsets.only(left: 2),
                width: 4,
                height: (i + 1) * 5.0,
                decoration: BoxDecoration(
                  color: i < 2
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── Send Button ───
  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isSending ? null : _sendSos,
        icon: _isSending
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.bluetooth_rounded,
                color: Colors.white, size: 20),
        label: Text(
          _isSending ? "Sending..." : "Send via Bluetooth",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
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

  // ─── Cancel Button ───
  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _cancel,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          "Cancel",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.grey.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}