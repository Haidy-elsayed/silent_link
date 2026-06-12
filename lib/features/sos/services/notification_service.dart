// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'sos_api_service.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   void Function(String createdAt)? onNotificationOpenRequest;
//   void Function(String sosId, String state)? onNotificationOpenSosSuccess;

//   final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

//   Timer? _pollingTimer;
//   bool _isPolling = false;

//     static const int _pollingIntervalSeconds = 30;
//   static const String _pendingSosIdsKey = 'pending_sos_ids';

//   Future<void> init() async {
//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//     const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

//     await _plugin.initialize(
//       settings,
//       onDidReceiveNotificationResponse: _onNotificationTapped,
//     );

//     final launchDetails = await _plugin.getNotificationAppLaunchDetails();
//     if (launchDetails?.didNotificationLaunchApp == true) {
//       final payload = launchDetails?.notificationResponse?.payload;
//       if (payload != null) {
//         await Future.delayed(const Duration(milliseconds: 800));
//         _handlePayload(payload);
//       }
//     }
//   }

//   void _onNotificationTapped(NotificationResponse response) {
//     final payload = response.payload;
//     if (payload != null) _handlePayload(payload);
//   }

//   // ✅ الـ fix — بيتعامل مع incoming_sos و state_change
//   void _handlePayload(String payload) {
//     try {
//       final data = jsonDecode(payload) as Map<String, dynamic>;
//       final type = data['type'] as String?;

//       if (type == 'incoming_sos') {
//         final createdAt = data['createdAt'] as String? ?? '';
//         onNotificationOpenRequest?.call(createdAt);
//       } else if (type == 'state_change') {
//         final sosId = data['sosId']?.toString() ?? '';
//         final state = data['state']?.toString() ?? 'pending';
//         onNotificationOpenSosSuccess?.call(sosId, state);
//       }
//     } catch (_) {
//       onNotificationOpenRequest?.call('');
//     }
//   }

//   Future<void> sendIncomingSosNotification({
//     required String senderName,
//     required String emergencyType,
//     required String location,
//     required String createdAt,
//   }) async {
//     await _showNotification(
//       id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
//       title: '🆘 Incoming SOS Request',
//       body: '$senderName needs help — $emergencyType near $location',
//       payload: jsonEncode({
//         'type': 'incoming_sos',
//         'createdAt': createdAt,
//       }),
//     );
//   }

//   Future<void> sendAssistNotification({
//     required String helperName,
//     required String requestId,
//   }) async {
//     await _showNotification(
//       id: 1002,
//       title: '✅ Help is on the way!',
//       body: 'Someone nearby is coming to assist',
//       payload: jsonEncode({'type': 'assist_coming', 'requestId': requestId}),
//     );
//   }

//   // ✅ الـ fix — بنضيف state في الـ payload
//   Future<void> _sendStateChangeNotification(String sosId, String state) async {
//     String title = 'SOS Update';
//     String body = 'Your SOS status changed to: $state';

//     switch (state) {
//       case 'delivered':
//         title = '✅ SOS Delivered';
//         body = 'Your SOS request has been delivered successfully.';
//         break;
//       case 'resolved':
//         title = '✅ SOS Resolved';
//         body = 'Your SOS request has been resolved. Stay safe!';
//         break;
//     }

//     await _showNotification(
//       id: sosId.hashCode,
//       title: title,
//       body: body,
//       // ✅ بنضيف state في الـ payload عشان _handlePayload يبعتها لـ SosSuccessScreen
//       payload: jsonEncode({
//         'type': 'state_change',
//         'sosId': sosId,
//         'state': state,
//       }),
//     );
//   }

