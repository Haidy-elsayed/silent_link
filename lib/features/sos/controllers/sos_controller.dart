import '../models/sos_request_model.dart';
import '../services/sos_api_service.dart';
import '../services/notification_service.dart';
import '../services/bluetooth_service.dart';
import '../services/network_service.dart';
import '../services/local_db_service.dart';

class SosController {
  final NetworkService _networkService = NetworkService();
  final LocalDbService _localDb = LocalDbService();
  final SosApiService _api = SosApiService();

  Future<Map<String, dynamic>> submit(SosRequestModel request) async {
    final now = DateTime.now();
    final hasInternet = await _networkService.isConnected();
    final state = hasInternet ? 'pending' : 'pending_connection';
    final deliveryMethod = hasInternet ? 'internet' : 'local';

    // نولد الـ clientRequestId مرة واحدة وبيفضل ثابت في كل retry
    final clientRequestId = request.clientRequestId ?? now.millisecondsSinceEpoch.toString();

    final finalRequest = request.copyWith(
      createdAt: now,
      state: state,
      deliveryMethod: deliveryMethod,
      clientRequestId: clientRequestId,
    );

    if (hasInternet) {
      final result = await _api.submitSos(finalRequest);
      if (result != null) {
        // نحفظ الـ request بـ state = sent عشان الـ queue ميبعتهوش تاني
        final savedRequest = finalRequest.copyWith(
          sosId: result['SosId'],
          state: 'sent',
        );
        await _localDb.insertSosRequest(savedRequest);

        if (result['SosId'] != null) {
          await NotificationService().trackSosId(result['SosId']!);
          NotificationService().startPolling();
        }

        return {
          "sosId": result['SosId'],
          "state": result['State'] ?? state,
          "deliveryMethod": deliveryMethod,
        };
      }
    }

    // مفيش نت أو فشل → حفظ محلياً بدون sosId
    await _localDb.insertSosRequest(finalRequest);
    return {
      "sosId": null,
      "state": state,
      "deliveryMethod": deliveryMethod,
    };
  }

  Future<void> retryPendingRequests() async {
    final hasInternet = await _networkService.isConnected();

    if (hasInternet) {
      final myRequests = await _localDb.getMyPendingRequests();
      for (final request in myRequests) {
        final result = await _api.submitSos(request);
        if (result != null && result['SosId'] != null) {
          await _localDb.updateSosId(
            request.createdAt.toIso8601String(),
            result['SosId'],
          );
          await _localDb.updateState(result['SosId'], 'sent');
          await NotificationService().trackSosId(result['SosId']!);
          NotificationService().startPolling();
        }
      }

      // received bluetooth requests
      final receivedBt = await _localDb.getReceivedBluetoothRequests();
      for (final request in receivedBt) {
        final result = await _api.submitSos(request);
        if (result != null && result['SosId'] != null) {
          await _localDb.updateSosId(
            request.createdAt.toIso8601String(),
            result['SosId'],
          );
          await _localDb.updateState(result['SosId'], 'delivered');
          await NotificationService().trackSosId(result['SosId']!);
          NotificationService().startPolling();

          final btService = BluetoothService();
          if (btService.hasDevices) {
            for (final endpointId in btService.discoveredDevices.keys) {
              await btService.sendSosIdResponse(
                endpointId,
                result['SosId']!,
                result['State'] ?? 'pending',
              );
            }
          }
        }
      }
    } else {
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
