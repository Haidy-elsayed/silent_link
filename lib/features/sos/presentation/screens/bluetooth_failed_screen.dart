import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/sos_request_model.dart';
import 'bluetooth_search_screen.dart';

class BluetoothFailedScreen extends StatelessWidget {
  final String? requestId;
  // FIX: بنقبل الـ request object عشان Try Again يشتغل صح
  final SosRequestModel? request;

  const BluetoothFailedScreen({super.key, this.requestId, this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    _buildFailedIcon(),
                    const SizedBox(height: 24),
                    const Text(
                      'No Devices Found',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No nearby devices were found.\nMake sure others nearby have\nSilent Link installed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.grey.withOpacity(0.85),
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildInfoCard(),
                    const SizedBox(height: 20),
                    _buildWarningBox(),
                    const SizedBox(height: 32),
                    _buildTryAgainButton(context),
                    const SizedBox(height: 12),
                    _buildBackButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Bluetooth Mesh',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.sosRed.withOpacity(0.1),
      ),
      child: Center(
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.sosRed,
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 50),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            dotColor: AppColors.sosRed,
            label: 'REQUEST ID',
            value: requestId ?? 'N/A',
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade100),
          const SizedBox(height: 14),
          _buildInfoRow(
            dotColor: AppColors.sosRed,
            label: 'STATUS',
            value: 'Saved locally — waiting for connection',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required Color dotColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey.withOpacity(0.7),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your SOS is saved. It will be sent automatically once your device connects to the internet.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange.shade800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Try Again ───
  Widget _buildTryAgainButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          // FIX: بنبعت الـ request object لو موجود عشان نضمن إن الـ scan
          // هيلاقي الـ request من غير ما يرجع يدور في الـ DB
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  BluetoothSearchScreen(requestId: requestId, request: request),
            ),
          );
        },
        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
        label: const Text(
          'Try Again',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sosRed,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Back to home',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
