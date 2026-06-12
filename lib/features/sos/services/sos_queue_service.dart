import 'dart:async';
import '../controllers/sos_controller.dart';
import '../../auth/service/auth_service.dart';

class SosQueueService {
  static final SosQueueService _instance = SosQueueService._internal();
  factory SosQueueService() => _instance;
  SosQueueService._internal();

  final SosController _sosController = SosController();

  Timer? _timer;
  bool _isRunning = false;
  bool _isProcessing = false;

  void start() {
    if (_isRunning) return;
    _isRunning = true;

    // بنستنى الـ token يكون موجود قبل ما نبدأ
    // عشان متبعتش requests من غير authentication
    _startWhenReady();
  }

  Future<void> _startWhenReady() async {
    // استنى لحد ما الـ token يكون موجود (max 30 ثانية)
    int attempts = 0;
    while (AuthServices.token == null && attempts < 30) {
      await Future.delayed(const Duration(seconds: 1));
      attempts++;
    }

    if (AuthServices.token == null) return; // مفيش token → متشتغلش

    // شغل أول مرة بعد ما الـ token يكون جاهز
    _processPendingRequests();

    // بعدين كل 30 ثانية
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _processPendingRequests();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  Future<void> _processPendingRequests() async {
    if (_isProcessing) return;
    if (AuthServices.token == null) return; // متشتغلش من غير token

    _isProcessing = true;
    try {
      await _sosController.retryPendingRequests();
    } finally {
      _isProcessing = false;
    }
  }

  bool get isRunning => _isRunning;
}