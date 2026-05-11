import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  // ===========================
  // Singleton Pattern
  // ===========================
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Timer? _pollingTimer;
  bool _isPolling = false;

  // ===========================
  // Constants
  // ===========================
  static const String _baseUrl = 'https://your-api.com'; // TODO: replace
  static const int _pollingIntervalSeconds = 30;
  static const String _pendingSosIdsKey = 'pending_sos_ids';

  // ===========================
  // Init
  // ===========================
  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
  }

  // ===========================
  // Start Polling
  // بيشتغل مع بداية الأبلكيشن
  // ===========================
  void startPolling() {
    if (_isPolling) return;
    _isPolling = true;

    // شغل مرة فوراً
    _checkSosStates();

    // بعدين كل 30 ثانية
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

  // ===========================
  // Check SOS States
  // بيجيب الـ SOS IDs المحفوظة ويشيك على حالتهم
  // ===========================
  Future<void> _checkSosStates() async {
    final sosIds = await _getPendingSosIds();
    if (sosIds.isEmpty) return;

    for (final sosId in List.from(sosIds)) {
      await _checkSingleSosState(sosId);
    }
  }

  Future<void> _checkSingleSosState(String sosId) async {
    try {
      // TODO: استبدل بالـ endpoint الحقيقي
      final response = await http.get(
        Uri.parse('$_baseUrl/api/sos/$sosId/state'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newState = data['State'] as String?;

        if (newState != null) {
          await _handleStateChange(sosId, newState);
        }
      }
    } catch (_) {
      // مش محتاج نعمل حاجة لو فشل الـ request
    }
  }

  // ===========================
  // Handle State Change
  // ===========================
  Future<void> _handleStateChange(String sosId, String newState) async {
    final prefs = await SharedPreferences.getInstance();
    final lastStateKey = 'sos_state_$sosId';
    final lastState = prefs.getString(lastStateKey);

    // لو الـ state اتغيرت → بعت notification
    if (lastState != newState) {
      await prefs.setString(lastStateKey, newState);
      await _sendStateChangeNotification(sosId, newState);

      // لو اتبعت → شيله من قائمة الـ polling
      if (newState == 'delivered' || newState == 'resolved') {
        await _removeSosId(sosId);
      }
    }
  }

  // ===========================
  // Send Notifications
  // ===========================

  /// Notification لما الـ state تتغير
  Future<void> _sendStateChangeNotification(
      String sosId, String state) async {
    String title = '';
    String body = '';

    switch (state) {
      case 'delivered':
        title = '✅ SOS Delivered';
        body = 'Your SOS request ($sosId) has been delivered successfully.';
        break;
      case 'resolved':
        title = '✅ SOS Resolved';
        body = 'Your SOS request ($sosId) has been resolved. Stay safe!';
        break;
      case 'pending':
        title = '⏳ SOS Pending';
        body = 'Your SOS request ($sosId) is being processed.';
        break;
      default:
        title = 'SOS Update';
        body = 'Your SOS request ($sosId) status: $state';
    }

    await _showNotification(
      id: sosId.hashCode,
      title: title,
      body: body,
    );
  }

  /// Notification لما يجيلك SOS من Bluetooth Mesh
  Future<void> sendIncomingSosNotification({
    required String senderName,
    required String emergencyType,
    required String location,
  }) async {
    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🆘 Incoming SOS Request',
      body: '$senderName needs help — $emergencyType near $location',
    );
  }

  /// بيبعت الـ notification الفعلية
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
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

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details);
  }

  // ===========================
  // SOS IDs Management
  // بيحفظ الـ SOS IDs اللي محتاج يتابعها
  // ===========================

  /// أضيف SOS ID للمتابعة لما المستخدم يبعت SOS
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

    // شيل الـ state المحفوظ
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