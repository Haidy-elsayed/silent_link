import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/weather_model.dart'; 

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  WeatherModel? _weather; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStaticWeather();
  }

 
  void _loadStaticWeather() {
    setState(() {
      _weather = WeatherModel(
       cityName: "El Shorouk City", 
        temperature: 36,            
        condition: "CLEAR SKY",    
        humidity: 32,              
        windSpeed: 18.0,        
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: SizedBox(
            width: 24, 
            height: 24, 
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)
          ),
        ),
      );
    }

    final data = _weather!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), 
            blurRadius: 15, 
            offset: const Offset(0, 5), 
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.cityName, 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 5),
              Text(
                "Wind ${data.windSpeed.toInt()}km/h", 
                style: const TextStyle(color: Colors.grey, fontSize: 14)
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.water_drop_outlined, size: 18, color: Colors.blue),
                  Text(" ${data.humidity}%", style: const TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
          Column(
            children: [
              const Icon(Icons.wb_sunny_outlined, size: 50, color: Colors.orange), 
              const SizedBox(height: 5),
              Text(
                "${data.temperature}°C", 
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)
              ),
              Text(
                data.condition, 
                style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)
              ),
            ],
          ),
        ],
      ),
    );
  }
}