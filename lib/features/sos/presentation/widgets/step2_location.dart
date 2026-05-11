import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import '../../../../core/constants/app_colors.dart';

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

  // ===========================
  // Validation
  // ===========================
  bool _validate() {
    if (address.isEmpty) {
      setState(() => locationError = "Please get your current location first");
      return false;
    }
    return true;
  }

  // ===========================
  // Get Location
  // ===========================
  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoading = true;
      locationError = null;
    });

    try {
      final location = loc.Location();

      /// ===============================
      /// 1) GPS SERVICE
      /// ===============================
      bool serviceEnabled = await location.serviceEnabled();

      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();

        if (!serviceEnabled) {
          setState(() => isLoading = false);
          return;
        }
      }

      /// ===============================
      /// 2) LOCATION PERMISSION
      /// ===============================
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      /// ===============================
      /// 3) PERMISSION DENIED FOREVER
      /// ===============================
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location permission permanently denied"),
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      if (permission == LocationPermission.denied) {
        setState(() => isLoading = false);
        return;
      }

      /// ===============================
      /// 4) GET POSITION
      /// ===============================
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = position.latitude;
      longitude = position.longitude;

      /// ===============================
      /// 5) REVERSE GEOCODING
      /// ===============================
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      final place = placemarks.first;
      address = "${place.street}, ${place.locality}, ${place.country}";

      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xffD9D9D9),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.18),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 2",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),

          const Text(
            "Choose your location",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 25),

          // Get Location Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.my_location),
              label: Text(
                isLoading ? "Getting location..." : "Use current location",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // Location Display Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(
                color: locationError != null ? Colors.red : AppColors.primary,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              address.isEmpty ? "Location will appear here" : address,
              style: TextStyle(
                fontSize: 14,
                color: address.isEmpty ? AppColors.grey : AppColors.black,
              ),
            ),
          ),

          // Location error
          if (locationError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                locationError!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),

          const SizedBox(height: 28),

          Center(
            child: SizedBox(
              width: 320,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  if (_validate()) {
                    widget.onNext(address, latitude, longitude);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  children: [
                    Spacer(),
                    Text(
                      "Next",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
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