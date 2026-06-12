import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/curved_nav_bar.dart';
import '../../controllers/sos_controller.dart';
import '../../models/sos_request_model.dart';
import 'sos_success_screen.dart';
import '../widgets/step1_personal_info.dart';
import '../widgets/step2_location.dart';
import '../widgets/step3_incident_type.dart';
import '../widgets/step_indicator.dart';

class CreateSosScreen extends StatefulWidget {
  const CreateSosScreen({super.key});

  @override
  State<CreateSosScreen> createState() => _CreateSosScreenState();
}

class _CreateSosScreenState extends State<CreateSosScreen> {
  int currentStep = 0;
  final SosController controller = SosController();
  SosRequestModel sosRequest = SosRequestModel.empty();

  String savedName = '';
  String savedPhone = '';
  String savedCountryCode = '+20';
  String savedCountryFlag = '🇪🇬';
  String savedLocationName = '';
  double savedLatitude = 0;
  double savedLongitude = 0;
  String savedEmergency = '';
  String savedInjury = '';
  String savedSeverity = '';

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: CustomCurvedNavBar(
        currentIndex: 0,
        onTap: (index) => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (currentStep > 0) {
                          setState(() => currentStep--);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.black),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Send SOS",
                      style: TextStyle(fontSize: sw * 0.055, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              StepIndicator(currentStep: currentStep),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildStep(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (currentStep) {
      case 0:
        return Step1PersonalInfo(
          initialName: savedName,
          initialPhone: savedPhone,
          initialCountryCode: savedCountryCode,
          initialCountryFlag: savedCountryFlag,
          onNext: (name, phone, countryCode, countryFlag) {
            savedName = name; savedPhone = phone;
            savedCountryCode = countryCode; savedCountryFlag = countryFlag;
            sosRequest = sosRequest.copyWith(name: name, phone: '$countryCode$phone');
            setState(() => currentStep = 1);
          },
        );
      case 1:
        return Step2Location(
          initialAddress: savedLocationName,
          initialLatitude: savedLatitude,
          initialLongitude: savedLongitude,
          onNext: (locationName, latitude, longitude) {
            savedLocationName = locationName; savedLatitude = latitude; savedLongitude = longitude;
            sosRequest = sosRequest.copyWith(locationName: locationName, latitude: latitude, longitude: longitude);
            setState(() => currentStep = 2);
          },
        );
      case 2:
        return Step3IncidentType(
          initialEmergency: savedEmergency,
          initialInjury: savedInjury,
          initialSeverity: savedSeverity,
          onChanged: (emergency, injury, severity) {
            savedEmergency = emergency; savedInjury = injury; savedSeverity = severity;
          },
          onSubmit: (emergency, injury, severity) async {
            savedEmergency = emergency; savedInjury = injury; savedSeverity = severity;
            sosRequest = sosRequest.copyWith(emergencyType: emergency, injuryType: injury, severity: severity);
            final result = await controller.submit(sosRequest);
            if (!mounted) return;
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => SosSuccessScreen(
                requestId: result["sosId"]?.toString() ?? "Pending...",
                status: result["state"],
              ),
            ));
          },
        );
      default:
        return const SizedBox();
    }
  }
}