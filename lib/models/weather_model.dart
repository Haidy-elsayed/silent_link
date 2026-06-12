class WeatherModel {
  final String condition;
  final int temperature;
  final int humidity;
  final double windSpeed;
  final String cityName;

  WeatherModel({
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.cityName,
  });

  // 🚀 الفاكتوري الجديد اللي بيترجم رد الـ OpenWeatherMap بالـ GPS الحقيقي
  factory WeatherModel.fromOpenWeather(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? "Unknown Location", 
      temperature: (json['main']['temp'] as num).toInt(),
      humidity: (json['main']['humidity'] as num).toInt(),
      windSpeed: (json['wind']['speed'] as num).toDouble() * 3.6, // تحويل لـ km/h
      condition: json['weather'][0]['description'].toString().toUpperCase(),
    );
  }
}