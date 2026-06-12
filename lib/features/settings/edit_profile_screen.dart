import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:silent_link/providers/user_provider.dart';
import 'package:silent_link/features/auth/widgets/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/profile_picture_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  String? selectedGender;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: userProvider.name);
    _emailController = TextEditingController(text: userProvider.email);
    _phoneController = TextEditingController(text: userProvider.phone);
    
    selectedGender = userProvider.gender == "Not Set" ? null : userProvider.gender;
    selectedDate = userProvider.birthDate == "Not Set" 
        ? null 
        : DateTime.tryParse(userProvider.birthDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  List<BoxShadow> get _softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              const SizedBox(height: 10),
              const Center(child: ProfilePictureWidget()),
              const SizedBox(height: 15),
              
              Consumer<UserProvider>(
                builder: (context, userProv, child) {
                  return Center(
                    child: Column(
                      children: [
                        Text(userProv.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(userProv.email, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 30),

              _buildInfoCard(
                title: "Personal Information",
                icon: Icons.person_outline,
                children: [
                  _buildTextField("Full Name", _nameController),
                  _buildTextField("Email", _emailController),
                  _buildTextField("Phone Number", _phoneController),
                ],
              ),

              const SizedBox(height: 20),

              _buildInfoCard(
                title: "Additional information",
                icon: Icons.badge_outlined,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildDatePicker()),
                      const SizedBox(width: 15),
                      Expanded(child: _buildGenderDropdown()),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              _buildSaveButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(height: 30),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: label == "Email", 
            decoration: InputDecoration(
              filled: true,
              fillColor: label == "Email" ? Colors.grey.shade100 : Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Date Of Birth", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime(2005, 3, 7),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => selectedDate = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null ? "Select" : DateFormat('yyyy-MM-dd').format(selectedDate!), 
                  style: TextStyle(color: selectedDate == null ? Colors.grey : Colors.black, fontSize: 13),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Gender", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedGender,
              isExpanded: true,
              hint: const Text("Select", style: TextStyle(fontSize: 13)),
              items: ["Male", "Female"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value, 
                  child: Text(value, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedGender = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Consumer<UserProvider>(
      builder: (context, userProv, child) {
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            
            onPressed: userProv.isLoading 
                ? null 
                : () async {
                   
                    String realToken = Provider.of<AuthProvider>(context, listen: false).token ?? "";

                    bool success = await userProv.updateProfile(
                      newName: _nameController.text,
                      newPhone: _phoneController.text,
                      newGender: selectedGender,
                      newBirthDate: selectedDate,
                      token: realToken, 
                    );

                    if (success) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Profile Updated Successfully!"),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop(); 
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to update profile. Please try again."),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 2,
            ),
            child: userProv.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    "Save", 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        );
      },
    );
  }
}