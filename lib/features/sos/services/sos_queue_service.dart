import 'dart:async';
import '../controllers/sos_controller.dart';

class SosQueueService {
  // ===========================
  // Singleton Pattern
  // ===========================
  static final SosQueueService _instance = SosQueueService._internal();
  factory SosQueueService() => _instance;
  SosQueueService._internal();

  final SosController _sosController = SosController();

  Timer? _timer;
  bool _isRunning = false;
  bool _isProcessing = false;

  // ===========================
  // Start Queue (بيتشغل مع الأبلكيشن)
  // ===========================
  void start() {
    if (_isRunning) return;
    _isRunning = true;

    // شغل مرة فوراً عند البداية
    _processPendingRequests();

    // بعدين كل 5 ثواني
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _processPendingRequests();
    });
  }

  // ===========================
  // Stop Queue
  // ===========================
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  // ===========================
  // Process Pending Requests
  // ===========================
  Future<void> _processPendingRequests() async {
    // لو في process شغالة، متشتغلش تاني في نفس الوقت
    if (_isProcessing) return;

    _isProcessing = true;

    try {
      await _sosController.retryPendingRequests();
    } finally {
      _isProcessing = false;
    }
  }

  bool get isRunning => _isRunning;
}