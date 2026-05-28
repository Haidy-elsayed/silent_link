import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/sos_request_model.dart';
import 'local_db_service.dart';
import 'notification_service.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  final Nearby _nearby = Nearby();
  final LocalDbService _localDb = LocalDbService();

  static const String _serviceId = 'com.silentlink.sos';
  static const Strategy _strategy = Strategy.P2P_CLUSTER;

  // FIX: بدل ما نعتمد على _isAdvertising/_isDiscovering flags
  // هنعمل force stop دايماً قبل أي start عشان نتجنب
  // STATUS_ALREADY_ADVERTISING و STATUS_ALREADY_DISCOVERING
  bool _isAdvertising = false;
  bool _isDiscovering = false;

  // FIX: flag عشان نمنع الـ background onDevicesChanged
  // من إرسال الـ SOS بعد ما اتبعت
  bool _sendingLock = false;

  final Map<String, String> _discoveredDevices = {};
  final Set<String> _connectedEndpoints = {};
  final Set<String> _seenSosIds = {};

  void Function(Map<String, String> devices)? onDevicesChanged;
  void Function(SosRequestModel request)? onSosReceived;
  void Function(String endpointId, bool connected)? onConnectionChanged;

  // ===========================
  // Permissions
  // ===========================
  Future<bool> requestPermissions() async {
    final criticalPermissions = [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ];
    final optionalPermissions = [
      Permission.bluetooth,
      Permission.nearbyWifiDevices,
    ];
    final statuses =
        await [...criticalPermissions, ...optionalPermissions].request();
    for (final e in statuses.entries) {
      debugPrint('Perm ${e.key}: ${e.value}');
    }
    final ok = criticalPermissions.every((p) =>
        statuses[p] == PermissionStatus.granted ||
        statuses[p] == PermissionStatus.limited);
    debugPrint('Critical permissions ok: $ok');
    return ok;
  }

  // ===========================
  // FIX: _forceStop — بيوقف كل حاجة على مستوى الـ native
  // بغض النظر عن الـ flags
  // ===========================
  Future<void> _forceStop() async {
    try { await _nearby.stopAdvertising(); } catch (_) {}
    try { await _nearby.stopDiscovery(); } catch (_) {}
    try { await _nearby.stopAllEndpoints(); } catch (_) {}
    _isAdvertising = false;
    _isDiscovering = false;
    _discoveredDevices.clear();
    _connectedEndpoints.clear();
  }

  // ===========================
  // start — من main.dart
  // ===========================
  Future<bool> start(String userName) async {
    debugPrint('start() called');
    // FIX: دايماً نعمل force stop الأول
    // عشان لو كان في hot restart والـ native service لسه شغال
    await _forceStop();
    await Future.delayed(const Duration(milliseconds: 300));

    final ok = await requestPermissions();
    if (!ok) { debugPrint('start() — permissions denied'); return false; }

    await _startAdvertising(userName);
    await _startDiscovery();
    debugPrint('start() done adv=$_isAdvertising disc=$_isDiscovering');
    return true;
  }

  // ===========================
  // startForSending — من BluetoothSearchScreen
  // ===========================
  // startForSending — من BluetoothSearchScreen
  // بيعمل discovery جديد بس من غير ما يوقف الـ advertising
  Future<bool> startForSending() async {
    debugPrint('startForSending() called');
    _sendingLock = false;

    // وقف الـ discovery القديم بس
    try { await _nearby.stopDiscovery(); } catch (_) {}
    try { await _nearby.stopAllEndpoints(); } catch (_) {}
    _isDiscovering = false;
    _discoveredDevices.clear();
    _connectedEndpoints.clear();

    await Future.delayed(const Duration(milliseconds: 500));

    // ابدأ discovery جديد من غير ما تلمس الـ advertising
    await _startDiscovery();
    debugPrint('startForSending() done disc=$_isDiscovering adv=$_isAdvertising');
    return _isDiscovering;
  }

  // ===========================
  // stopDiscoveryOnly
  // ===========================
  Future<void> stopDiscoveryOnly() async {
    try { await _nearby.stopDiscovery(); } catch (_) {}
    try { await _nearby.stopAllEndpoints(); } catch (_) {}
    _isDiscovering = false;
    _discoveredDevices.clear();
    _connectedEndpoints.clear();
    debugPrint('Discovery stopped only');
  }

  Future<void> stop() async {
    await _forceStop();
    debugPrint('All BT stopped');
  }

  // ===========================
  // Advertising
  // ===========================
  Future<void> _startAdvertising(String userName) async {
    try {
      debugPrint('Starting advertising as: $userName');
      await _nearby.startAdvertising(
        userName,
        _strategy,
        serviceId: _serviceId,
        onConnectionInitiated: (endpointId, info) {
          debugPrint('Connection initiated: $endpointId (${info.endpointName})');
          // FIX: قبول الـ connection تلقائياً بدون أي popup
          _nearby.acceptConnection(
            endpointId,
            onPayLoadRecieved: _onPayloadReceived,
            onPayloadTransferUpdate: (endpointId, update) {
              debugPrint('Transfer: ${update.status}');
            },
          );
        },
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
      _isAdvertising = true;
      debugPrint('Advertising started!');
    } catch (e) {
      debugPrint('Advertising error: $e');
    }
  }

  // ===========================
  // Discovery
  // ===========================
  Future<void> _startDiscovery() async {
    try {
      debugPrint('Starting discovery...');
      await _nearby.startDiscovery(_serviceId, _strategy,
          serviceId: _serviceId,
          onEndpointFound: (endpointId, name, serviceId) {
            debugPrint('DEVICE FOUND: $name (id=$endpointId)');
            _discoveredDevices[endpointId] = name;
            onDevicesChanged?.call(Map.from(_discoveredDevices));
          },
          onEndpointLost: (endpointId) {
            debugPrint('Device LOST: $endpointId');
            _discoveredDevices.remove(endpointId);
            onDevicesChanged?.call(Map.from(_discoveredDevices));
          });
      _isDiscovering = true;
      debugPrint('Discovery started!');
    } catch (e) {
      debugPrint('Discovery error: $e');
    }
  }

  // ===========================
  // Connection Callbacks
  // ===========================
  void _onConnectionInitiated(String endpointId, ConnectionInfo info) {
    debugPrint('Connection initiated: $endpointId (${info.endpointName})');
    _nearby.acceptConnection(endpointId,
        onPayLoadRecieved: _onPayloadReceived,
        onPayloadTransferUpdate: (endpointId, update) {
          debugPrint('Transfer: ${update.status}');
        });
  }

  void _onConnectionResult(String endpointId, Status status) {
    debugPrint('Connection result: $endpointId -> $status');
    if (status == Status.CONNECTED) {
      _connectedEndpoints.add(endpointId);
      onConnectionChanged?.call(endpointId, true);
    } else {
      _connectedEndpoints.remove(endpointId);
      onConnectionChanged?.call(endpointId, false);
    }
  }

  void _onDisconnected(String endpointId) {
    debugPrint('Disconnected: $endpointId');
    _connectedEndpoints.remove(endpointId);
    _discoveredDevices.remove(endpointId);
    onDevicesChanged?.call(Map.from(_discoveredDevices));
    onConnectionChanged?.call(endpointId, false);
  }

  // ===========================
  // Send SOS
  // ===========================
  Future<BluetoothSendResult> sendSos(SosRequestModel request) async {
    // FIX: استخدم _sendingLock بدل ما يعتمد على الـ screen فقط
    if (_sendingLock) {
      debugPrint('sendSos() blocked — already sending');
      return BluetoothSendResult.failed;
    }
    if (_discoveredDevices.isEmpty) return BluetoothSendResult.noDevices;

    _sendingLock = true; // اقفل فوراً
    final targetEndpointId = _discoveredDevices.keys.first;
    debugPrint('sendSos() sending to: ${_discoveredDevices[targetEndpointId]} ($targetEndpointId)');

    final completer = Completer<BluetoothSendResult>();

    try {
      await _nearby.requestConnection('SilentLink', targetEndpointId,
          onConnectionInitiated: (endpointId, info) {
            debugPrint('Send connection initiated: $endpointId');
            _nearby.acceptConnection(
              endpointId,
              onPayLoadRecieved: _onPayloadReceived,
              onPayloadTransferUpdate: (eid, update) {},
            );
          },
          onConnectionResult: (endpointId, status) async {
            debugPrint('Send conn result: $status');
            if (status == Status.CONNECTED) {
              try {
                await _sendPayload(endpointId, request);
                if (request.sosId != null && request.sosId!.isNotEmpty) {
                  await _localDb.updateState(
                      request.sosId!, 'forwarded_bluetooth');
                  await _localDb.updateDeliveryMethod(
                      request.sosId!, 'bluetooth');
                } else {
                  await _localDb.updateStateBySosIdOrCreatedAt(
                    sosId: null,
                    createdAt: request.createdAt.toIso8601String(),
                    newState: 'forwarded_bluetooth',
                  );
                }
                debugPrint('SOS sent successfully!');
                if (!completer.isCompleted) {
                  completer.complete(BluetoothSendResult.success);
                }
              } catch (e) {
                debugPrint('Payload error: $e');
                if (!completer.isCompleted) {
                  completer.complete(BluetoothSendResult.failed);
                }
              }
            } else {
              debugPrint('Connection rejected: $status');
              if (!completer.isCompleted) {
                completer.complete(BluetoothSendResult.failed);
              }
            }
          },
          onDisconnected: (_) {
            debugPrint('Disconnected during send');
            if (!completer.isCompleted) {
              completer.complete(BluetoothSendResult.failed);
            }
          });

      final result = await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('Send timeout!');
          return BluetoothSendResult.failed;
        },
      );

      // FIX: بعد الإرسال — فك الـ lock بس لو فشل
      // عشان لو نجح مش هيتبعت تاني
      if (result != BluetoothSendResult.success) {
        _sendingLock = false;
      }
      return result;
    } catch (e) {
      debugPrint('sendSos error: $e');
      _sendingLock = false;
      return BluetoothSendResult.failed;
    }
  }

  Future<void> _sendPayload(
      String endpointId, SosRequestModel request) async {
    final json = jsonEncode(request.toJson());
    final bytes = utf8.encode(json);
    await _nearby.sendBytesPayload(endpointId, Uint8List.fromList(bytes));
    debugPrint('Payload sent: ${bytes.length} bytes');
  }

  // ===========================
  // Receive SOS
  // ===========================
  void _onPayloadReceived(String endpointId, Payload payload) async {
    debugPrint('Payload received from: $endpointId');
    if (payload.type != PayloadType.BYTES) return;
    try {
      final json = utf8.decode(payload.bytes!);
      final map = jsonDecode(json) as Map<String, dynamic>;
      final request = SosRequestModel.fromJson(map);
      final uniqueKey =
          request.sosId ?? request.createdAt.toIso8601String();
      if (_seenSosIds.contains(uniqueKey)) {
        debugPrint('Dup SOS: $uniqueKey');
        return;
      }
      _seenSosIds.add(uniqueKey);
      final savedRequest = request.copyWith(
          state: 'received_bluetooth', deliveryMethod: 'bluetooth');
      await _localDb.insertSosRequest(savedRequest);
      debugPrint('SOS saved: $uniqueKey');
      await NotificationService().sendIncomingSosNotification(
        senderName: request.name.isEmpty ? 'Unknown' : request.name,
        emergencyType: request.emergencyType.isEmpty
            ? 'Emergency'
            : request.emergencyType,
        location: request.locationName.isEmpty
            ? '${request.latitude.toStringAsFixed(3)}, ${request.longitude.toStringAsFixed(3)}'
            : request.locationName,
        createdAt: savedRequest.createdAt.toIso8601String(),
      );
      onSosReceived?.call(savedRequest);
    } catch (e) {
      debugPrint('Parse error: $e');
    }
  }

  Map<String, String> get discoveredDevices => Map.from(_discoveredDevices);
  bool get isActive => _isAdvertising || _isDiscovering;
  bool get hasDevices => _discoveredDevices.isNotEmpty;
}

enum BluetoothSendResult { success, noDevices, failed }

// ignore: avoid_print
void debugPrint(String message) => print('[BT] $message');