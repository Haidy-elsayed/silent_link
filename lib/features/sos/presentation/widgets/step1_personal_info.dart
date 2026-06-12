import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class _Country {
  final String flag;
  final String name;
  final String code;
  final int phoneLength;

  const _Country({required this.flag, required this.name, required this.code, required this.phoneLength});
}

const List<_Country> _supportedCountries = [
  _Country(flag: '🇪🇬', name: 'Egypt',   code: '+20',  phoneLength: 11),
  _Country(flag: '🇱🇾', name: 'Libya',   code: '+218', phoneLength: 10),
  _Country(flag: '🇹🇳', name: 'Tunisia', code: '+216', phoneLength: 8),
  _Country(flag: '🇩🇿', name: 'Algeria', code: '+213', phoneLength: 9),
  _Country(flag: '🇲🇦', name: 'Morocco', code: '+212', phoneLength: 9),
];

class Step1PersonalInfo extends StatefulWidget {
  final Function(String name, String phone, String countryCode, String countryFlag) onNext;
  final String initialName;
  final String initialPhone;
  final String initialCountryCode;
  final String initialCountryFlag;

  const Step1PersonalInfo({
    super.key,
    required this.onNext,
    this.initialName = '',
    this.initialPhone = '',
    this.initialCountryCode = '+20',
    this.initialCountryFlag = '🇪🇬',
  });

  @override
  State<Step1PersonalInfo> createState() => _Step1PersonalInfoState();
}

class _Step1PersonalInfoState extends State<Step1PersonalInfo> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late _Country selectedCountry;
  String? nameError;
  String? phoneError;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName);
    phoneController = TextEditingController(text: widget.initialPhone);
    selectedCountry = _supportedCountries.firstWhere(
      (c) => c.code == widget.initialCountryCode,
      orElse: () => _supportedCountries.first,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  bool _validate() {
    String? newNameError;
    String? newPhoneError;

    final name = nameController.text.trim();
    if (name.isEmpty) {
      newNameError = "Please enter your name";
    } else if (name.length < 3) {
      newNameError = "Name must be at least 3 characters";
    }

    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      newPhoneError = "Please enter your phone number";
    } else if (phone.length < selectedCountry.phoneLength) {
      newPhoneError = "Must be ${selectedCountry.phoneLength} digits for ${selectedCountry.name}";
    }

    setState(() {
      nameError = newNameError;
      phoneError = newPhoneError;
    });

    return newNameError == null && newPhoneError == null;
  }

  void _showCountryPicker(double sw) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Text('Select Country',
                  style: TextStyle(fontSize: sw * 0.04, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ..._supportedCountries.map((country) {
                final isSelected = country.code == selectedCountry.code;
                return ListTile(
                  leading: Text(country.flag, style: const TextStyle(fontSize: 26)),
                  title: Text(country.name,
                      style: TextStyle(fontSize: sw * 0.037, fontWeight: FontWeight.w500)),
                  trailing: Text(country.code,
                      style: TextStyle(
                        fontSize: sw * 0.035,
                        color: isSelected ? AppColors.primary : AppColors.grey,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                      )),
                  selected: isSelected,
                  selectedTileColor: AppColors.primary.withOpacity(0.06),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onTap: () {
                    setState(() {
                      selectedCountry = country;
                      phoneController.clear();
                      phoneError = null;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
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
        boxShadow: [
          BoxShadow(color: const Color(0xff000000).withOpacity(.18),
              blurRadius: 16, spreadRadius: 1, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Step 1",
              style: TextStyle(fontSize: sw * 0.055, fontWeight: FontWeight.w400, color: AppColors.black)),
          const SizedBox(height: 10),
          Text("Enter personal info",
              style: TextStyle(fontSize: sw * 0.045, fontWeight: FontWeight.w500, color: AppColors.black)),
          const SizedBox(height: 20),
          _nameField(sw),
          if (nameError != null) _errorText(nameError!, sw),
          const SizedBox(height: 16),
          _phoneField(sw),
          if (phoneError != null) _errorText(phoneError!, sw),
          const SizedBox(height: 28),
          Center(
            child: SizedBox(
              width: 320, height: 46,
              child: ElevatedButton(
                onPressed: () {
                  if (_validate()) {
                    widget.onNext(
                      nameController.text.trim(),
                      phoneController.text.trim(),
                      selectedCountry.code,
                      selectedCountry.flag,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    Text("Next",
                        style: TextStyle(color: Colors.white, fontSize: sw * 0.04, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: sw * 0.045),
                  ],
                ),
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

  Widget _nameField(double sw) {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: nameController,
        onChanged: (_) { if (nameError != null) setState(() => nameError = null); },
        decoration: InputDecoration(
          hintText: "Your name",
          hintStyle: TextStyle(color: AppColors.grey.withOpacity(.8), fontSize: sw * 0.035),
          prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.grey.withOpacity(.85), size: sw * 0.055),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: nameError != null ? Colors.red : AppColors.primary, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: nameError != null ? Colors.red : AppColors.primary, width: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _phoneField(double sw) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: phoneError != null ? Colors.red : AppColors.primary, width: 1),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showCountryPicker(sw),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(selectedCountry.flag, style: TextStyle(fontSize: sw * 0.05)),
                const SizedBox(width: 6),
                Text(selectedCountry.code,
                    style: TextStyle(fontSize: sw * 0.035, fontWeight: FontWeight.w500, color: AppColors.black)),
                const SizedBox(width: 2),
                Icon(Icons.arrow_drop_down_rounded, color: AppColors.grey, size: sw * 0.05),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 22, color: AppColors.grey.withOpacity(.6)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              maxLength: selectedCountry.phoneLength,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) { if (phoneError != null) setState(() => phoneError = null); },
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: '',
                hintText: "${selectedCountry.phoneLength} digits",
                hintStyle: TextStyle(color: AppColors.grey.withOpacity(.8), fontSize: sw * 0.035),
              ),
            ),
          ),
        ],
      ),
    );
  }
}