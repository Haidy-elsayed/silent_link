import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/sos_request_model.dart';
import 'local_db_service.dart';
import 'notification_service.dart';

class BluetoothService {
  // ===========================
  // Singleton Pattern
  // ===========================
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  final Nearby _nearby = Nearby();
  final LocalDbService _localDb = LocalDbService();

  // ===========================
  // Constants
  // ===========================
  static const String _serviceId = 'com.silentlink.sos';
  static const Strategy _strategy = Strategy.P2P_CLUSTER;

  // ===========================
  // State
  // ===========================
  bool _isAdvertising = false;
  bool _isDiscovering = false;

  // Discovered endpoints (deviceId → deviceName)
  final Map<String, String> _discoveredDevices = {};

  // Active connections
  final Set<String> _connectedEndpoints = {};

  // Seen SOS IDs (لمنع التكرار)
  final Set<String> _seenSosIds = {};

  // Callbacks للـ UI
  void Function(Map<String, String> devices)? onDevicesChanged;
  void Function(SosRequestModel request)? onSosReceived;
  void Function(String endpointId, bool connected)? onConnectionChanged;

  // ===========================
  // Permissions
  // ===========================
  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
      Permission.nearbyWifiDevices,
    ].request();

    return statuses.values.every(
      (status) => status == PermissionStatus.granted,
    );
  }

  // ===========================
  // Start (Advertise + Discover)
  // ===========================
  Future<bool> start(String userName) async {
    final hasPermissions = await requestPermissions();
    if (!hasPermissions) return false;

    await _startAdvertising(userName);
    await _startDiscovery();
    return true;
  }

  /// وقف كل حاجة
  Future<void> stop() async {
    await _nearby.stopAdvertising();
    await _nearby.stopDiscovery();
    await _nearby.stopAllEndpoints();
    _isAdvertising = false;
    _isDiscovering = false;
    _discoveredDevices.clear();
    _connectedEndpoints.clear();
  }

  // ===========================
  // Advertising
  // ===========================
  Future<void> _startAdvertising(String userName) async {
    if (_isAdvertising) return;

    try {
      await _nearby.startAdvertising(
        userName,
        _strategy,
        serviceId: _serviceId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
      _isAdvertising = true;
    } catch (e) {
      debugPrint('Advertising error: $e');
    }
  }

  // ===========================
  // Discovery
  // ===========================
  Future<void> _startDiscovery() async {
    if (_isDiscovering) return;

    try {
      await _nearby.startDiscovery(
        _serviceId,
        _strategy,
        serviceId: _serviceId,
        onEndpointFound: (endpointId, name, serviceId) {
          _discoveredDevices[endpointId] = name;
          onDevicesChanged?.call(Map.from(_discoveredDevices));
        },
        onEndpointLost: (endpointId) {
          _discoveredDevices.remove(endpointId);
          onDevicesChanged?.call(Map.from(_discoveredDevices));
        },
      );
      _isDiscovering = true;
    } catch (e) {
      debugPrint('Discovery error: $e');
    }
  }

  // ===========================
  // Connection Callbacks
  // ===========================
  void _onConnectionInitiated(String endpointId, ConnectionInfo info) {
    _nearby.acceptConnection(
      endpointId,
      onPayLoadRecieved: _onPayloadReceived,
      onPayloadTransferUpdate: (endpointId, update) {},
    );
  }

  void _onConnectionResult(String endpointId, Status status) {
    if (status == Status.CONNECTED) {
      _connectedEndpoints.add(endpointId);
      onConnectionChanged?.call(endpointId, true);
    } else {
      _connectedEndpoints.remove(endpointId);
      onConnectionChanged?.call(endpointId, false);
    }
  }

  void _onDisconnected(String endpointId) {
    _connectedEndpoints.remove(endpointId);
    _discoveredDevices.remove(endpointId);
    onDevicesChanged?.call(Map.from(_discoveredDevices));
    onConnectionChanged?.call(endpointId, false);
  }

  // ===========================
  // Send SOS via Bluetooth Mesh
  // ===========================
  Future<BluetoothSendResult> sendSos(SosRequestModel request) async {
    if (_discoveredDevices.isEmpty) {
      return BluetoothSendResult.noDevices;
    }

    final targetEndpointId = _discoveredDevices.keys.first;

    // Completer عشان ننتظر نتيجة الاتصال الحقيقية
    final completer = Completer<BluetoothSendResult>();

    try {
      await _nearby.requestConnection(
        'SilentLink',
        targetEndpointId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: (endpointId, status) async {
          if (status == Status.CONNECTED) {
            try {
              await _sendPayload(endpointId, request);
              if (request.sosId != null) {
                await _localDb.updateState(request.sosId!, 'forwarded_bluetooth');
                await _localDb.updateDeliveryMethod(request.sosId!, 'bluetooth');
              }
              if (!completer.isCompleted) {
                completer.complete(BluetoothSendResult.success);
              }
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(BluetoothSendResult.failed);
              }
            }
          } else {
            if (!completer.isCompleted) {
              completer.complete(BluetoothSendResult.failed);
            }
          }
        },
        onDisconnected: (_) {
          if (!completer.isCompleted) {
            completer.complete(BluetoothSendResult.failed);
          }
        },
      );

      // انتظر لحد 15 ثانية
      return await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () => BluetoothSendResult.failed,
      );
    } catch (e) {
      debugPrint('Send SOS error: $e');
      return BluetoothSendResult.failed;
    }
  }

  Future<void> _sendPayload(String endpointId, SosRequestModel request) async {
    final json = jsonEncode(request.toJson());
    final bytes = utf8.encode(json);
    await _nearby.sendBytesPayload(endpointId, Uint8List.fromList(bytes));
  }

  // ===========================
  // Receive SOS
  // ===========================
  void _onPayloadReceived(String endpointId, Payload payload) async {
    if (payload.type != PayloadType.BYTES) return;

    try {
      final json = utf8.decode(payload.bytes!);
      final map = jsonDecode(json) as Map<String, dynamic>;
      final request = SosRequestModel.fromJson(map);

      // ✅ Fix: تجاهل لو الـ sosId null أو شفناه قبل كده
      if (request.sosId == null) return;
      if (_seenSosIds.contains(request.sosId!)) return;
      _seenSosIds.add(request.sosId!);

      final savedRequest = request.copyWith(
        state: 'received_bluetooth',
        deliveryMethod: 'bluetooth',
      );

      await _localDb.insertSosRequest(savedRequest);

      // ✅ بعت notification برا الفون
      await NotificationService().sendIncomingSosNotification(
        senderName: request.name.isEmpty ? 'Unknown' : request.name,
        emergencyType: request.emergencyType.isEmpty ? 'Emergency' : request.emergencyType,
        location: request.locationName.isEmpty
            ? '${request.latitude.toStringAsFixed(3)}, ${request.longitude.toStringAsFixed(3)}'
            : request.locationName,
      );

      onSosReceived?.call(savedRequest);
    } catch (e) {
      debugPrint('Payload parse error: $e');
    }
  }

  // ===========================
  // Getters
  // ===========================
  Map<String, String> get discoveredDevices => Map.from(_discoveredDevices);
  bool get isActive => _isAdvertising || _isDiscovering;
  bool get hasDevices => _discoveredDevices.isNotEmpty;
}

// ===========================
// Result Enum
// ===========================
enum BluetoothSendResult { success, noDevices, failed }

// ignore: avoid_print
void debugPrint(String message) => print('[BluetoothService] $message');