//   Future<void> _showNotification({
//     required int id,
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     const androidDetails = AndroidNotificationDetails(
//       'silent_link_channel',
//       'Silent Link',
//       channelDescription: 'SOS Alerts and Updates',
//       importance: Importance.high,
//       priority: Priority.high,
//       playSound: true,
//       enableVibration: true,
//     );
//     const iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
//     const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
//     await _plugin.show(id, title, body, details, payload: payload);
//   }

//   void startPolling() {
//     if (_isPolling) return;
//     _isPolling = true;
//     _checkSosStates();
//     _pollingTimer = Timer.periodic(
//       const Duration(seconds: _pollingIntervalSeconds),
//       (_) => _checkSosStates(),
//     );
//   }

//   void stopPolling() {
//     _pollingTimer?.cancel();
//     _pollingTimer = null;
//     _isPolling = false;
//   }

//   Future<void> _checkSosStates() async {
//     final sosIds = await _getPendingSosIds();
//     if (sosIds.isEmpty) return;
//     for (final sosId in List.from(sosIds)) {
//       await _checkSingleSosState(sosId);
//     }
//   }

//   Future<void> _checkSingleSosState(String sosId) async {
//     try {
//       final newState = await SosApiService().getSosState(sosId);
//       if (newState != null) await _handleStateChange(sosId, newState);
//     } catch (_) {}
//   }

//   Future<void> _handleStateChange(String sosId, String newState) async {
//     final prefs = await SharedPreferences.getInstance();
//     final lastState = prefs.getString('sos_state_$sosId');
//     if (lastState != newState) {
//       await prefs.setString('sos_state_$sosId', newState);
//       await _sendStateChangeNotification(sosId, newState);
//       if (newState == 'delivered' || newState == 'resolved') {
//         await _removeSosId(sosId);
//       }
//     }
//   }

//   Future<void> trackSosId(String sosId) async {
//     final ids = await _getPendingSosIds();
//     if (!ids.contains(sosId)) {
//       ids.add(sosId);
//       await _savePendingSosIds(ids);
//     }
//   }

//   Future<void> _removeSosId(String sosId) async {
//     final ids = await _getPendingSosIds();
//     ids.remove(sosId);
//     await _savePendingSosIds(ids);
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('sos_state_$sosId');
//   }

//   Future<List<String>> _getPendingSosIds() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getStringList(_pendingSosIdsKey) ?? [];
//   }

//   Future<void> _savePendingSosIds(List<String> ids) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList(_pendingSosIdsKey, ids);
//   }

//   bool get isPolling => _isPolling;
// }

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sos_api_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  void Function(String createdAt)? onNotificationOpenRequest;
  void Function(String sosId, String state)? onNotificationOpenSosSuccess;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Timer? _pollingTimer;
  bool _isPolling = false;

    static const int _pollingIntervalSeconds = 30;
  static const String _pendingSosIdsKey = 'pending_sos_ids';

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      final payload = launchDetails?.notificationResponse?.payload;
      if (payload != null) {
        await Future.delayed(const Duration(milliseconds: 800));
        _handlePayload(payload);
      }
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) _handlePayload(payload);
  }

  // ✅ الـ fix — بيتعامل مع incoming_sos و state_change
  void _handlePayload(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'] as String?;

      if (type == 'incoming_sos') {
        final createdAt = data['createdAt'] as String? ?? '';
        onNotificationOpenRequest?.call(createdAt);
      } else if (type == 'state_change') {
        final sosId = data['sosId']?.toString() ?? '';
        final state = data['state']?.toString() ?? 'pending';
        onNotificationOpenSosSuccess?.call(sosId, state);
      }
    } catch (_) {
      onNotificationOpenRequest?.call('');
    }
  }

  Future<void> sendIncomingSosNotification({
    required String senderName,
    required String emergencyType,
    required String location,
    required String createdAt,
  }) async {
    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🆘 Incoming SOS Request',
      body: '$senderName needs help — $emergencyType near $location',
      payload: jsonEncode({
        'type': 'incoming_sos',
        'createdAt': createdAt,
      }),
    );
  }

  Future<void> sendAssistNotification({
    required String helperName,
    required String requestId,
  }) async {
    await _showNotification(
      id: 1002,
      title: '✅ Help is on the way!',
      body: 'Someone nearby is coming to assist',
      payload: jsonEncode({'type': 'assist_coming', 'requestId': requestId}),
    );
  }

  // ✅ الـ fix — بنضيف state في الـ payload
  Future<void> sendStateChangeNotification(String sosId, String state) async {
    String title = 'SOS Update';
    String body = 'Your SOS status changed to: $state';

    switch (state) {
      case 'delivered':
        title = '✅ SOS Delivered';
        body = 'Your SOS request has been delivered successfully.';
        break;
      case 'resolved':
        title = '✅ SOS Resolved';
        body = 'Your SOS request has been resolved. Stay safe!';
        break;
    }

    await _showNotification(
      id: sosId.hashCode,
      title: title,
      body: body,
      // ✅ بنضيف state في الـ payload عشان _handlePayload يبعتها لـ SosSuccessScreen
      payload: jsonEncode({
        'type': 'state_change',
        'sosId': sosId,
        'state': state,
      }),
    );
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'silent_link_channel',
      'Silent Link',
      channelDescription: 'SOS Alerts and Updates',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.show(id, title, body, details, payload: payload);
  }

  void startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    _checkSosStates();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: _pollingIntervalSeconds),
      (_) => _checkSosStates(),
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
  }

  Future<void> _checkSosStates() async {
    final sosIds = await _getPendingSosIds();
    if (sosIds.isEmpty) return;
    for (final sosId in List.from(sosIds)) {
      await _checkSingleSosState(sosId);
    }
  }

  Future<void> _checkSingleSosState(String sosId) async {
    try {
      final newState = await SosApiService().getSosState(sosId);
      if (newState != null) await _handleStateChange(sosId, newState);
    } catch (_) {}
  }

  Future<void> _handleStateChange(String sosId, String newState) async {
    final prefs = await SharedPreferences.getInstance();
    final lastState = prefs.getString('sos_state_$sosId');
    if (lastState != newState) {
      await prefs.setString('sos_state_$sosId', newState);
      await sendStateChangeNotification(sosId, newState);
      if (newState == 'delivered' || newState == 'resolved') {
        await _removeSosId(sosId);
      }
    }
  }

  Future<void> trackSosId(String sosId) async {
    final ids = await _getPendingSosIds();
    if (!ids.contains(sosId)) {
      ids.add(sosId);
      await _savePendingSosIds(ids);
    }
  }

  Future<void> _removeSosId(String sosId) async {
    final ids = await _getPendingSosIds();
    ids.remove(sosId);
    await _savePendingSosIds(ids);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sos_state_$sosId');
  }

  Future<List<String>> _getPendingSosIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_pendingSosIdsKey) ?? [];
  }

  Future<void> _savePendingSosIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_pendingSosIdsKey, ids);
  }

  bool get isPolling => _isPolling;
}