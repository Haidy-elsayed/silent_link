import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BluetoothResultScreen extends StatelessWidget {
  final String? requestId;

  const BluetoothResultScreen({super.key, this.requestId});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, sw),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    _buildSuccessIcon(),
                    const SizedBox(height: 24),
                    Text(
                      "SOS Forwarded",
                      style: TextStyle(
                        fontSize: sw * 0.065,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Your SOS was sent to a nearby device\nThey will forward it when connected",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: sw * 0.032,
                        color: AppColors.grey.withOpacity(0.85),
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildInfoCard(sw),
                    const SizedBox(height: 20),
                    _buildMeshPath(sw),
                    const SizedBox(height: 32),
                    _buildBackButton(context, sw),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double sw) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
              ),
              child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: sw * 0.035),
            ),
          ),
          const SizedBox(width: 12),
          Text("Bluetooth Mesh",
              style: TextStyle(color: Colors.white, fontSize: sw * 0.042, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 120, height: 120,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.withOpacity(0.1)),
      child: Center(
        child: Container(
          width: 90, height: 90,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
        ),
      ),
    );
  }

  Widget _buildInfoCard(double sw) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildInfoRow(dotColor: Colors.green, label: "REQUEST ID", value: requestId ?? "N/A", sw: sw),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade100),
          const SizedBox(height: 14),
          _buildInfoRow(dotColor: Colors.green, label: "STATUS", value: "Forwarded to nearby device", sw: sw),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade100),
          const SizedBox(height: 14),
          _buildInfoRow(dotColor: Colors.orange, label: "SERVER DELIVERY", value: "Pending - not confirmed yet", sw: sw),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required Color dotColor, required String label, required String value, required double sw}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 8, height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: sw * 0.025, fontWeight: FontWeight.w600,
                      color: AppColors.grey.withOpacity(0.7), letterSpacing: 0.6)),
              const SizedBox(height: 3),
              Text(value,
                  style: TextStyle(fontSize: sw * 0.032, fontWeight: FontWeight.w600, color: AppColors.black)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeshPath(double sw) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Mesh Path",
              style: TextStyle(fontSize: sw * 0.027, fontWeight: FontWeight.w600,
                  color: AppColors.grey.withOpacity(0.7), letterSpacing: 0.6)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildPathNode(color: AppColors.primary, icon: Icons.person_rounded, label: "Device", sw: sw),
              Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 18), color: AppColors.primary)),
              _buildPathNode(color: Colors.orange, icon: Icons.person_rounded, label: "You", sw: sw),
              Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 18),
                  child: CustomPaint(painter: _DashedLinePainter()))),
              _buildPathNode(color: Colors.grey.shade300, icon: Icons.dns_rounded, label: "Server", iconColor: Colors.grey, sw: sw),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text("⏳ Waiting for device to reach server",
                style: TextStyle(fontSize: sw * 0.027, color: AppColors.grey.withOpacity(0.7), fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  Widget _buildPathNode({required Color color, required IconData icon, required String label, Color? iconColor, required double sw}) {
    return Column(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Icon(icon, color: iconColor ?? Colors.white, size: sw * 0.045),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(fontSize: sw * 0.025, color: AppColors.grey.withOpacity(0.7), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context, double sw) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text("Back to home",
            style: TextStyle(color: Colors.white, fontSize: sw * 0.037, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.shade300..strokeWidth = 2;
    double startX = 0;
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}