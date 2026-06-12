import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import '../../../../core/constants/app_colors.dart';
import '../../../sos/services/network_service.dart';

class Step2Location extends StatefulWidget {
  final Function(String address, double latitude, double longitude) onNext;
  final String initialAddress;
  final double initialLatitude;
  final double initialLongitude;

  const Step2Location({
    super.key,
    required this.onNext,
    this.initialAddress = '',
    this.initialLatitude = 0,
    this.initialLongitude = 0,
  });

  @override
  State<Step2Location> createState() => _Step2LocationState();
}

class _Step2LocationState extends State<Step2Location> {
  late String address;
  late double latitude;
  late double longitude;
  bool isLoading = false;
  String? locationError;

  @override
  void initState() {
    super.initState();
    address = widget.initialAddress;
    latitude = widget.initialLatitude;
    longitude = widget.initialLongitude;
  }

  bool _validate() {
    if (address.isEmpty) {
      setState(() => locationError = "Please get your current location first");
      return false;
    }
    return true;
  }

  Future<void> _getCurrentLocation() async {
    setState(() { isLoading = true; locationError = null; });

    try {
      final location = loc.Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) { setState(() => isLoading = false); return; }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission permanently denied")),
        );
        setState(() => isLoading = false);
        return;
      }

      if (permission == LocationPermission.denied) { setState(() => isLoading = false); return; }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      latitude = position.latitude;
      longitude = position.longitude;
      address = await _getEnglishAddress(latitude, longitude);
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() => isLoading = false);
  }

  Future<String> _getEnglishAddress(double lat, double lon) async {
    final hasNet = await NetworkService().isConnected();
    if (!hasNet) return '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';

    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&accept-language=en'),
        headers: {'User-Agent': 'SilentLink/1.0'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final addr = data['address'] as Map<String, dynamic>?;
        if (addr != null) {
          final parts = <String>[];
          if (addr['road'] != null) parts.add(addr['road']);
          if (addr['suburb'] != null) parts.add(addr['suburb']);
          if (addr['city'] ?? addr['town'] ?? addr['village'] != null)
            parts.add(addr['city'] ?? addr['town'] ?? addr['village']);
          if (addr['country'] != null) parts.add(addr['country']);
          if (parts.isNotEmpty) return parts.join(', ');
        }
        return data['display_name']?.toString() ?? '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
      }
    } catch (_) {}
    return '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
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
          Text("Step 2",
              style: TextStyle(fontSize: sw * 0.055, fontWeight: FontWeight.w400, color: AppColors.black)),
          const SizedBox(height: 10),
          Text("Choose your location",
              style: TextStyle(fontSize: sw * 0.045, fontWeight: FontWeight.w500, color: AppColors.black)),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: isLoading
                  ? const SizedBox(height: 18, width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.my_location),
              label: Text(isLoading ? "Getting location..." : "Use current location"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: locationError != null ? Colors.red : AppColors.primary),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              address.isEmpty ? "Location will appear here" : address,
              style: TextStyle(fontSize: sw * 0.035, color: address.isEmpty ? AppColors.grey : AppColors.black),
            ),
          ),
          if (locationError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(locationError!,
                  style: TextStyle(color: Colors.red, fontSize: sw * 0.03)),
            ),
          const SizedBox(height: 28),
          Center(
            child: SizedBox(
              width: 320, height: 46,
              child: ElevatedButton(
                onPressed: () { if (_validate()) widget.onNext(address, latitude, longitude); },
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
}