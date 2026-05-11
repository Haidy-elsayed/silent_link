import '../models/sos_request_model.dart';
import '../services/bluetooth_service.dart';
import '../services/network_service.dart';
import '../services/local_db_service.dart';

class SosController {
  final NetworkService _networkService = NetworkService();
  final LocalDbService _localDb = LocalDbService();

  // ===========================
  // Submit SOS Request
  // ===========================
  Future<Map<String, dynamic>> submit(SosRequestModel request) async {
    final now = DateTime.now();

    // تشيك على النت
    final hasInternet = await _networkService.isConnected();
    final state = hasInternet ? 'pending' : 'pending_connection';
    final deliveryMethod = hasInternet ? 'internet' : 'local';

    // إنشاء الـ request بدون SosId
    final finalRequest = request.copyWith(
      createdAt: now,
      state: state,
      deliveryMethod: deliveryMethod,
    );

    // لو في نت → ابعت للـ backend واستنى الـ SosId منه
    if (hasInternet) {
      final result = await _trySendToServer(finalRequest);
      if (result != null) {
        // حفظ في SQLite بالـ SosId الجاي من الـ backend
        final savedRequest = finalRequest.copyWith(
          sosId: result['SosId'],
          state: result['State'] ?? state,
        );
        await _localDb.insertSosRequest(savedRequest);

        return {
          "sosId": result['SosId'],
          "state": result['State'] ?? state,
          "deliveryMethod": deliveryMethod,
        };
      }
    }

    // لو مفيش نت أو فشل الإرسال → حفظ محلياً بدون SosId
    await _localDb.insertSosRequest(finalRequest);

    return {
      "sosId": null,
      "state": state,
      "deliveryMethod": deliveryMethod,
    };
  }

  // ===========================
  // Send to Backend Server
  // ===========================
  Future<Map<String, dynamic>?> _trySendToServer(
      SosRequestModel request) async {
    try {
      // TODO: استبدل الـ URL ده بالـ endpoint الحقيقي لما الـ backend يخلص
      // final response = await http.post(
      //   Uri.parse('https://your-api.com/api/sos'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(request.toJson()),
      // );
      // if (response.statusCode == 200 || response.statusCode == 201) {
      //   final data = jsonDecode(response.body);
      //   return { 'SosId': data['SosId'], 'State': data['State'] };
      // }
      // return null;

      // مؤقتاً: simulate response من الـ backend
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'SosId': 'SOS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'State': 'pending',
      };
    } catch (_) {
      return null;
    }
  }

  // ===========================
  // Retry Loop
  // ===========================
  Future<void> retryPendingRequests() async {
    final hasInternet = await _networkService.isConnected();

    if (hasInternet) {
      // ── إرسال كل الطلبات اللي لسه ما اتبعتتش ──
      // يشمل: pending, pending_connection, received_bluetooth, forwarded_bluetooth
      final pending = await _localDb.getPendingRequests();
      for (final request in pending) {
        final result = await _trySendToServer(request);
        if (result != null) {
          await _localDb.updateSosId(
            request.createdAt.toIso8601String(),
            result['SosId'],
          );
          await _localDb.updateState(result['SosId'], 'delivered');
        }
      }
    } else {
      // ── مفيش نت → عمل Auto-Forward عبر Bluetooth Mesh ──
      // الطلبات اللي جات عبر Bluetooth وناقص تتبعت
      final received = await _localDb.getReceivedBluetoothRequests();
      if (received.isNotEmpty) {
        final bluetoothService = BluetoothService();
        if (bluetoothService.hasDevices) {
          for (final request in received) {
            final result = await bluetoothService.sendSos(request);
            if (result == BluetoothSendResult.success) {
              await _localDb.updateState(
                request.sosId ?? request.createdAt.toIso8601String(),
                'forwarded_bluetooth',
              );
            }
          }
        }
      }
    }
  }

  // ===========================
  // Getters
  // ===========================
  Future<List<SosRequestModel>> getAllRequests() async {
    return await _localDb.getAllRequests();
  }

  Future<List<SosRequestModel>> getPendingRequests() async {
    return await _localDb.getPendingRequests();
  }
}