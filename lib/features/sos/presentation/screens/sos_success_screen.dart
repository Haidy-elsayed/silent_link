import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/sos_request_model.dart';
import 'bluetooth_search_screen.dart';

class SosSuccessScreen extends StatelessWidget {
  final String requestId;
  final String status;
  // FIX: بنقبل الـ request object عشان نبعته للـ BluetoothSearchScreen
  final SosRequestModel? request;

  const SosSuccessScreen({
    super.key,
    required this.requestId,
    required this.status,
    this.request,
  });

  String get statusText {
    switch (status) {
      case 'pending_connection': return 'Pending Connection';
      case 'delivered': return 'Delivered';
      default: return 'Pending Delivery';
    }
  }

  String get message {
    switch (status) {
      case 'pending_connection':
        return 'Your request is saved safely.\nIt will be sent automatically once connection is available.';
      case 'delivered':
        return 'Your emergency request has been delivered successfully.\nHelp is on the way. Stay safe.';
      default:
        return 'Your emergency request has been recorded successfully.';
    }
  }

  String get helpText {
    switch (status) {
      case 'pending_connection':
        return 'No internet? You can forward your SOS to a nearby device via Bluetooth Mesh.';
      case 'delivered':
        return 'Stay calm. Our team has received your request.';
      default:
        return 'Stay calm. Our team has been notified and will reach you as soon as possible.';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending_connection': return Colors.red;
      case 'delivered': return Colors.green;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 130, height: 130,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.withOpacity(.08)),
                child: Center(
                  child: Container(
                    width: 95, height: 95,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 58),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text("SOS Submitted",
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.black)),
              const SizedBox(height: 18),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.7, color: AppColors.grey.withOpacity(.95))),
              const SizedBox(height: 30),

              // Request Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description_outlined, color: AppColors.primary.withOpacity(.85)),
                        const SizedBox(width: 10),
                        Text("Request ID", style: TextStyle(fontSize: 15, color: AppColors.grey.withOpacity(.9))),
                        const Spacer(),
                        Text(requestId,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1, color: AppColors.black)),
                        const SizedBox(width: 6),
                        InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () async {
                            await Clipboard.setData(ClipboardData(text: requestId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Request ID copied"), duration: Duration(milliseconds: 1200)),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text("Status", style: TextStyle(fontSize: 15, color: AppColors.grey.withOpacity(.9))),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(.12),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(statusText,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Help Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: status == 'pending_connection' ? const Color(0xffFFF3E0) : const Color(0xffEAF7EF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: status == 'pending_connection'
                        ? Colors.orange.withOpacity(.25)
                        : Colors.green.withOpacity(.15),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      status == 'pending_connection' ? Icons.wifi_off_rounded : Icons.shield_outlined,
                      color: status == 'pending_connection' ? Colors.orange : AppColors.primary,
                      size: 30,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status == 'pending_connection' ? "No Internet Connection" : "Help is on the way.",
                            style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700,
                              color: status == 'pending_connection' ? Colors.orange.shade800 : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(helpText,
                              style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.black.withOpacity(.72))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // FIX: Bluetooth Button — بيبعت الـ request object كمان
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton.icon(
                  onPressed: status == 'pending_connection'
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BluetoothSearchScreen(
                                requestId: requestId,
                                request: request,
                                fromSuccessScreen: true,
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: Icon(Icons.bluetooth_rounded,
                      color: status == 'pending_connection' ? Colors.white : Colors.white54, size: 22),
                  label: Text("Send via Bluetooth Mesh",
                      style: TextStyle(
                        color: status == 'pending_connection' ? Colors.white : Colors.white54,
                        fontSize: 16, fontWeight: FontWeight.w600,
                      )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: status == 'pending_connection'
                        ? const Color(0xFF1A6B9A)
                        : const Color(0xFF1A6B9A).withOpacity(0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Back To Home",
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}