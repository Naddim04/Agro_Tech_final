import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherData {
  final double temperature;
  final String condition;
  final IconData icon;
  final String city;
  final List<DailyForecast> daily;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.city,
    required this.daily,
  });
}

class DailyForecast {
  final String day;
  final String temp;
  final IconData icon;

  DailyForecast({required this.day, required this.temp, required this.icon});
}

class WeatherService {
  final String _apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _geoUrl = 'https://api.openweathermap.org/geo/1.0';

  /// Get coordinates from city name
  Future<Map<String, double>> fetchCoordinatesByCity(String cityName) async {
    final url = '$_geoUrl/direct?q=${Uri.encodeComponent(cityName)}&limit=1&appid=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('City not found');
    }

    final List<dynamic> data = json.decode(response.body);
    if (data.isEmpty) {
      throw Exception('City not found. Please try another name.');
    }

    return {
      'lat': data[0]['lat'].toDouble(),
      'lon': data[0]['lon'].toDouble(),
    };
  }

  Future<WeatherData> fetchWeather(double lat, double lon) async {
    // 1. Fetch Current Weather (provides temperature, condition, and CITY NAME)
    final currentUrl = '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
    final currentResponse = await http.get(Uri.parse(currentUrl));

    if (currentResponse.statusCode != 200) {
      throw Exception('Failed to load current weather');
    }

    final currentData = json.decode(currentResponse.body);
    final String cityName = currentData['name'] ?? 'Unknown';

    // 2. Fetch Forecast
    final forecastUrl = '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
    final forecastResponse = await http.get(Uri.parse(forecastUrl));

    if (forecastResponse.statusCode != 200) {
      throw Exception('Failed to load forecast');
    }

    final forecastData = json.decode(forecastResponse.body);
    final List<dynamic> list = forecastData['list'];

    final List<DailyForecast> dailyForecasts = [];
    
    // The forecast 2.5 API returns data every 3 hours. 
    // We'll pick one entry per day for the next 3 days (approx indices 8, 16, 24)
    final Set<String> addedDays = {};
    final today = DateTime.now().day;

    for (var entry in list) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(entry['dt'] * 1000);
      final String dayName = _getDayName(dateTime.weekday);
      
      if (dateTime.day != today && !addedDays.contains(dayName) && dailyForecasts.length < 3) {
        dailyForecasts.add(DailyForecast(
          day: dayName,
          temp: '${entry['main']['temp'].round()}°C',
          icon: _getWeatherIcon(entry['weather'][0]['icon']),
        ));
        addedDays.add(dayName);
      }
    }

    return WeatherData(
      temperature: currentData['main']['temp'].toDouble(),
      condition: currentData['weather'][0]['main'],
      icon: _getWeatherIcon(currentData['weather'][0]['icon']),
      city: cityName,
      daily: dailyForecasts,
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  IconData _getWeatherIcon(String iconCode) {
    // OpenWeatherMap icon mapping
    if (iconCode.startsWith('01')) return Icons.wb_sunny;
    if (iconCode.startsWith('02')) return Icons.wb_cloudy_outlined;
    if (iconCode.startsWith('03') || iconCode.startsWith('04')) return Icons.cloud_outlined;
    if (iconCode.startsWith('09') || iconCode.startsWith('10')) return Icons.umbrella_outlined;
    if (iconCode.startsWith('11')) return Icons.thunderstorm_outlined;
    if (iconCode.startsWith('13')) return Icons.ac_unit;
    if (iconCode.startsWith('50')) return Icons.cloud_queue;
    return Icons.wb_sunny;
  }
}
