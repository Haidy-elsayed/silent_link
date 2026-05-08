import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'data/models/map_location.dart';
import 'data/services/map_api_service.dart';
import 'package:silent_link/core/constants/colors.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class MapPage extends StatefulWidget {
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool isLoading = true;

  List<MapLocationModel> allLocations = [];
  List<MapLocationModel> filteredLocations = [];

  String selectedType = "all";

  @override
  void initState() {
    super.initState();
    initCache();
    loadData();
  }

  /// 🟢 initialize offline cache
  Future<void> initCache() async {
    await FMTCStore('mapStore').manage.create();
  }

  /// 📦 load data
  Future<void> loadData() async {
    setState(() => isLoading = true);

    final data = getLocalData(); // مؤقتًا بدل backend

    setState(() {
      allLocations = data;
      applyFilter("all", updateState: false);
      isLoading = false;
    });
  }

  /// 🗺️ BIGGER LOCAL DATA (Egypt)
  List<MapLocationModel> getLocalData() {
    return [
      // 🔴 DANGER (6)
      MapLocationModel(id: 1, lat: 30.0444, lng: 31.2357, type: "danger"), // Tahrir
      MapLocationModel(id: 2, lat: 30.0626, lng: 31.2497, type: "danger"), // Ramses
      MapLocationModel(id: 3, lat: 29.9773, lng: 31.1325, type: "danger"), // Giza
      MapLocationModel(id: 4, lat: 30.0210, lng: 31.2118, type: "danger"), // Dokki
      MapLocationModel(id: 5, lat: 30.0480, lng: 31.2400, type: "danger"), // Downtown
      MapLocationModel(id: 6, lat: 30.0330, lng: 31.2500, type: "danger"), // Kasr El Nile

      // 🟢 SAFE (6)
      MapLocationModel(id: 7, lat: 30.0732, lng: 31.3461, type: "safe"), // Nasr City
      MapLocationModel(id: 8, lat: 30.0956, lng: 31.3178, type: "safe"), // Heliopolis
      MapLocationModel(id: 9, lat: 30.0185, lng: 31.4152, type: "safe"), // New Cairo
      MapLocationModel(id: 10, lat: 30.0595, lng: 31.2239, type: "safe"), // Garden City
      MapLocationModel(id: 11, lat: 30.0700, lng: 31.3300, type: "safe"), // Abbasia
      MapLocationModel(id: 12, lat: 30.0800, lng: 31.3000, type: "safe"), // Shorouk

      // 🟡 HELP (6)
      MapLocationModel(id: 13, lat: 30.0500, lng: 31.2350, type: "help"), // Tahrir services
      MapLocationModel(id: 14, lat: 30.0409, lng: 31.2090, type: "help"), // Agouza
      MapLocationModel(id: 15, lat: 30.0276, lng: 31.2331, type: "help"), // Dokki services
      MapLocationModel(id: 16, lat: 29.9970, lng: 31.1710, type: "help"), // Giza services
      MapLocationModel(id: 17, lat: 30.0600, lng: 31.2400, type: "help"), // Downtown help
      MapLocationModel(id: 18, lat: 30.0550, lng: 31.2600, type: "help"), // Ramses help
    ];
  }

  /// 🎛️ filter
  void applyFilter(String type, {bool updateState = true}) {
    if (updateState) {
      setState(() {
        selectedType = type;

        if (type == "all") {
          filteredLocations = allLocations;
        } else {
          filteredLocations =
              allLocations.where((e) => e.type == type).toList();
        }
      });
    } else {
      selectedType = type;

      if (type == "all") {
        filteredLocations = allLocations;
      } else {
        filteredLocations =
            allLocations.where((e) => e.type == type).toList();
      }
    }
  }

  /// 📍 markers
  List<Marker> buildMarkers() {
    return filteredLocations.map((loc) {
      Color color;

      if (loc.type == "danger") {
        color = Colors.red;
      } else if (loc.type == "safe") {
        color = Colors.green;
      } else {
        color = Colors.orange;
      }

      return Marker(
        point: LatLng(loc.lat, loc.lng),
        width: 40,
        height: 40,
        child: Icon(Icons.location_on, color: color, size: 40),
      );
    }).toList();
  }

  /// 🔘 تظبيط شكل الزرار ليكون مثل الصورة (Capsule & Shadow)
  Widget buildButton(String title, String type, Color color) {
    bool isSelected = selectedType == type;
    return GestureDetector(
      onTap: () => applyFilter(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: isSelected ? Border.all(color: Colors.black45, width: 1.5) : null,
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          /// 🟢 تظبيط الـ Header الأخضر
          Container(
            width: double.infinity,
            height: 110, // ارتفاع ثابت
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            alignment: Alignment.center,
            child: const SafeArea(
              child: Text(
                "Map",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),

          /// 🔘 منطقة الزراير)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildButton("Help arrived", "help", const Color(0xFFFFD54F)),
                buildButton("Safe places", "safe", const Color(0xFF81C784)),
                buildButton("Affected areas", "danger", const Color(0xFFE57373)),
              ],
            ),
          ),

          /// 🗺️ الخريطة
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(30.0444, 31.2357),
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  "https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
                  tileProvider:
                  FMTCStore('mapStore').getTileProvider(),
                  userAgentPackageName: "com.example.app",
                ),
                MarkerLayer(
                  markers: buildMarkers(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}