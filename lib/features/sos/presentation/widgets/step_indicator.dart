import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;

  const StepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 45, child: _fullOrEmptyLine(0)),
              _buildCircle(0, sw),
              SizedBox(width: 70, child: _segment(1)),
              _buildCircle(1, sw),
              SizedBox(width: 70, child: _segment(2)),
              _buildCircle(2, sw),
              SizedBox(width: 45, child: _fullOrEmptyLine(3)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(width: 10),
              SizedBox(
                width: 90,
                child: Text("Enter personal\ninfo",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, height: 1.3, color: AppColors.grey)),
              ),
              SizedBox(width: 18),
              SizedBox(
                width: 90,
                child: Text("Enter location",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, height: 1.3, color: AppColors.grey)),
              ),
              SizedBox(width: 25),
              SizedBox(
                width: 90,
                child: Text("Select emergency\ntype",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, height: 1.3, color: AppColors.grey)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(int index, double sw) {
    final isActive = index <= currentStep;
    return Container(
      width: 38, height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.primary : const Color(0xffD9D9D9),
      ),
      child: Text(
        "${index + 1}",
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black54,
          fontWeight: FontWeight.w700,
          fontSize: sw * 0.04,
        ),
      ),
    );
  }

  Widget _fullOrEmptyLine(int index) {
    final isActive = index <= currentStep || currentStep == 2;
    return Container(height: 2, color: isActive ? AppColors.primary : const Color(0xffD9D9D9));
  }

  Widget _segment(int index) {
    final fullActive = index <= currentStep;
    final halfActive = index == currentStep + 1;
    return Row(
      children: [
        Expanded(child: Container(height: 2,
            color: (fullActive || halfActive) ? AppColors.primary : const Color(0xffD9D9D9))),
        Expanded(child: Container(height: 2,
            color: fullActive ? AppColors.primary : const Color(0xffD9D9D9))),
      ],
    );
  }
}