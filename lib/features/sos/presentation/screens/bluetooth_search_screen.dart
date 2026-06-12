import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/sos_request_model.dart';
import '../../services/bluetooth_service.dart';
import '../../services/local_db_service.dart';
import 'bluetooth_result_screen.dart';
import 'bluetooth_failed_screen.dart';

class BluetoothSearchScreen extends StatefulWidget {
  final String? requestId;
  final SosRequestModel? request;
  final bool fromSuccessScreen;

  const BluetoothSearchScreen({
    super.key,
    this.requestId,
    this.request,
    this.fromSuccessScreen = false,
  });

  @override
  State<BluetoothSearchScreen> createState() => _BluetoothSearchScreenState();
}

class _BluetoothSearchScreenState extends State<BluetoothSearchScreen>
    with SingleTickerProviderStateMixin {
  final BluetoothService _bluetoothService = BluetoothService();
  final LocalDbService _localDb = LocalDbService();

  Map<String, String> _devices = {};
  bool _hasSent = false;
  bool _isStarting = true;
  SosRequestModel? _request;
  late AnimationController _radarController;

  Timer? _timeoutTimer;
  Timer? _sendTimer;
  static const int _scanTimeoutSeconds = 30;
  static const int _collectDevicesSeconds = 3;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _startScan();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _timeoutTimer?.cancel();
    _sendTimer?.cancel();
    _bluetoothService.onDevicesChanged = null;
    _bluetoothService.stopDiscoveryOnly();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() => _isStarting = true);

    if (widget.request != null) {
      _request = widget.request;
    } else if (widget.requestId != null && widget.requestId!.isNotEmpty) {
      _request = await _localDb.getRequestBySosId(widget.requestId!);
      _request ??= await _localDb.getRequestByCreatedAt(widget.requestId!);
    }
    _request ??= await _localDb.getLatestPendingRequest();

    _bluetoothService.onDevicesChanged = (devices) {
      if (!mounted || _hasSent) return;
      setState(() => _devices = devices);
      if (devices.isNotEmpty && _request != null) {
        _timeoutTimer?.cancel();
        _sendTimer?.cancel();
        _sendTimer = Timer(const Duration(seconds: _collectDevicesSeconds), () {
          if (!mounted || _hasSent) return;
          _hasSent = true;
          _sendSos();
        });
      }
    };

    await _bluetoothService.startForSending();
    if (mounted) setState(() => _isStarting = false);

    _timeoutTimer = Timer(const Duration(seconds: _scanTimeoutSeconds), () {
      if (mounted && !_hasSent) _navigateToFailed();
    });
  }

  Future<void> _sendSos() async {
    if (_request == null) return;
    final result = await _bluetoothService.sendSos(_request!);
    await _bluetoothService.stopDiscoveryOnly();
    if (!mounted) return;

    if (result == BluetoothSendResult.success) {
      if (widget.fromSuccessScreen) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => BluetoothResultScreen(requestId: widget.requestId ?? _request?.sosId),
        ));
      } else {
        Navigator.pop(context, true);
      }
    } else {
      _hasSent = false;
      _navigateToFailed();
    }
  }

  void _navigateToFailed() {
    if (!mounted) return;
    if (widget.fromSuccessScreen) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => BluetoothFailedScreen(requestId: widget.requestId ?? _request?.sosId, request: _request),
      ));
    } else {
      Navigator.pop(context, false);
    }
  }

  Future<void> _cancel() async {
    _timeoutTimer?.cancel();
    _bluetoothService.onDevicesChanged = null;
    await _bluetoothService.stopDiscoveryOnly();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(sw),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressBar(sw),
                    const SizedBox(height: 32),
                    Center(child: _buildRadar(sw)),
                    const SizedBox(height: 28),
                    Center(child: _buildSearchText(sw)),
                    const SizedBox(height: 24),
                    if (_devices.isNotEmpty) ...[
                      Text(
                        "NEARBY DEVICES (${_devices.length})",
                        style: TextStyle(
                          fontSize: sw * 0.027,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey.withOpacity(0.7),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._devices.entries.map((e) => _buildDeviceItem(e.key, e.value, sw)),
                    ],
                    const SizedBox(height: 28),
                    _buildCancelButton(sw),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double sw) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: _cancel,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 14),
            ),
          ),
          const SizedBox(width: 12),
          Text("Bluetooth Mesh",
              style: TextStyle(color: Colors.white, fontSize: sw * 0.042, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isStarting ? "Initializing..." : (_hasSent ? "Sending..." : "Scanning nearby devices"),
              style: TextStyle(fontSize: sw * 0.03, color: AppColors.grey.withOpacity(0.75), fontWeight: FontWeight.w500),
            ),
            Text("${_devices.length} found",
                style: TextStyle(fontSize: sw * 0.03, color: AppColors.primary, fontWeight: FontWeight.w700)),
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

  Widget _buildRadar(double sw) {
    return SizedBox(
      width: 190, height: 190,
      child: AnimatedBuilder(
        animation: _radarController,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 0; i < 3; i++)
                Opacity(
                  opacity: ((1 - _radarController.value + i * 0.33) % 1.0) * 0.35,
                  child: Container(
                    width: sw * 0.47 - i * sw * 0.095,
                    height: sw * 0.47 - i * sw * 0.095,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              if (_devices.isNotEmpty) ...[
                Positioned(top: 20, right: 50, child: _buildDot()),
                if (_devices.length > 1) Positioned(bottom: 28, left: 36, child: _buildDot()),
              ],
              Container(
                width: 58, height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hasSent ? Colors.green : AppColors.primary,
                  boxShadow: [BoxShadow(
                    color: (_hasSent ? Colors.green : AppColors.primary).withOpacity(0.35),
                    blurRadius: 18, spreadRadius: 2,
                  )],
                ),
                child: Icon(_hasSent ? Icons.send_rounded : Icons.bluetooth_rounded, color: Colors.white, size: 28),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 6)],
      ),
    );
  }

  Widget _buildSearchText(double sw) {
    String title;
    String subtitle;

    if (_isStarting) {
      title = "Initializing Bluetooth...";
      subtitle = "Please wait";
    } else if (_hasSent) {
      title = "Sending SOS...";
      subtitle = "Device found! Forwarding your request";
    } else if (_devices.isNotEmpty) {
      title = "Device Found!";
      subtitle = "Connecting and sending SOS...";
    } else {
      title = "Searching for devices";
      subtitle = "Looking for nearby devices\nto forward your SOS request";
    }

    return Column(
      children: [
        Text(title,
            style: TextStyle(fontSize: sw * 0.045, fontWeight: FontWeight.w700, color: AppColors.black)),
        const SizedBox(height: 8),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: sw * 0.032, color: AppColors.grey.withOpacity(0.8), height: 1.55)),
        const SizedBox(height: 4),
        if (!_hasSent)
          Text("Timeout in ${_scanTimeoutSeconds}s if no device found",
              style: TextStyle(fontSize: sw * 0.027, color: AppColors.grey.withOpacity(0.55), fontStyle: FontStyle.italic)),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _radarController,
          builder: (context, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final delay = i * 0.33;
                final val = (_radarController.value - delay + 1) % 1.0;
                final opacity = val < 0.5 ? val * 2 : (1 - val) * 2;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 6, height: 6,
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

  Widget _buildDeviceItem(String endpointId, String deviceName, double sw) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.bluetooth_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(deviceName,
              style: TextStyle(fontSize: sw * 0.032, fontWeight: FontWeight.w600, color: AppColors.black))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text("Found",
                style: TextStyle(fontSize: sw * 0.027, color: Colors.green, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(double sw) {
    return SizedBox(
      width: double.infinity, height: 50,
      child: OutlinedButton(
        onPressed: _cancel,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text("Cancel",
            style: TextStyle(fontSize: sw * 0.035, fontWeight: FontWeight.w600, color: AppColors.grey.withOpacity(0.8))),
      ),
    );
  }
}