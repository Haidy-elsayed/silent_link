import '../models/sos_request_model.dart';
import '../services/bluetooth_service.dart';
import '../services/network_service.dart';
import '../services/local_db_service.dart';

class SosController {
  final NetworkService _networkService = NetworkService();
  final LocalDbService _localDb = LocalDbService();

  Future<Map<String, dynamic>> submit(SosRequestModel request) async {
    final now = DateTime.now();
    final hasInternet = await _networkService.isConnected();
    final state = hasInternet ? 'pending' : 'pending_connection';
    final deliveryMethod = hasInternet ? 'internet' : 'local';

    final finalRequest = request.copyWith(
      createdAt: now,
      state: state,
      deliveryMethod: deliveryMethod,
    );

    if (hasInternet) {
      final result = await _trySendToServer(finalRequest);
      if (result != null) {
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

    final localSosId =
        'SOS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final requestWithId = finalRequest.copyWith(sosId: localSosId);
    await _localDb.insertSosRequest(requestWithId);

    return {
      "sosId": localSosId,
      "state": state,
      "deliveryMethod": deliveryMethod,
    };
  }

  Future<Map<String, dynamic>?> _trySendToServer(
      SosRequestModel request) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'SosId':
            'SOS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'State': 'pending',
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> retryPendingRequests() async {
    final hasInternet = await _networkService.isConnected();

    if (hasInternet) {
      // FIX: بنبعت بس الـ requests بتاعت الجهاز نفسه
      // مش الـ received_bluetooth لأنها بتاعت حد تاني
      // الـ received_bluetooth بيبعتها صاحبها بنفسه لما يدوس Forward
      final myRequests = await _localDb.getMyPendingRequests();

      for (final request in myRequests) {
        final res = await _trySendToServer(request);
        if (res != null) {
          await _localDb.updateSosId(
            request.createdAt.toIso8601String(),
            res['SosId'],
          );
          await _localDb.updateState(res['SosId'], 'delivered');
        }
      }
    } else {
      // مفيش نت → auto-forward عبر Bluetooth
      final received = await _localDb.getReceivedBluetoothRequests();
      if (received.isNotEmpty) {
        final bluetoothService = BluetoothService();
        if (bluetoothService.hasDevices) {
          for (final request in received) {
            final res = await bluetoothService.sendSos(request);
            if (res == BluetoothSendResult.success) {
              await _localDb.updateStateBySosIdOrCreatedAt(
                sosId: request.sosId,
                createdAt: request.createdAt.toIso8601String(),
                newState: 'forwarded_bluetooth',
              );
            }
          }
        }
      }
    }
  }

  Future<List<SosRequestModel>> getAllRequests() async {
    return await _localDb.getAllRequests();
  }

  Future<List<SosRequestModel>> getPendingRequests() async {
    return await _localDb.getPendingRequests();
  }
}