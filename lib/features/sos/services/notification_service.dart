import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// GlobalKey للـ navigation من الـ notification
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Callback — الـ SosScreen بيسمع عليه
void Function(String createdAt)? onNotificationOpenRequest;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Timer? _pollingTimer;
  bool _isPolling = false;

  static const String _baseUrl = 'https://silentlink.runasp.net';
  static const int _pollingIntervalSeconds = 30;
  static const String _pendingSosIdsKey = 'pending_sos_ids';

  // ===========================
  // Init
  // ===========================
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

    // لو الأبلكيشن كان مقفول وفتح من notification
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      final payload = launchDetails?.notificationResponse?.payload;
      if (payload != null) {
        await Future.delayed(const Duration(milliseconds: 800));
        _handlePayload(payload);
      }
    }
  }

  // ===========================
  // Notification Tap
  // ===========================
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) _handlePayload(payload);
  }

  void _handlePayload(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'] as String?;
      final createdAt = data['createdAt'] as String?;

      if (type == 'incoming_sos' && createdAt != null) {
        // FIX: بنبعت الـ createdAt للـ SosScreen عشان يفتح الـ RequestDetailsScreen مباشرةً
        onNotificationOpenRequest?.call(createdAt);
      }
    } catch (_) {
      // fallback — افتح الـ SOS screen بس
      onNotificationOpenRequest?.call('');
    }
  }

  // ===========================
  // Incoming SOS من Bluetooth — بنحفظ الـ createdAt في الـ payload
  // ===========================
  Future<void> sendIncomingSosNotification({
    required String senderName,
    required String emergencyType,
    required String location,
    required String createdAt, // FIX: محتاجينه عشان نعرف أي request
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

  // ===========================
  // Assist Notification — Device 2 بيبعت للـ Device 1
  // ===========================
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

  // ===========================
  // State Change Notification
  // ===========================
  Future<void> _sendStateChangeNotification(String sosId, String state) async {
    String title = 'SOS Update';
    String body = 'Your SOS ($sosId) status: $state';

    switch (state) {
      case 'delivered':
        title = '✅ SOS Delivered';
        body = 'Your SOS request ($sosId) has been delivered successfully.';
        break;
      case 'resolved':
        title = '✅ SOS Resolved';
        body = 'Your SOS request ($sosId) has been resolved. Stay safe!';
        break;
    }

    await _showNotification(
      id: sosId.hashCode,
      title: title,
      body: body,
      payload: jsonEncode({'type': 'state_change', 'sosId': sosId}),
    );
  }

  // ===========================
  // Show Notification
  // ===========================
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

  // ===========================
  // Polling
  // ===========================
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
      final response = await http.get(
        Uri.parse('$_baseUrl/api/App/$sosId/state'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newState = (data['state'] ?? data['State'])?.toString().toLowerCase();
        if (newState != null) await _handleStateChange(sosId, newState);
      }
    } catch (_) {}
  }

  Future<void> _handleStateChange(String sosId, String newState) async {
    final prefs = await SharedPreferences.getInstance();
    final lastState = prefs.getString('sos_state_$sosId');
    if (lastState != newState) {
      await prefs.setString('sos_state_$sosId', newState);
      await _sendStateChangeNotification(sosId, newState);
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