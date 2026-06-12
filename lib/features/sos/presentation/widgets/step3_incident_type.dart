import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/sos_options.dart';
import 'custom_dropdown_field.dart';

class Step3IncidentType extends StatefulWidget {
  final Function(String emergency, String injury, String severity) onSubmit;
  final Function(String emergency, String injury, String severity)? onChanged;
  final String initialEmergency;
  final String initialInjury;
  final String initialSeverity;

  const Step3IncidentType({
    super.key,
    required this.onSubmit,
    this.initialEmergency = '',
    this.initialInjury = '',
    this.initialSeverity = '',
    this.onChanged,
  });

  @override
  State<Step3IncidentType> createState() => _Step3IncidentTypeState();
}

class _Step3IncidentTypeState extends State<Step3IncidentType> {
  String? selectedEmergency;
  String? selectedInjury;
  String? selectedSeverity;
  String? emergencyError;
  String? injuryError;
  String? severityError;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmergency.isNotEmpty) selectedEmergency = widget.initialEmergency;
    if (widget.initialInjury.isNotEmpty) selectedInjury = widget.initialInjury;
    if (widget.initialSeverity.isNotEmpty) selectedSeverity = widget.initialSeverity;
  }

  bool _validate() {
    setState(() {
      emergencyError = selectedEmergency == null ? "Please select emergency type" : null;
      injuryError = selectedInjury == null ? "Please select injury type" : null;
      severityError = selectedSeverity == null ? "Please select severity level" : null;
    });
    return selectedEmergency != null && selectedInjury != null && selectedSeverity != null;
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xffD9D9D9),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.18), blurRadius: 16, spreadRadius: 1, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Step 3",
              style: TextStyle(fontSize: sw * 0.055, fontWeight: FontWeight.w400, color: AppColors.black)),
          const SizedBox(height: 10),
          Text("Select incident type",
              style: TextStyle(fontSize: sw * 0.045, fontWeight: FontWeight.w500, color: AppColors.black)),
          const SizedBox(height: 22),
          CustomDropdownField(
            hint: "Select emergency type",
            value: selectedEmergency,
            items: emergencyTypes,
            hasError: emergencyError != null,
            onSelected: (value) {
              setState(() { selectedEmergency = value; emergencyError = null; });
              widget.onChanged?.call(value, selectedInjury ?? '', selectedSeverity ?? '');
            },
          ),
          if (emergencyError != null) _errorText(emergencyError!, sw),
          const SizedBox(height: 16),
          CustomDropdownField(
            hint: "Select injury type",
            value: selectedInjury,
            items: injuryTypes,
            hasError: injuryError != null,
            onSelected: (value) {
              setState(() { selectedInjury = value; injuryError = null; });
              widget.onChanged?.call(selectedEmergency ?? '', value, selectedSeverity ?? '');
            },
          ),
          if (injuryError != null) _errorText(injuryError!, sw),
          const SizedBox(height: 16),
          CustomDropdownField(
            hint: "Select severity level",
            value: selectedSeverity,
            items: severityLevels,
            hasError: severityError != null,
            onSelected: (value) {
              setState(() { selectedSeverity = value; severityError = null; });
              widget.onChanged?.call(selectedEmergency ?? '', selectedInjury ?? '', value);
            },
          ),
          if (severityError != null) _errorText(severityError!, sw),
          const SizedBox(height: 28),
          Center(
            child: SizedBox(
              width: 320, height: 46,
              child: ElevatedButton(
                onPressed: () {
                  if (_validate()) widget.onSubmit(selectedEmergency!, selectedInjury!, selectedSeverity!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffE62415), elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Send SOS",
                    style: TextStyle(color: Colors.white, fontSize: sw * 0.04, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorText(String message, double sw) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(message, style: TextStyle(color: Colors.red, fontSize: sw * 0.03)),
    );
  }
}